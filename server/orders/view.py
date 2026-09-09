from flask_jwt_extended import jwt_required
from flask_openapi3 import APIView, Tag

import config
import models
import orders.pickup_api
import settings
import traceback
import utils
from decorators import role_required
from errors import IncorrectDataValue
from logger import logger
from orders.models import (
    ETAResponse,
    GetETARequest,
    PricesResponse,
    GetPricesRequest,
    ExtraAcceptRequest,
    ExtraAcceptResponse,
)

tag = Tag(name='Orders', description='Поездки')
app = APIView(url_prefix='/kek/orders', view_tags=[tag])
security = [{"jwt": []}]


@app.route('/pickup_calculate')
class PickupCalculateView:
    @app.doc(
        summary='Расчёт времени',
        responses={
            '200': ETAResponse,
            '500': models.ErrorAnswer
        },
        security=None
    )
    def post(self, body: GetETARequest):
        try:
            etas = orders.pickup_api.get_pickup_times_all_tariffs(body.user_location.lat,
                                                                  body.user_location.lng,
                                                                  config.Production.GOOGLE_API_KEY,
                                                                  10)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'etas': etas}
        )

@app.route('/route_calculate')
class RouteCalculateView:
    @app.doc(
        summary='Расчёт стоимости',
        responses={
            '200': PricesResponse,
            '500': models.ErrorAnswer
        },
        security=None
    )
    def post(self, body: GetPricesRequest):
        try:
            prices = orders.pickup_api.get_prices_all_tariffs(body.user_location.lat,
                                                                  body.user_location.lng,
                                                            body.dest_location.lat,
                                                            body.dest_location.lng,
                                                            config.Production.GOOGLE_API_KEY,
                                                              (body.intermediate_location.lat, body.intermediate_location.lng) if body.intermediate_location else None,
                                                              movers=body.movers
                                                              )
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'prices': prices}
        )


@app.route('/extra_accept')
class ExtraAcceptView:
    @app.doc(
        summary='Принятие водителем дополнительного заказа «по пути»',
        description=(
            'Транзакционно переводит newOrder в spec_set с указанным водителем '
            'и добавляет orderRef в users/{uid}.active_orders_queue. '
            'Возвращает 409 если заказ уже взят или очередь переполнена.'
        ),
        responses={
            '200': ExtraAcceptResponse,
            '409': models.ErrorAnswer,
            '500': models.ErrorAnswer,
        },
        security=None,
    )
    def post(self, body: ExtraAcceptRequest):
        order_id = body.order_id
        driver_uid = body.driver_uid
        logger.info(
            f"[extra_accept] entry driver_uid={driver_uid} order_id={order_id}"
        )

        try:
            import app_order_ops

            result = app_order_ops.extra_accept(driver_uid, order_id)
            logger.info(
                f"[extra_accept] success driver_uid={driver_uid} order_id={order_id} "
                f"queue_size={result.get('queue_size')}"
            )
            return utils.get_answer('', {'extra': result})

        except IncorrectDataValue as e:
            logger.warning(f"[extra_accept] rejected: {e.message}")
            return utils.get_error(e.message, status=409)
        except ValueError as e:
            logger.warning(f"[extra_accept] rejected: {e}")
            return utils.get_error(str(e), status=409)
        except Exception as e:
            logger.error(
                f"[extra_accept] uncaught: {e}\n{traceback.format_exc()}"
            )
            return utils.get_error(str(e), status=500)

