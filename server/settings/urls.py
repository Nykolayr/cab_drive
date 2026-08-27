from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
from .models import *
import traceback
import utils
import settings


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