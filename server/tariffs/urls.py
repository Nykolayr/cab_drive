from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
import utils
import json
import tariffs

app = blueprints.Blueprint('tariffs', __name__, url_prefix='/api/tariffs')


@app.route('/create', methods=['POST'])
def create_tariff_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    name = request.values.get('name', '', str)
    icon_uuid = request.values.get('icon_uuid', '', str)
    base_distance = request.values.get('base_distance', 0.0, float)
    base_cost = request.values.get('base_cost', 0.0, float)
    base_distance_night = request.values.get('base_distance_night', 0.0, float)
    base_cost_night = request.values.get('base_cost_night', 0.0, float)
    cost_day = request.values.get('cost_day', 0.0, float)
    cost_night = request.values.get('cost_night', 0.0, float)
    cost_city_day = request.values.get('cost_city_day', 0.0, float)
    cost_city_night = request.values.get('cost_city_night', 0.0, float)
    free_waiting = request.values.get('free_waiting', 0, int)
    cost_waiting = request.values.get('cost_waiting', 0, int)

    try:
        tariffs.api.create_tariff(name, icon_uuid, base_distance, base_cost, cost_day, cost_night, cost_city_day, cost_city_night,
                                  free_waiting, cost_waiting, base_distance_night, base_cost_night)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Тариф успешно добавлен')


@app.route('/edit', methods=['POST'])
def edit_tariff_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    tariff_id = request.values.get('id', 0, int)
    name = request.values.get('name', '', str)
    icon_uuid = request.values.get('icon_uuid', '', str)
    base_distance = request.values.get('base_distance', 0.0, float)
    base_cost = request.values.get('base_cost', 0.0, float)
    base_distance_night = request.values.get('base_distance_night', 0.0, float)
    base_cost_night = request.values.get('base_cost_night', 0.0, float)
    cost_day = request.values.get('cost_day', 0.0, float)
    cost_night = request.values.get('cost_night', 0.0, float)
    cost_city_day = request.values.get('cost_city_day', 0.0, float)
    cost_city_night = request.values.get('cost_city_night', 0.0, float)
    free_waiting = request.values.get('free_waiting', 0, int)
    cost_waiting = request.values.get('cost_waiting', 0, int)

    try:
        tariffs.api.edit_tariff(tariff_id, name, icon_uuid, base_distance, base_cost, cost_day, cost_night, cost_city_day, cost_city_night,
                                free_waiting, cost_waiting, base_distance_night, base_cost_night)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Тариф успешно сохранён')


@app.route('/remove', methods=['POST'])
def remove_tariff_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    tariff_id = request.values.get('id', 0, int)

    try:
        tariffs.api.remove_tariff(tariff_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Тариф успешно удалён')


@app.route('/indexes', methods=['POST'])
def indexes_tariffs_view():
    user = utils.get_user()
    if user is None:
        return abort(401)

    data = request.json

    try:
        ids = data.get('ids', [])
    except:
        return utils.get_error('Ошибка валидации', status=200)

    try:
        tariffs.api.update_indexes(ids)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')