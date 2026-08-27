from flask import blueprints, request, render_template, session, abort, redirect, url_for, make_response

import orders
from errors import *
import json
import notify
import users
from logger import logger

app = blueprints.Blueprint('orders', __name__, url_prefix='/api/orders')


@app.route('/list')
def get_trips_table_view():
    import utils

    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)

    order_list = orders.api.fetch_firebase_orders()
    return order_list


@app.route('/export_statistics', methods=['POST'])
def export_statistics():
    import utils
    import traceback

    logger.info("=== export_statistics: начало обработки запроса ===")

    try:
        user = utils.get_user([1, 2])
        if user is None:
            logger.warning("export_statistics: пользователь не авторизован")
            return abort(401)

        logger.info(f"export_statistics: пользователь авторизован, user_id={getattr(user, 'id', 'unknown')}")

        # Логируем сырые данные запроса
        logger.info(f"export_statistics: Content-Type = {request.content_type}")
        logger.info(f"export_statistics: request.data length = {len(request.data) if request.data else 0}")

        if not request.json:
            logger.error("export_statistics: request.json пустой или None")
            logger.error(f"export_statistics: request.data = {request.data[:500] if request.data else 'empty'}")
            return abort(400)

        order_counts = request.json.get('order_counts')
        earnings = request.json.get('earnings')
        commission_earnings = request.json.get('commission_earnings')
        monthly_earnings = request.json.get('monthly_earnings')
        status_counts = request.json.get('status_counts')

        logger.info(f"export_statistics: order_counts = {order_counts}")
        logger.info(f"export_statistics: earnings = {earnings}")
        logger.info(f"export_statistics: commission_earnings = {commission_earnings}")
        logger.info(f"export_statistics: monthly_earnings = {monthly_earnings}")
        logger.info(f"export_statistics: status_counts = {status_counts}")

        logger.info("export_statistics: вызов export_order_statistics_to_excel...")
        export = orders.api.export_order_statistics_to_excel(order_counts, earnings, commission_earnings, monthly_earnings, status_counts)

        if export is None:
            logger.error("export_statistics: export_order_statistics_to_excel вернул None")
            return abort(500)

        logger.info(f"export_statistics: Excel сгенерирован, размер = {export.getbuffer().nbytes} байт")

        # Установка заголовков, чтобы браузер начал скачивание
        response = make_response(export.read())
        response.headers['Content-Disposition'] = 'attachment; filename=order_statistics.xlsx'
        response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

        logger.info("=== export_statistics: успешно завершено ===")
        return response

    except Exception as e:
        logger.error(f"export_statistics: исключение - {str(e)}")
        logger.error(f"export_statistics: traceback:\n{traceback.format_exc()}")
        return abort(500)

@app.route('/update_point', methods=['GET'])
def update_point():
    import utils

    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)

    point_key = request.args.get('point')
    point_id = request.args.get('id', type=str)
    position_data = request.args.get('position_data')
    description = request.args.get('description')
    city = request.args.get('city')

    updated_point = orders.api.update_order_point(point_id, point_key, position_data, description, city)

    return utils.get_answer('Сохранено')


@app.route('/edit', methods=['GET'])
def edit():
    import utils

    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)
    order_id = (request.args.get('order_id'))

    budget = float(request.args.get('budget'))
    currentPrice = float(request.args.get('currentPrice'))
    distance = request.args.get('distance')

    order = orders.api.edit_order(order_id, budget, distance, currentPrice)

    return utils.get_answer('Сохранено')