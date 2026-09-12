from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
from .models import *
import traceback
import utils
import settings
import config
from logger import logger


app = blueprints.Blueprint('settings', __name__, url_prefix='/kek/settings')


@app.route('/get', methods=['GET'])
def get_public_settings():
    """Публичные настройки для мобильного клиента (без авторизации):
    тайминги авто-отмены и авто-архивации заказов."""
    model = settings.get_model()
    return utils.get_answer('ok', info={
        'minutes_for_delete_order': model.minutes_for_delete_order,
        'deadline_minutes': model.deadline_minutes,
    })


@app.route('/edit_minutes', methods=['POST'])
def edit_minutes():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json
    print(data)

    model = settings.get_model()


    try:
        model.minutes_for_delete_order = data['minutes']
        print(data)
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        settings.update_model(model)
    except IncorrectDataValue as e:
        print(traceback.format_exc())
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')


@app.route('/edit_deadlines', methods=['POST'])
def edit_deadline():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json
    print(data)

    model = settings.get_model()


    try:
        model.deadline_minutes = data['minutes']
        print(data)
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        settings.update_model(model)
    except IncorrectDataValue as e:
        print(traceback.format_exc())
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')

@app.route('/edit', methods=['POST'])
def edit_settings():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        model = SiteModel.model_validate(data)
        print(data)
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        settings.update_model(model)
    except IncorrectDataValue as e:
        print(traceback.format_exc())
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')


@app.route('/tinkoff', methods=['GET', 'POST'])
def tinkoff_settings():
    """GET — текущие настройки; POST — сохранить (только суперадмин)."""
    user = utils.require_super_admin()
    if user is None:
        return abort(403)

    if request.method == 'GET':
        model = settings.get_model()
        cfg = config.Production
        return utils.get_answer('ok', info={
            'mode': model.tinkoff_mode or 'test',
            'payments_base_url': model.payments_base_url or 'https://cab.artean.ru',
            'test_keys_set': bool(
                getattr(cfg, 'TINKOFF_TEST_TERMINAL_KEY', None)
                or getattr(cfg, 'TINKOFF_TERMINAL_KEY', None)
            ),
            'prod_keys_set': bool(getattr(cfg, 'TINKOFF_PROD_TERMINAL_KEY', None)),
        })

    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return utils.get_error("Ожидался JSON body", status=200)
    mode = data.get("mode")
    payments_base_url = data.get("payments_base_url")
    if mode is None and payments_base_url is None:
        return utils.get_error("Укажите mode и/или payments_base_url", status=200)
    try:
        model = settings.update_tinkoff_settings(
            mode=mode,
            payments_base_url=payments_base_url,
        )
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        logger.exception("[settings.tinkoff] save failed")
        return utils.get_error(str(e), status=200)

    return utils.get_answer(
        "Сохранено",
        info={
            "mode": model.tinkoff_mode or "test",
            "payments_base_url": model.payments_base_url or "https://cab.artean.ru",
        },
    )


@app.route('/polygons', methods=['POST'])
def polygons_settings():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        polygons = []
        for arr in data:
            polygons.append(Area(coords=arr['coords']))
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        settings.update_polygons(polygons)
    except IncorrectDataValue as e:
        print(traceback.format_exc())
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')


@app.route('/cities', methods=['POST'])
def cities_settings():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        polygons = []
        for arr in data:
            polygons.append(Area(coords=arr['coords']))
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        settings.update_cities(polygons)
    except IncorrectDataValue as e:
        print(traceback.format_exc())
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')