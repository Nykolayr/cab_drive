from flask import blueprints, request, render_template, session, abort, redirect, url_for

import chats.api
import orders.api
from errors import *
import utils
import json
import users
import tariffs
import drivers
import enums
import trips
import datetime
import settings
import payments
import config
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FuturesTimeout
import ttl_cache

app = blueprints.Blueprint('d', __name__, url_prefix='/d')

_EMPTY_STATS = (0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, [0.0] * 12, {})


def _call_timeout(fn, timeout_sec=10, default=None):
    """Таймаут без join зависшего Firestore-потока (иначе gunicorn worker мёртв до SIGKILL)."""
    pool = ThreadPoolExecutor(max_workers=1)
    try:
        return pool.submit(fn).result(timeout=timeout_sec)
    except FuturesTimeout:
        print(f"[dashboard] timeout {timeout_sec}s on {getattr(fn, '__name__', fn)}")
        return default
    except Exception as e:
        print(f"[dashboard] soft-fail {getattr(fn, '__name__', fn)}: {e}")
        return default
    finally:
        pool.shutdown(wait=False, cancel_futures=True)


def _safe_order_stats(user_id, driver_id, start_date, finish_date, city, timeout_sec=4):
    """Возвращает {'stats': tuple|list, 'quota_exhausted': bool}. TTL + Redis на все workers."""
    key = f"dash:stats_pack:{user_id}:{driver_id}:{start_date}:{finish_date}:{city}"
    empty_pack = {"stats": _EMPTY_STATS, "quota_exhausted": True}
    rkey = f"{user_id}|{driver_id}|{start_date}|{finish_date}|{city}"

    try:
        import cache as redis_cache
        raw = redis_cache.get_cache("dash_stats", rkey)
        if raw:
            packed = json.loads(raw)
            if isinstance(packed, dict) and "stats" in packed:
                return packed
    except Exception:
        pass

    def _load():
        result = _call_timeout(
            lambda: orders.api.get_order_statistics_result(
                user_id, driver_id, start_date, finish_date, city
            ),
            timeout_sec=timeout_sec,
            default=empty_pack,
        )
        if not isinstance(result, dict) or "stats" not in result:
            return empty_pack
        return {
            "stats": result.get("stats") or _EMPTY_STATS,
            "quota_exhausted": bool(result.get("quota_exhausted")),
        }

    pack = ttl_cache.get_or_set(key, 180, _load)
    try:
        import cache as redis_cache
        redis_cache.set_cache(
            "dash_stats",
            rkey,
            json.dumps(pack, default=str),
            minutes=3,
        )
    except Exception:
        pass
    return pack


def _safe_firebase_user_lists(timeout_sec=3):
    def _load():
        users_list = _call_timeout(
            lambda: users.api.get_firebase_users(is_driver=False, is_all=True)['users'],
            timeout_sec=timeout_sec,
            default=[],
        ) or []
        driver_list = _call_timeout(
            lambda: users.api.get_firebase_users(is_driver=True, is_all=True)['users'],
            timeout_sec=timeout_sec,
            default=[],
        ) or []
        return users_list, driver_list

    return ttl_cache.get_or_set('dash:user_filter_lists', 300, _load)


def _stats_filter_lists(need_lists: bool):
    """На статистике списки users/drivers тяжелые — по умолчанию не грузим (быстрый первый экран)."""
    if not need_lists:
        return [], []
    return _safe_firebase_user_lists(timeout_sec=3)


@app.route('/')
def home():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    # Get statistics data

    user_id = request.values.get('user_id', "", str)
    driver_id = request.values.get('driver_id', "", str)

    start_date = request.values.get('start_date', '', str)
    finish_date = request.values.get('finish_date', '', str)

    city_data = request.values.get('city', '', str)

    city = city_data if len(city_data) > 0 else None
    user_id = user_id if user_id != 0 else None
    driver_id = driver_id if driver_id != 0 else None

    try:
        start_date = datetime.datetime.strptime(start_date, '%Y-%m-%dT%H:%M')
    except:
        start_date = None
    try:
        finish_date = datetime.datetime.strptime(finish_date, '%Y-%m-%dT%H:%M')
    except:
        finish_date = None

    # Sample ≤400 docs / 120 дней + TTL (см. get_order_statistics_result).
    stats_pack = _safe_order_stats(user_id, driver_id, start_date, finish_date, city, timeout_sec=4)
    order_stats = stats_pack["stats"]
    firestore_quota_exhausted = stats_pack.get("quota_exhausted", False)
    need_lists = bool(user_id or driver_id or request.values.get('with_filters'))
    users_list, driver_list = _stats_filter_lists(need_lists)

    return render_template(
        'dashboard/statistics.html',
        user=user,
        order_stats=order_stats,
        firestore_quota_exhausted=firestore_quota_exhausted,
        client_id=user_id,
        driver_id=driver_id,
        start_date=start_date,
        finish_date=finish_date,
        users_list=users_list,
        driver_list=driver_list,
        city=city,
    )


@app.route('/payments')
def payments_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    payments_list = payments.api.get_payments()
    drivers_list = drivers.api.get_drivers(is_all=True)
    drivers_dict = {driver.id: driver for driver in drivers_list}

    for payment in payments_list:
        payment.driver = drivers_dict[payment.driver_id]

    return render_template('dashboard/payments.html', user=user, payments_list=payments_list)


@app.route('/auth_codes')
def auth_codes_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    auth_codes = users.api.get_auth_codes()

    return render_template('dashboard/auth_codes.html', user=user, auth_codes=auth_codes)


@app.route('/users')
def users_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    filter_type = request.values.get('filter', "all", str)
    page = request.values.get('page', 1, int)
    search_query = request.values.get('search', "", str).strip()

    is_driver = None
    on_verif_now = None

    if filter_type == "driver":
        is_driver = True
    elif filter_type == "client":
        is_driver = False
    elif filter_type == "verification":
        is_driver = True
        on_verif_now = True

    if filter_type is None:
        filter_type = 'all'

    users_list = _call_timeout(
        lambda: ttl_cache.get_or_set(
            f"dash:users:{filter_type}:{page}:{search_query}",
            60,
            lambda: users.api.get_firebase_users(
                query=search_query if search_query else None,
                is_driver=is_driver,
                on_verif_now=on_verif_now,
                page=page,
            ),
        ),
        timeout_sec=8,
        default={'users': [], 'current_page': 1, 'total_pages': 1, 'total_users': 0},
    )

    super_admins = []
    if utils.is_super_admin(user):
        super_admins = _call_timeout(
            users.api.get_dashboard_super_admins,
            timeout_sec=5,
            default=[],
        ) or []

    return render_template(
        'dashboard/users.html',
        user=user,
        users_list=users_list['users'],
        f_phone=utils.format_phone,
        filter=filter_type,
        search=search_query,
        current_page=users_list.get('current_page', 1),
        total_pages=users_list.get('total_pages', 1),
        total_user=users_list.get('total_pages', 1),
        super_admins=super_admins,
        is_super_admin=utils.is_super_admin(user),
    )


@app.route('/user')
def user_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    client_id = request.values.get('id', "", str)
    client = _call_timeout(
        lambda: users.api.get_firebase_user_by_id(client_id),
        timeout_sec=10,
        default=None,
    )
    if not client:
        return redirect('/d/users')
    balance = 0
    verification_data=None

    if client.get('is_driver'):
        balance = _call_timeout(
            lambda: users.api.calculate_user_balance(client['id'], None, None),
            timeout_sec=10,
            default=0,
        )
        verification_data = _call_timeout(
            lambda: users.api.get_driver_verification_data(client['id']),
            timeout_sec=10,
            default=None,
        )

    from datetime import datetime

    current_year_month = datetime.now().strftime('%Y-%m')
    statistics = _call_timeout(
        lambda: users.api.get_monthly_user_statistics(client['id'], current_year_month),
        timeout_sec=10,
        default={},
    )
    return render_template('dashboard/user.html', user=user, client=client, f_phone=utils.format_phone, server_path=utils.get_server_ip(), balance=balance, statistics=statistics, verification_data=verification_data)


@app.route('/tariffs')
def tariffs_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    tariffs_list = tariffs.api.get_tariffs()

    return render_template('dashboard/tariffs.html', user=user, tariffs_list=tariffs_list)


@app.route('/drivers')
def drivers_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    is_blocked = request.values.get('is_blocked', 0, int)
    status = request.values.get('status', '', str)

    is_blocked = False if is_blocked == 0 else True
    status = utils.str_to_enum(status, enums.DriverStatus)

    conditions_list = [
        drivers.Driver.is_blocked == is_blocked,
        ]

    if status is not None:
        conditions_list.append(drivers.Driver.status == status)

    drivers_list = drivers.api.get_drivers(conditions_list=conditions_list, is_all=True)

    return render_template('dashboard/drivers.html', user=user, drivers_list=drivers_list,
                           is_blocked=is_blocked, status=status, DriverStatus=enums.DriverStatus)


@app.route('/driver')
def driver_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    driver_id = request.values.get('id', 0, int)

    driver = drivers.api.get_driver_by_id(driver_id)
    if driver is None:
        return utils.get_error('Driver not found')

    tariffs_list = tariffs.api.get_tariffs()

    tariffs_dict = {}

    for tariff in driver.tariffs:
        tariffs_dict[tariff.id] = tariff.status

    return render_template('dashboard/driver.html', user=user, driver=driver, DriverStatus=enums.DriverStatus,
                           tariffs_list=tariffs_list, tariffs_dict=tariffs_dict)


@app.route('/chats')
def chats_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    page = request.values.get('page', 0, int)
    sort = request.values.get('sort')
    if not page:
        page = 1
    chats_list = _call_timeout(
        lambda: ttl_cache.get_or_set(
            f"dash:chats:{page}:{sort}",
            60,
            lambda: chats.api.fetch_firebase_chats(page, 10, sort_by=sort),
        ),
        timeout_sec=8,
        default={'chats': [], 'current_page': 1, 'total_pages': 1},
    )

    return render_template(
        'dashboard/chats.html',
        user=user,
        chat_list=chats_list.get('chats', []),
        current_page=chats_list.get('current_page', 1),
        page=chats_list.get('current_page', 1),
        total_pages=chats_list.get('total_pages', 1),
    )


@app.route('/chat')
def chat_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    user_name = request.values.get('user_name')
    user_id = request.values.get('user_id')
    chat_id = request.values.get('chat_id')

    chats.api.mark_chat_messages_read(chat_id)




    return render_template('dashboard/chat.html', user=user, chat_id=chat_id, user_name=user_name, user_id=user_id)



@app.route('/trips')
def trips_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    status_id = request.values.get('status_id', "", str)
    user_id = request.values.get('user_id', "", str)
    driver_id = request.values.get('driver_id', "", str)

    start_date = request.values.get('start_date', '', str)
    finish_date = request.values.get('finish_date', '', str)

    price_from = request.values.get('price_from')
    price_to = request.values.get('price_to')

    distance_from = request.values.get('distance_from')
    distance_to = request.values.get('distance_to')

    status_id = status_id if status_id != "" else None

    user_id = user_id if user_id != 0 else None
    driver_id = driver_id if driver_id != 0 else None

    try:
        start_date = datetime.datetime.strptime(start_date, '%Y-%m-%dT%H:%M')
    except:
        start_date = None
    try:
        finish_date = datetime.datetime.strptime(finish_date, '%Y-%m-%dT%H:%M')
    except:
        finish_date = None

    users_list, driver_list = _safe_firebase_user_lists(timeout_sec=6)
    page = request.values.get('page', 1, int)

    order_list = _call_timeout(
        lambda: ttl_cache.get_or_set(
            f"dash:trips:{status_id}:{user_id}:{driver_id}:{start_date}:{finish_date}:{page}:{price_from}:{price_to}:{distance_from}:{distance_to}",
            45,
            lambda: orders.api.fetch_firebase_orders(
                client_id=user_id,
                driver_id=driver_id,
                start_date=start_date,
                finish_date=finish_date,
                status=status_id,
                page=page,
                price_from=price_from,
                price_to=price_to,
                distance_from=distance_from,
                distance_to=distance_to,
            ),
        ),
        timeout_sec=8,
        default={'orders': [], 'current_page': 1, 'total_pages': 1, 'total_orders': 0},
    )

    users_list = users_list or []
    driver_list = driver_list or []
    users_list.sort(key=lambda _user: _user['id'])

    return render_template('dashboard/orders.html', user=user, status_id=status_id,
                           is_finished=False, user_id=user_id,
                           start_date=start_date, finish_date=finish_date,
                           users_list=users_list, driver_list=driver_list, order_list=order_list.get('orders', []),total_pages=order_list.get('total_pages', 1), total_orders=order_list.get('total_orders', 0), current_page=order_list.get('current_page', 1) )


@app.route('/trip')
def trip_page():
    user = utils.get_user([1, 2])
    if user is None:
        return redirect('/d/auth')

    trip_id = request.values.get('id', "", str)

    trip = orders.api.get_order_by_id(trip_id)
    if trip is None:
        return utils.get_error('Поездка не найдена')

    print(trip)
    client = users.api.get_firebase_user_by_id(trip['user_customer'])
    if trip.get('selected_driver') is not None:
        driver = users.api.get_firebase_user_by_id(trip['selected_driver'])
    else:
        driver = None
    return render_template('dashboard/trip.html', user=user, trip=trip, client=client,
                           driver=driver, )


@app.route('/driver_tariffs')
def driver_tariffs_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    model = settings.get_model()

    return render_template('dashboard/driver_tariffs.html', user=user, tariffs_list=model.driver_tariffs)


@app.route('/polygons')
def polygons_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    model = settings.get_model()

    return render_template('dashboard/polygons.html', user=user,
                           polygons_json=[polygon.model_dump() for polygon in model.polygons])


@app.route('/cities')
def cities_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    model = settings.get_model()

    return render_template('dashboard/cities.html', user=user,
                           polygons_json=[polygon.model_dump() for polygon in model.cities])


@app.route('/notify')
def notify_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    return render_template('dashboard/notify.html', user=user)


@app.route('/operator')
def operator_page():
    user = utils.get_user([1, 2])
    if user is None:
        return redirect('/d/auth')

    trip_id = request.values.get('trip_id', 0, str)
    page = request.values.get('page', 1, int)

    trip = None
    if trip_id > 0:
        trip = _call_timeout(
            lambda: orders.api.get_order_by_id(trip_id),
            timeout_sec=10,
            default=None,
        )

    order_list = _call_timeout(
        lambda: orders.api.fetch_firebase_orders(
            client_id=None,
            driver_id=None,
            start_date=None,
            finish_date=None,
            status=None,
            page=page,
        ),
        timeout_sec=10,
        default={'orders': [], 'current_page': 1, 'total_pages': 1, 'total_orders': 0},
    )

    return render_template(
        'dashboard/operator.html',
        user=user,
        trip=trip,
        order_list=order_list.get('orders', []),
        total_pages=order_list.get('total_pages', 1),
        total_orders=order_list.get('total_orders', 0),
        page=order_list.get('current_page', page),
    )

@app.route('/auth', methods=['GET', 'POST'])
def auth_api():
    user = utils.get_user()
    if user is not None:
        return redirect(url_for('d.home'))

    if request.method == 'GET':
        return render_template('dashboard/auth.html')
    else:
        phone = request.values.get('phone')
        password = request.values.get('password')

        if users.api.authenticate(phone, password):
            return utils.get_answer('ok')

        return utils.get_error('Неверный пароль', status=200)


@app.route('/logout')
def logout():
    session['user_id'] = None
    return redirect(url_for('d.auth_api'))


# New route for statistics
@app.route('/statistics')
def statistics_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    # Get statistics data

    user_id = request.values.get('user_id', "", str)
    driver_id = request.values.get('driver_id', "", str)

    start_date = request.values.get('start_date', '', str)
    finish_date = request.values.get('finish_date', '', str)

    city_data = request.values.get('city', '', str)
    page = request.values.get('page', 1, int)

    city = city_data if len(city_data) > 0 else None
    user_id = user_id if user_id != 0 else None
    driver_id = driver_id if driver_id != 0 else None

    print(f"request value {request.values}")
    try:
        start_date = datetime.datetime.strptime(start_date, '%Y-%m-%dT%H:%M')
    except:
        start_date = None
    try:
        finish_date = datetime.datetime.strptime(finish_date, '%Y-%m-%dT%H:%M')
    except:
        finish_date = None

    # Sample ≤400 docs / 120 дней + TTL (см. get_order_statistics_result).
    stats_pack = _safe_order_stats(user_id, driver_id, start_date, finish_date, city, timeout_sec=4)
    order_stats = stats_pack["stats"]
    firestore_quota_exhausted = stats_pack.get("quota_exhausted", False)
    need_lists = bool(user_id or driver_id or request.values.get('with_filters'))
    users_list, driver_list = _stats_filter_lists(need_lists)

    return render_template(
        'dashboard/statistics.html',
        user=user,
        order_stats=order_stats,
        firestore_quota_exhausted=firestore_quota_exhausted,
        client_id=user_id,
        driver_id=driver_id,
        start_date=start_date,
        finish_date=finish_date,
        users_list=users_list,
        driver_list=driver_list,
        city=city,
    )


@app.route('/order_settings')
def orders_settings_page():
    user = utils.get_user()
    if user is None:
        return redirect('/d/auth')

    settings_model= settings.get_model()

    return render_template('dashboard/order_settings.html', user=user, minutes=settings_model.minutes_for_delete_order, deadline_minutes=settings_model.deadline_minutes)


@app.route('/tinkoff')
def tinkoff_page():
    user = utils.require_super_admin()
    if user is None:
        return redirect('/d/auth')

    model = settings.get_model()
    cfg = config.Production
    return render_template(
        'dashboard/tinkoff.html',
        user=user,
        mode=model.tinkoff_mode or 'test',
        payments_base_url=model.payments_base_url or 'https://cab.artean.ru',
        test_keys_set=bool(
            getattr(cfg, 'TINKOFF_TEST_TERMINAL_KEY', None)
            or getattr(cfg, 'TINKOFF_TERMINAL_KEY', None)
        ),
        prod_keys_set=bool(getattr(cfg, 'TINKOFF_PROD_TERMINAL_KEY', None)),
    )


@app.route('/tinkoff/logs')
def tinkoff_logs_api():
    """JSON список событий T‑Bank для таба «Логи» (только суперадмин)."""
    user = utils.require_super_admin()
    if user is None:
        return abort(403)

    import tinkoff.events_log as events_log

    fails = request.values.get('fails_only', '', str).lower() in ('1', 'true', 'yes')
    try:
        limit = int(request.values.get('limit', 100))
    except ValueError:
        limit = 100
    try:
        offset = int(request.values.get('offset', 0))
    except ValueError:
        offset = 0

    data = events_log.query_events(
        date_from=request.values.get('from', '', str),
        date_to=request.values.get('to', '', str),
        event_type=request.values.get('type', '', str),
        level=request.values.get('level', '', str),
        q=request.values.get('q', '', str),
        fails_only=fails,
        limit=limit,
        offset=offset,
    )
    return utils.get_answer('', data)


@app.route('/super_admins', methods=['POST'])
def create_super_admin_api():
    user = utils.require_super_admin()
    if user is None:
        return abort(403)

    data = request.json or {}
    try:
        created = users.api.create_super_admin(
            phone=str(data.get('phone') or ''),
            password=str(data.get('password') or ''),
            name=str(data.get('name') or ''),
        )
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Суперадмин сохранён', info={
        'id': created.id,
        'phone': created.phone,
        'name': created.name,
    })

