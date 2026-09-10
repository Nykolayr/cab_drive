import logging
import math
import string
import traceback
from random import random

from flask import session as flask_session
from typing import List, Tuple, Dict, Any, Optional

from proto.datetime_helpers import DatetimeWithNanoseconds

from db import Session
from logger import logger
from .entities import *
from errors import *
from .models import *
from uuid import uuid4

import files
import utils
import json
import zvonok
import cache
import datetime
import notify
import os

def get_user_by_id(user_id, session=None, check=True) -> User | None:
    if session is None:
        with Session() as session:
            user = session.query(User).get(user_id)
    else:
        user = session.query(User).get(user_id)

    if user.is_removed and check:
        return None
    return user


def get_user_by_phone(phone, session=None) -> FirebaseUser | None:
    if session is None:
        with Session() as session:
            user = session.query(FirebaseUser).filter(FirebaseUser.phone == phone).first()
    else:
        user = session.query(FirebaseUser).filter(FirebaseUser.phone == phone).first()
    return user


def get_users(conditions_list=[], is_all=False, session=None) -> List[FirebaseUser]:
    if session is None:
        with Session() as session:
            users_list = session.query(FirebaseUser)

            if len(conditions_list) > 0:
                for condition in conditions_list:
                    users_list = users_list.filter(condition)

            users_list = users_list.all()
    else:
        users_list = session.query(FirebaseUser)

        if len(conditions_list) > 0:
            for condition in conditions_list:
                users_list = users_list.filter(condition)

        users_list = users_list.all()
    return users_list


def auth(model: AuthRequestModel) -> str:
    model.phone = utils.telephone(model.phone)
    if model.phone is None:
        raise IncorrectDataValue('Please provide a valid phone number.')

    if model.phone is not None and model.phone == '9001112233':
        code = '1111'
    if model.phone is not None and model.phone == '9956641268':
        code = '1111'
    elif model.phone is not None and model.phone.startswith('111'):
        code = '2259'
    else:
        check = cache.get_cache('auth_check', model.phone)
        if check is not None:
            raise IncorrectDataValue('Please try again later.')
        cache.set_cache('auth_check', model.phone, '1', 1)
        code = zvonok.call(model.phone)

    with Session() as session:
        identity = model.phone
        auth_code = AuthCode(identity=identity, code=code)
        session.add(auth_code)
        session.commit()

    auth_model = AuthModel(phone=model.phone, date=datetime.datetime.now(), code=code)
    token = str(uuid4())
    #AUTH_TOKENS[token] = auth_model

    value = json.dumps(utils.to_json(auth_model.model_dump()), ensure_ascii=False, indent=3)
    cache.set_cache('auth', token, value, minutes=10)

    return token



def _find_firebase_user_by_phone(phone: str):
    from firebase_admin import auth

    for domain in (AUTH_EMAIL_DOMAIN, 'ydrive.com'):
        try:
            return auth.get_user_by_email(f'{phone}@{domain}')
        except Exception:
            continue
    return None


def create_user_by_phone(phone):
    from firebase_admin import auth

    with Session() as session:
        check = get_user_by_phone(phone, session=session)
        if check is not None:
            raise IncorrectDataValue('This phone number is already registered.')

        email = auth_email(phone)
        fb_user = _find_firebase_user_by_phone(phone)

        if fb_user is None:
            generated_password = utils.generate_random_password(8)
            fb_user = auth.create_user(
                email=email,
                password=generated_password,
                display_name=f'{phone}',
            )
        else:
            # Старый OTP: пароль совпадал с email. Привязываем SQL без смены пароля в Firebase.
            generated_password = email
            if fb_user.email != email:
                try:
                    fb_user = auth.update_user(fb_user.uid, email=email)
                except Exception as e:
                    logger.warning(
                        'create_user_by_phone: не удалось обновить email %s → %s: %s',
                        fb_user.email,
                        email,
                        e,
                    )

        user = FirebaseUser(
            phone=phone,
            password=generated_password,
            firebase_id=fb_user.uid,
        )

        session.add(user)
        session.commit()
    return get_user_by_phone(phone)


def auth_by_code(model: AuthByCodeRequestModel) -> Tuple[FirebaseUser, str]:
    try:
        auth_model = cache.get_cache('auth', model.call_token)

        if auth_model is None:
            raise IncorrectDataValue('Invalid call token.')

        auth_model = AuthModel.model_validate(json.loads(auth_model))

        auth_model.phone =  utils.telephone(auth_model.phone)

        if auth_model.code != model.code:
            raise IncorrectDataValue('Incorrect confirmation code.')

        diff = (datetime.datetime.now(datetime.timezone.utc) - auth_model.date).seconds
        if diff > 300:
            raise IncorrectDataValue('The confirmation code has expired. Please request a new one.')

        user = get_user_by_phone(phone=auth_model.phone)
        if user is None:
            user = create_user_by_phone(auth_model.phone)

        access_token = create_access_token(
            identity={
                'account_type': 'user',
                'id': user.id
            },
            expires_delta=datetime.timedelta(days=365)
        )
        return user, access_token
    except Exception as e:
        logger.error("Ошибка в auth_by_code: %s", str(e))
        logger.error("Источник ошибки:\n%s", traceback.format_exc())
        raise e


def api_get_me(user_id) -> User:
    return get_user_by_id(user_id)


def authenticate(phone, password):
    with Session() as session:
        print(password)
        user = session.query(User).filter(User.phone == utils.telephone(phone), User.password == password).first()
        print(user)
        if user is None:
            return False
        if user.account_type == 0:
            return False
    flask_session['user_id'] = user.id
    return True


def get_dashboard_super_admins() -> List[User]:
    with Session() as session:
        return (
            session.query(User)
            .filter(User.is_super_admin.is_(True), User.is_removed.is_(False))
            .order_by(User.id.asc())
            .all()
        )


def create_super_admin(phone: str, password: str, name: str = '') -> User:
    phone_n = utils.telephone(phone)
    if not phone_n:
        raise IncorrectDataValue('Некорректный телефон')
    if not password or len(str(password)) < 4:
        raise IncorrectDataValue('Пароль слишком короткий')

    with Session() as session:
        existing = session.query(User).filter(User.phone == phone_n).first()
        if existing is not None:
            if existing.is_removed:
                existing.is_removed = False
            existing.password = str(password)
            existing.is_super_admin = True
            existing.is_admin = True
            existing.account_type = 2
            if name:
                existing.name = name
            session.commit()
            uid = existing.id
        else:
            user = User(
                phone=phone_n,
                password=str(password),
                name=name or phone_n,
                is_admin=True,
                is_super_admin=True,
                account_type=2,
            )
            session.add(user)
            session.commit()
            uid = user.id
    return get_user_by_id(uid)


def ensure_bootstrap_super_admin():
    """Стартовый суперадмин 9001112234 — создать/пометить при старте приложения."""
    phone = '9001112234'
    password = '2259'
    try:
        with Session() as session:
            # колонка могла ещё не существовать — вызывающий делает ALTER
            user = session.query(User).filter(User.phone == phone).first()
            if user is None:
                user = User(
                    phone=phone,
                    password=password,
                    name='Super Admin',
                    is_admin=True,
                    is_super_admin=True,
                    account_type=2,
                )
                session.add(user)
            else:
                user.is_super_admin = True
                user.is_admin = True
                user.account_type = 2
                if not user.password:
                    user.password = password
            session.commit()
    except Exception:
        logger.error(f'[ensure_bootstrap_super_admin] {traceback.format_exc()}')


def api_edit(user_id: int, model: EditUserRequest) -> User:
    with Session() as session:
        user = get_user_by_id(user_id, session=session)
        if user is None:
            raise AuthEmptyException()

        if model.photo_uuid is not None:
            file = files.api.get_file_by_uuid(model.photo_uuid, session=session)
            if file is None:
                raise IncorrectDataValue('Image with this UUID not found.')

        user.name = model.name
        user.photo_uuid = model.photo_uuid

        session.commit()
    return get_user_by_id(user_id)


def get_auth_codes() -> List[AuthCode]:
    with Session() as session:
        auth_codes = session.query(AuthCode).order_by(AuthCode.created_at.desc()).all()
    return auth_codes


def edit_user(user_id, name, password, account_type, photo_uuid):
    if len(password) == 0:
        raise IncorrectDataValue('Please provide the admin password.')

    with Session() as session:
        user = get_user_by_id(user_id, session=session)
        if user is None:
            raise IncorrectDataValue('User not found.')

        user.name = name
        user.password = password
        user.account_type = account_type
        user.photo_uuid = photo_uuid

        session.commit()


def remove_me(user_id):
    with Session() as session:
        user = get_user_by_id(user_id, session=session)
        if user is None:
            raise IncorrectDataValue('User not found.')

        user.is_removed = True
        session.commit()


def unremove_me(user_id):
    with Session() as session:
        user = get_user_by_id(user_id, session=session, check=False)
        if user is None:
            raise IncorrectDataValue('User not found.')

        user.is_removed = False
        session.commit()


def set_fcm_token(uid, fcm_token, user_id):
    with Session() as session:
        user = session.query(FirebaseUser).filter(FirebaseUser.firebase_id == uid).first()
        if user is None:
            raise IncorrectDataValue('User not found.')

        res = notify.push_service.subscribe_to_topic([fcm_token], 'all')
        if 'error' in res:
            raise IncorrectDataValue(res['error'])
        if res['success_count'] == 0:
            raise IncorrectDataValue('Please provide a valid FCM token.')
        user.user_id = user_id
        user.fcm_token = fcm_token
        session.commit()
    return user


def get_firebase_users(query: Optional[str] = None,
                       is_driver: Optional[bool] = None,
                       login_is_complete: Optional[bool] = None,
                       on_verif_now: Optional[bool] = None,
                       page: int = 1,
                       per_page: int = 10,
                       is_all=False) -> Dict[str, Any]:
    """
    Retrieve a paginated list of users from the 'users' collection.

    Возвращает dict:
    {
        "users": [...],
        "total_pages": int,
        "total_users": int,   # общее количество подходящих документов
        "current_page": int,
    }

    Примечания:
    - Фильтрация по булевым полям выполняется на стороне Firestore (where).
    - Подстрочный поиск по email выполняется на стороне приложения (нельзя сделать через where).
    - Если query (по email) передан — подсчёт total_users и пагинация выполняются после client-side фильтрации.
    """
    try:
        # Быстрый путь: список из Postgres (в т.ч. filter on_verif_now).
        if login_is_complete is None:
            try:
                import app_pg
                if app_pg.enabled():
                    if page is None or page < 1:
                        page = 1
                    if per_page is None or per_page <= 0:
                        per_page = 20
                    if is_all:
                        page_data = app_pg.list_users_page(
                            is_driver=is_driver,
                            on_verif_now=on_verif_now,
                            query=query,
                            limit=100,
                            offset=0,
                        )
                        page_rows = page_data.get("users") or []
                        total_users = int(page_data.get("total") or 0)
                        return {
                            "users": page_rows,
                            "total_pages": 1,
                            "total_users": total_users,
                            "current_page": 1,
                            "source": "postgres",
                        }
                    offset = (page - 1) * per_page
                    page_data = app_pg.list_users_page(
                        is_driver=is_driver,
                        on_verif_now=on_verif_now,
                        query=query,
                        limit=per_page,
                        offset=offset,
                    )
                    page_rows = page_data.get("users") or []
                    total_users = int(page_data.get("total") or 0)
                    # пустой список при активном фильтре on_verif — тоже ответ PG
                    if page_rows or on_verif_now is not None or total_users >= 0:
                        total_pages = (
                            max(1, (total_users + per_page - 1) // per_page)
                            if total_users
                            else 1
                        )
                        return {
                            "users": page_rows,
                            "total_pages": total_pages,
                            "total_users": total_users,
                            "current_page": page,
                            "source": "postgres",
                        }
            except Exception:
                logger.exception("[users.get_firebase_users] app_pg list failed, fallback Firestore")

        if on_verif_now is None and login_is_complete is None:
            pass  # already tried PG above

        client = utils.init_firebase_client()
        users_ref = client.collection('users')
        query_ref = users_ref

        # Apply server-side boolean filters
        if is_driver is not None:
            query_ref = query_ref.where('is_driver', '==', is_driver)
        if login_is_complete is not None:
            query_ref = query_ref.where('login_complete', '==', login_is_complete)
        if on_verif_now is not None:
            query_ref = query_ref.where('on_verif_now', '==', on_verif_now)
        # Normalize paging params
        if page is None or page < 1:
            page = 1
        if per_page is None or per_page <= 0:
            per_page = 20
        offset = (page - 1) * per_page

        q_lower = (query or '').strip().lower() if query else None

        # If there's no substring query, we can do server-side count + server-side pagination
        if not q_lower:
            total_users = None
            # Try aggregate count() if SDK supports it
            try:
                count_query = query_ref.count()
                count_result = count_query.get()
                if hasattr(count_result, 'count'):
                    total_users = int(count_result.count)
                else:
                    # fallback if shape differs
                    try:
                        total_users = int(count_result[0])
                    except Exception:
                        total_users = None
            except Exception:
                total_users = None

            # Fallback: НЕ стримим всю коллекцию ради count (сжигает quota).
            if total_users is None:
                total_users = -1

            # Server-side ordering for deterministic results
            if is_all:
                query_page = query_ref.order_by('created_time', direction='DESCENDING').limit(100)
            else:
                query_page = query_ref.order_by('created_time', direction='DESCENDING').offset(offset).limit(per_page)

            docs = query_page.stream()
            data: List[Dict[str, Any]] = []
            for doc in docs:
                value = firebase_user_to_json(doc)
                if isinstance(value, dict):
                    value.setdefault('id', doc.id)
                data.append(value)

            if total_users < 0:
                total_users = offset + len(data)
                if len(data) >= per_page:
                    total_users += 1
            total_pages = math.ceil(total_users / per_page) if per_page > 0 else 1
            if total_pages < page:
                total_pages = page

            return {
                "users": data,
                "total_pages": total_pages,
                "total_users": total_users,
                "current_page": page,
            }

        # Поиск: не читаем всю коллекцию — потолок документов.
        all_docs = query_ref.limit(300).stream()
        matched: List[Dict[str, Any]] = []
        for doc in all_docs:
            data = doc.to_dict() or {}
            email = (data.get('email') or '').lower()
            name = (data.get('name') or '').lower()
            phone = (data.get('phone') or '').lower()
            if q_lower not in email and q_lower not in name and q_lower not in phone:
                continue
            value = firebase_user_to_json(doc)
            if isinstance(value, dict):
                value.setdefault('id', doc.id)
            matched.append(value)

        total_users = len(matched)
        total_pages = math.ceil(total_users / per_page) if per_page > 0 else 1

        # Slice the matched results for requested page
        start = offset
        end = offset + per_page
        page_items = matched[start:end]

        return {
            "users": page_items,
            "total_pages": total_pages,
            "total_users": total_users,
            "current_page": page,
        }

    except Exception as e:
        raise IncorrectDataValue(f'Error retrieving users from Firebase: {e}')


def calculate_user_balance(user_id: str, start_date: str | None, end_date: str | None) -> float:
    """
    Calculate the user's balance based on completed orders.

    :param user_id: User ID for balance calculation.
    :param start_date: Start date for calculation in ISO format (e.g. '2025-08-19') or None.
    :param end_date: End date for calculation in ISO format or None.
    :return: Total amount of completed orders (float).
    """
    import datetime
    from google.api_core import exceptions as api_exceptions

    def _parse_iso_date(s: str | None) -> datetime.datetime | None:
        if not s:
            return None
        if isinstance(s, datetime.datetime):
            return s
        if isinstance(s, datetime.date):
            return datetime.datetime.combine(s, datetime.time.min)
        try:
            return datetime.datetime.fromisoformat(s)
        except Exception:
            try:
                return datetime.datetime.strptime(s, "%Y-%m-%d")
            except Exception:
                return None

    start_dt = _parse_iso_date(start_date)
    end_dt = _parse_iso_date(end_date)

    # Postgres SoT
    try:
        import app_pg

        if app_pg.enabled():
            total = app_pg.sum_driver_completed_budget(
                str(user_id), start_dt=start_dt, end_dt=end_dt
            )
            if total is not None:
                return float(total)
    except Exception:
        logger.exception("[calculate_user_balance] PG failed, fallback Firestore")

    try:
        client = utils.init_firebase_client()
        orders_ref = client.collection('order')

        # Get driver representation (in original code get_firebase_user_by_id(user_id, True))
        driver_ref = get_firebase_user_by_id(user_id, True)

        # Normalizer date from Firestore document into datetime
        def _to_datetime(value) -> datetime.datetime | None:
            if value is None:
                return None
            if isinstance(value, datetime.datetime):
                return value
            if isinstance(value, datetime.date):
                return datetime.datetime.combine(value, datetime.time.min)
            # Firestore Timestamp-like objects may have to_datetime / ToDatetime
            if hasattr(value, "to_datetime") and callable(value.to_datetime):
                try:
                    return value.to_datetime()
                except Exception:
                    pass
            if hasattr(value, "ToDatetime") and callable(value.ToDatetime):
                try:
                    return value.ToDatetime()
                except Exception:
                    pass
            if isinstance(value, str):
                return _parse_iso_date(value)
            return None

        # Attempting to perform "optimal" request (equal + equal + range).
        # If Firestore requires index — we will catch the error and perform a safe fallback,
        # which filters data on the client.
        query_ref = orders_ref.where('selected_driver', '==', driver_ref).where('status', '==', 'completed')
        if start_dt:
            query_ref = query_ref.where('dateTime_created', '>=', start_dt)
        if end_dt:
            query_ref = query_ref.where('dateTime_created', '<=', end_dt)

        try:
            docs = list(query_ref.stream())
        except api_exceptions.FailedPrecondition as exc:
            # Composite index missing — log and perform fallback query.
            logger.warning("Firestore composite index required for query (falling back to client-side filtering): %s", exc)
            # To minimize the data volume, first request using the single equality status.
            # This is safer than pulling the entire collection.
            fallback_q = orders_ref.where('status', '==', 'completed')
            # Optionally, you can limit by date at the query level, but this may also require an index.
            # Thus, only using status and filtering date and driver on the client.
            docs = list(fallback_q.stream())

        total_balance = 0.0
        for doc in docs:
            data = doc.to_dict() or {}

            # Checking the selected driver — several formats are possible:
            # - DocumentReference (compare directly)
            # - string id
            selected = data.get('selected_driver')
            matches_driver = False
            try:
                if selected is None:
                    matches_driver = False
                elif selected == driver_ref:
                    matches_driver = True
                elif isinstance(selected, str):
                    # comparing with id
                    matches_driver = selected == user_id
                else:
                    # other possible representations (object with id/path)
                    sel_id = getattr(selected, 'id', None) or getattr(selected, 'document_id', None) or getattr(selected, 'path', None)
                    drv_id = getattr(driver_ref, 'id', None) or getattr(driver_ref, 'document_id', None) or getattr(driver_ref, 'path', None)
                    matches_driver = bool(sel_id and drv_id and sel_id == drv_id) or (sel_id == user_id)
            except Exception:
                matches_driver = False

            if not matches_driver:
                continue

            # Checking document date
            doc_dt = _to_datetime(data.get('dateTime_created'))
            if start_dt and (doc_dt is None or doc_dt < start_dt):
                continue
            if end_dt and (doc_dt is None or doc_dt > end_dt):
                continue

            budget_val = data.get('budget', 0) or 0
            try:
                total_balance += float(budget_val)
            except Exception:
                # if budget is not convertible to a number — log and skip
                logger.debug("Cannot convert budget to float for document %s: %r", doc.id, budget_val)
                continue

        return float(total_balance)

    except Exception as e:
        logger.error("Error in calculate_user_balance: %s", str(e))
        logger.error("Error source:\n%s", traceback.format_exc())
        # If Firestore returned a link to create an index — include it in the message
        if isinstance(e, api_exceptions.FailedPrecondition) and hasattr(e, 'message'):
            raise IncorrectDataValue(f'Error calculating user balance: {e.message}')
        raise IncorrectDataValue(f'Error calculating user balance: {e}')


def get_firebase_user_by_id(user_id: str, is_reference: bool = False) -> dict:
    """
    Retrieve a user by ID.

    Сначала Postgres (зеркало), при отсутствии — Firestore.
    is_reference=True всегда Firestore DocumentReference (нужно для записей FS).
    """
    try:
        if not is_reference:
            try:
                import app_pg
                pg_user = app_pg.get_user(user_id)
                if pg_user:
                    return pg_user
            except Exception:
                logger.exception("[users.get_firebase_user_by_id] app_pg read failed id=%s", user_id)

        client = utils.init_firebase_client()
        user_ref = client.collection('users').document(user_id)
        user_doc = user_ref.get()

        if user_doc.exists:
            if is_reference:
                return  user_ref
            return firebase_user_to_json(user_doc)
        else:
            return {}
    except Exception as e:
        raise IncorrectDataValue(f'Error retrieving user with ID {user_id}: {e}')

def _parse_number(value, field_name: str = 'value'):
    """Принимает int/float/str с точкой или запятой; пустое → None."""
    if value is None or value == 'None':
        return None
    if isinstance(value, bool):
        raise IncorrectDataValue(f'Invalid {field_name}: {value!r}')
    if isinstance(value, (int, float)):
        return float(value)
    s = str(value).strip().replace(',', '.').replace(' ', '')
    if s == '':
        return None
    try:
        return float(s)
    except (ValueError, TypeError):
        raise IncorrectDataValue(f'Invalid {field_name}: {value!r}')


def update_firebase_user(user_id: str, display_name: str, photo_url: str | None, is_driver: bool, is_blocked: bool, block_comment: str | None, phone_number: str | None, verif_ne_proidena: bool | None, balance, commission, verif_compl: bool | None, on_verif_now: bool | None, bonus_balance=None) -> None:
    """
    Update user data. Postgres is Source of Truth; Firestore only via soft_fs (APP_FS_MIRROR).

    :param user_id: User ID.
    :param display_name: New user name.
    :param photo_url: New UUID of user photo or None.
    :param is_driver: New driver status.
    :param bonus_balance: Delta to apply to bonus_balance (e.g. +200 to credit, -50 to debit).
        Bonus balance is for write-offs only — never withdrawn via payout.
    """
    try:
        import app_fs_mirror
        import app_pg
        from firebase_admin import firestore

        pg_fields = {}

        if display_name is not None:
            pg_fields['display_name'] = display_name

        if photo_url is not None:
            pg_fields['photo_url'] = photo_url

        if is_driver is not None:
            pg_fields['is_driver'] = is_driver

        if is_blocked is not None:
            pg_fields['is_blocked'] = is_blocked

        if block_comment is not None:
            pg_fields['block_comment'] = block_comment

        if phone_number is not None:
            pg_fields['phone_number'] = phone_number

        if verif_ne_proidena is not None:
            pg_fields['verif_ne_proidena'] = verif_ne_proidena

        if verif_compl is not None:
            pg_fields['verif_compl'] = verif_compl

        if on_verif_now is not None:
            pg_fields['on_verif_now'] = on_verif_now

        balance_num = _parse_number(balance, 'balance')
        if balance_num is not None:
            # Дробные балансы (напр. -9031.7) — не приводить к int().
            pg_fields['balance'] = balance_num

        commission_num = _parse_number(commission, 'commission')
        if commission_num is not None:
            pg_fields['commission_percent'] = commission_num

        bonus_delta = None
        if bonus_balance is not None and bonus_balance != 'None' and str(bonus_balance).strip() != '':
            try:
                bonus_delta = _parse_number(bonus_balance, 'bonus_balance')
                if bonus_delta is None:
                    bonus_delta = 0.0
            except IncorrectDataValue:
                logger.error(f"[users.update_firebase_user] invalid bonus_balance delta={bonus_balance!r} user_id={user_id}")
                raise
            if bonus_delta != 0:
                logger.info(f"[users.update_firebase_user] bonus_balance delta={bonus_delta} user_id={user_id}")

        # Postgres SoT first
        if pg_fields:
            if not app_pg.mirror_user_fields(user_id, pg_fields):
                raise IncorrectDataValue(f'Error updating user with ID {user_id}: postgres update failed')
        if bonus_delta:
            if not app_pg.increment_user_bonus(user_id, float(bonus_delta)):
                raise IncorrectDataValue(f'Error updating user with ID {user_id}: postgres bonus update failed')

        def _fs():
            client = utils.init_firebase_client()
            user_ref = client.collection('users').document(user_id)
            if pg_fields:
                user_ref.update(pg_fields)
            if bonus_delta:
                user_ref.update({
                    'bonus_balance': firestore.Increment(bonus_delta),
                })

        app_fs_mirror.soft_fs("update_firebase_user", _fs)
    except IncorrectDataValue:
        raise
    except Exception as e:
        logger.error(f"[users.update_firebase_user] error user_id={user_id}: {e}")
        raise IncorrectDataValue(f'Error updating user with ID {user_id}: {e}')



def firebase_user_to_json(doc, is_dict_already: bool = False):
    if doc is None:
        return None

    # Получаем данные документа (словарь) либо используем переданный словарь
    data = doc if is_dict_already else (doc.to_dict() or {})

    # Если передан DocumentSnapshot, подтягиваем fcm_tokens из подколлекции
    if not is_dict_already:
        fcm_tokens = []
        try:
            # doc должен иметь атрибут reference (DocumentReference)
            doc_ref = getattr(doc, 'reference', None)
            if doc_ref is not None:
                for token_doc in doc_ref.collection('fcm_tokens').stream():
                    token_data = token_doc.to_dict() or {}
                    token_value = token_data.get('fcm_token')
                    if token_value:
                        fcm_tokens.append(token_value)
        except Exception:
            # В случае ошибки чтения подколлекции оставляем пустой список
            fcm_tokens = []
        data['fcm_tokens'] = fcm_tokens

    value = {
        'id': doc.id if not is_dict_already else data.get('id'),
        'admin': data.get('admin'),
        'email': data.get('email'),
        'display_name': data.get('display_name'),
        'is_driver': data.get('is_driver'),
        'login_complete': data.get('login_complete'),
        'created_time': data.get('created_time'),
        'fcm_tokens': data.get('fcm_tokens', []),
        'photo_url': data.get('photo_url'),
        'phone_number': data.get('phone_number'),
        'verif_ne_proidena': data.get('verif_ne_proidena'),
        'on_verif_now': data.get('on_verif_now'),
        'verif_compl': data.get('verif_compl'),
        'balance': data.get('balance'),
        'bonus_balance': data.get('bonus_balance', 0),
        'commission': data.get('commission_percent'),
        'fb_id': data.get('fb_id')
    }

    if data.get('is_blocked') is not None:
        value['is_blocked'] = data.get('is_blocked')
        value['block_comment'] = data.get('block_comment')

    return value
def get_monthly_user_statistics(user_id: str, month: str) -> dict:
    """
    Retrieve user statistics for the month.

    :param user_id: User ID for statistical calculation.
    :param month: Month in format 'YYYY-MM'.
    :return: Dictionary with balance, last deposit/withdrawal date, and order statistics.
    """
    try:
        from datetime import datetime, timedelta, timezone
        import calendar

        def _parse_doc_datetime(value):
            """Try to convert dateTime_created value to datetime."""
            if value is None:
                return None
            # Already datetime
            if isinstance(value, datetime):
                return value
            # Firestore Timestamp: attempt to use ToDatetime / to_datetime / to_pydatetime method
            for attr in ("ToDatetime", "to_datetime", "to_pydatetime", "ToPydatetime"):
                meth = getattr(value, attr, None)
                if callable(meth):
                    try:
                        return meth()
                    except Exception:
                        pass
            # protobuf Timestamp-like with seconds / nanos
            if hasattr(value, "seconds"):
                try:
                    secs = int(getattr(value, "seconds"))
                    nanos = int(getattr(value, "nanos", 0))
                    return datetime.fromtimestamp(secs, tz=timezone.utc) + timedelta(microseconds=nanos // 1000)
                except Exception:
                    pass
            # numeric unix timestamp
            if isinstance(value, (int, float)):
                try:
                    return datetime.fromtimestamp(value, tz=timezone.utc)
                except Exception:
                    pass
            # ISO / common string formats
            if isinstance(value, str):
                for fmt in ("%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d"):
                    try:
                        dt = datetime.fromisoformat(value) if fmt == "%Y-%m-%dT%H:%M:%S" else datetime.strptime(value, fmt)
                        # If no tz info, assume UTC for consistent comparison
                        return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
                    except Exception:
                        continue
                # last resort: try fromisoformat without specifying format
                try:
                    dt = datetime.fromisoformat(value)
                    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
                except Exception:
                    pass
            return None

        # Parsing the month and finding boundaries
        try:
            year, mon = map(int, month.split("-"))
            start_dt = datetime(year, mon, 1, 0, 0, 0, tzinfo=timezone.utc)
            last_day = calendar.monthrange(year, mon)[1]
            end_dt = datetime(year, mon, last_day, 23, 59, 59, 999999, tzinfo=timezone.utc)
        except Exception as ex:
            raise IncorrectDataValue(f"Invalid month format: {month}. Expected 'YYYY-MM'. {ex}")

        # Postgres SoT
        try:
            import app_pg

            if app_pg.enabled():
                stats = app_pg.driver_order_stats(
                    str(user_id), month_start=start_dt, month_end=end_dt
                )
                if stats is not None:
                    return {
                        "monthly_balance": stats.get("monthly_balance", 0),
                        "last_transaction_date": stats.get("last_transaction_date"),
                        "total_orders": stats.get("total_orders", 0),
                        "completed_orders": stats.get("completed_orders", 0),
                    }
        except Exception:
            logger.exception("[get_monthly_user_statistics] PG failed, fallback Firestore")

        client = utils.init_firebase_client()
        orders_ref = client.collection("order")

        # Get reference to user once
        user_ref = get_firebase_user_by_id(user_id, True)

        # Retrieve all orders of the selected driver (without range in the request, so as not to require composite index)
        base_query = orders_ref.where("selected_driver", "==", user_ref)

        # completed orders (using equality filters — they do not require composite index)
        completed_query = base_query.where("status", "==", "completed")
        completed_docs = list(completed_query.stream())

        # For monthly statistics, filter by dates on the client to avoid a query that requires an index
        monthly_docs = []
        for doc in base_query.stream():
            data = doc.to_dict()
            dt_raw = data.get("dateTime_created")
            dt = _parse_doc_datetime(dt_raw)
            if dt is None:
                # If date could not be recognized — skip document
                continue
            # Normalize timezone for correct comparison
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            if start_dt <= dt <= end_dt:
                monthly_docs.append(doc)

        # Counting: balance summed up from completed orders
        total_balance = sum((doc.to_dict().get("budget", 0) or 0) for doc in completed_docs)

        # Last transaction date — from completed orders
        last_dates = []
        for doc in completed_docs:
            dt_raw = doc.to_dict().get("dateTime_created")
            dt = _parse_doc_datetime(dt_raw)
            if dt is not None:
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=timezone.utc)
                last_dates.append(dt)
        last_transaction_date = max(last_dates).isoformat() if last_dates else None

        monthly_orders_len = len(monthly_docs)
        completed_orders_len = len(completed_docs)
        return {
            "monthly_balance": total_balance,
            "last_transaction_date": last_transaction_date,
            "total_orders": monthly_orders_len,
            "completed_orders": completed_orders_len,
        }

    except IncorrectDataValue:
        # Propagate our correct errors further without logging here
        raise
    except Exception as e:
        raise IncorrectDataValue(f"Error retrieving user statistics: {e}")


def get_driver_verification_data(driver_id):
    """
    Retrieve driver's verification data (Postgres SoT, FS fallback).
    """
    try:
        import app_verifications_ops

        row = app_verifications_ops.get_for_driver(str(driver_id))
        if row:
            return json.loads(
                json.dumps(row, ensure_ascii=False, default=utils.json_serial)
            )
    except Exception as e:
        print(f"[get_driver_verification_data] PG failed: {e}")

    try:
        client = utils.init_firebase_client()
        driver = get_firebase_user_by_id(driver_id, is_reference=True)
        verification_ref = client.collection('request_verefication')
        verification_ref = verification_ref.where("user", "==", driver)
        verification_docs = verification_ref.stream()

        verification_data = []
        for doc in verification_docs:
            data = doc.to_dict() or {}

            data['id'] = doc.id  # Add document ID
            data['user'] = driver_id
            if data.get('dateCreated') is not None and isinstance(data['dateCreated'], DatetimeWithNanoseconds):
                date_created: DatetimeWithNanoseconds = data['dateCreated']
                data['dateCreated'] = date_created.date().isoformat()
            if data.get('dfb') is not None and isinstance(data['dfb'], DatetimeWithNanoseconds):
                dfb_date: DatetimeWithNanoseconds = data['dfb']
                data['dfb'] = dfb_date.date().isoformat()

            verification_data.append(data)

        if not verification_data:
            return None
        # prefer onVerif if present
        on = [x for x in verification_data if x.get('status') == 'onVerif']
        pick = on[0] if on else verification_data[0]
        return json.loads(json.dumps(pick, ensure_ascii=False, default=utils.json_serial))

    except Exception as e:
        print(str(e))
        return None


def update_driver_verification_data(driver_id, update_fields):
    """
    Update driver's verification (Postgres SoT + soft FS by doc id).
    """
    try:
        import app_verifications_ops

        fields = dict(update_fields or {})
        fields['user_id'] = str(driver_id)
        app_verifications_ops.upsert_from_admin(str(driver_id), fields)
        return
    except Exception as e:
        raise IncorrectDataValue(f'Error updating driver verification data: {e}')

def send_message (user_id, message):
    with Session() as session:
        users = session.query(FirebaseUser).filter(FirebaseUser.user_id == user_id).all()
    if len(users) < 1:
        raise IncorrectDataValue(f'Пользователь не найден')
    user = users[0]
    if user.fcm_token is None:
      raise  IncorrectDataValue(f'Пользователь не может получить сообщение')
    try:
        print(user.fcm_token)
        notify.push_service.send_push_notification(fcm_tokens=[user.fcm_token], title='Cab Drive', message=message)
    except Exception as e:
        logger.error(str(e))


def check_driver_inn(inn: str, timeout: int = 10) -> Dict[str, Any]:
    """
    Отправляет запрос к https://statusnpd.nalog.ru/api/v1/tracker/taxpayer_status
    с указанным INN и текущей датой.

    Args:
        inn: ИНН (строка из цифр, длина 10 или 12).
        timeout: таймаут запроса в секундах.

    Returns:
        Словарь с ключами:
        - success: bool
        - status_code: int | None
        - data: распарсенный JSON (если success)
        - error: текст ошибки (если не success)
        - raw_response: ответ сервера (если не удалось распарсить JSON)
    Raises:
        ValueError: при неверном формате inn.
    """
    # Валидация ИНН (простейшая: цифры и длина 10 или 12)
    if not inn.isdigit() or len(inn) not in (10, 12):
        raise ValueError("ИНН должен содержать только цифры и иметь длину 10 или 12 символов")

    url = "https://statusnpd.nalog.ru/api/v1/tracker/taxpayer_status"
    request_date = datetime.date.today().isoformat()  # 'YYYY-MM-DD'

    payload = {"inn": inn, "requestDate": request_date}
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "python-requests/3.x (check_driver_inn)",
    }

    try:
        resp = requests.post(url, json=payload, headers=headers, timeout=timeout)
    except requests.RequestException as exc:
        return {
            "success": False,
            "status_code": None,
            "error": f"Network error: {exc}",
        }

    result: Dict[str, Any] = {"status_code": resp.status_code}

    try:
        body = resp.json()
    except ValueError:
        # Не JSON в ответе
        result.update(
            {
                "success": False,
                "error": "Response is not valid JSON",
                "raw_response": resp.text,
            }
        )
        return result

    if resp.ok:
        result.update({"success": True, "data": body})
    else:
        # Возвратим тело ответа если есть (обычно содержит описание ошибки)
        result.update({"success": False, "error": "HTTP error", "data": body})

    return result


def send_push_to_firebase_users(user_ids: List[str], title: str, text: str, data: dict = None) -> Dict[str, Any]:
    """
    Отправляет push по firebase_id.
    Токены: Postgres app_user_fcm_tokens (primary), FS fcm_tokens как fallback.
    """
    try:
        import app_fcm_ops

        page = None
        pdata = None
        if isinstance(data, dict):
            page = data.get("initialPageName")
            pdata = data.get("parameterData")
        return app_fcm_ops.send_to_users(
            list(user_ids or []),
            title=title or "",
            body=text or "",
            data=data if isinstance(data, dict) else None,
            initial_page_name=page,
            parameter_data=pdata,
        )
    except Exception:
        logger.exception(
            "[send_push_to_firebase_users] app_fcm_ops failed, legacy FS path"
        )

    logger.info(f"[send_push_to_firebase_users] Starting for {len(user_ids)} users")
    logger.info(f"[send_push_to_firebase_users] user_ids: {user_ids}")

    client = utils.init_firebase_client()

    # Собираем токены и их references для удаления невалидных
    tokens = []
    token_refs = {}  # token -> document reference

    for user_id in user_ids:
        user_ref = client.collection('users').document(user_id)
        fcm_tokens_ref = user_ref.collection('fcm_tokens')
        token_docs = fcm_tokens_ref.get()

        logger.info(f"[send_push_to_firebase_users] User {user_id}: found {len(token_docs)} token docs")

        for token_doc in token_docs:
            token_data = token_doc.to_dict()
            fcm_token = token_data.get('fcm_token')
            if fcm_token:
                tokens.append(fcm_token)
                token_refs[fcm_token] = token_doc.reference
                logger.info(f"[send_push_to_firebase_users] Added token: {fcm_token[:20]}...")

    if not tokens:
        logger.warning("[send_push_to_firebase_users] No FCM tokens found")
        return {
            "success": False,
            "error": "No FCM tokens found for specified users",
            "success_count": 0,
            "failure_count": 0,
            "tokens_cleaned": 0
        }

    logger.info(f"[send_push_to_firebase_users] Total tokens to send: {len(tokens)}")

    # Отправляем push
    result = notify.push_service.send_push_notification(
        fcm_tokens=tokens,
        title=title,
        message=text,
        data=data
    )

    logger.info(f"[send_push_to_firebase_users] Push result: {result}")

    # Удаляем невалидные токены
    tokens_cleaned = 0
    failed_tokens = result.get('failed_tokens', [])

    for failed_token in failed_tokens:
        if failed_token in token_refs:
            try:
                token_refs[failed_token].delete()
                tokens_cleaned += 1
                logger.info(f"[send_push_to_firebase_users] Deleted invalid token: {failed_token[:20]}...")
            except Exception as e:
                logger.error(f"[send_push_to_firebase_users] Error deleting token: {e}")

    result['tokens_cleaned'] = tokens_cleaned
    result['success'] = result.get('success_count', 0) > 0 or len(tokens) == 0

    logger.info(f"[send_push_to_firebase_users] Completed. Sent: {result.get('success_count', 0)}, Failed: {result.get('failure_count', 0)}, Cleaned: {tokens_cleaned}")

    return result