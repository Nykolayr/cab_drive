from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
from .models import *
import traceback
import utils
import json
import drivers

app = blueprints.Blueprint('drivers', __name__, url_prefix='/api/drivers')


@app.route('/create', methods=['POST'])
def create_driver_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        model = CreateDriverModel.model_validate(data)
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        driver = drivers.api.create_driver(model)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Водитель успешно добавлен', {'driver': driver})


@app.route('/edit', methods=['POST'])
def edit_driver_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        model = EditDriverModel.model_validate(data)
    except:
        print(traceback.format_exc())
        return utils.get_error('Заполните все поля', status=200)

    try:
        drivers.api.edit_driver(model)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Водитель успешно сохранён')


@app.route('/remove', methods=['POST'])
def remove_driver_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    driver_id = request.values.get('id', 0, int)

    try:
        drivers.api.remove_driver(driver_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Водитель успешно удалён')


@app.route('/tariffs', methods=['POST'])
def save_tariffs_driver_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        tariffs_dict = data['tariffs']
        driver_id = int(data['id'])
    except:
        print(traceback.format_exc())
        return utils.get_error('Ошибка валидации', status=200)

    try:
        drivers.api.save_tariffs(driver_id, tariffs_dict)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Тарифы сохранены')


@app.route('/docs', methods=['POST'])
def save_docs_driver_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        docs = [DriverDoc.model_validate(d) for d in data['docs']]
        driver_id = int(data['id'])
    except:
        print(traceback.format_exc())
        return utils.get_error('Ошибка валидации', status=200)

    try:
        drivers.api.save_docs(driver_id, docs)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Документы сохранены')