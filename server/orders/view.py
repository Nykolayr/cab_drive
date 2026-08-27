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
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayUnion

        order_id = body.order_id
        driver_uid = body.driver_uid
        logger.info(
            f"[extra_accept] entry driver_uid={driver_uid} order_id={order_id}"
        )

        try:
            model = settings.get_model()
            max_queue = model.driver_max_queue_size
            db = firestore.client()
            order_ref = db.collection('order').document(order_id)
            user_ref = db.collection('users').document(driver_uid)

            transaction = db.transaction()

            @firestore.transactional
            def _accept(tx) -> dict:
                order_snap = order_ref.get(transaction=tx)
                if not order_snap.exists:
                    raise IncorrectDataValue('Заказ не найден')
                order_data = order_snap.to_dict() or {}
                status_now = (order_data.get('status') or '').lower()
                if status_now != 'neworder':
                    logger.info(
                        f"[extra_accept] race: order {order_id} already taken "
                        f"(status={status_now})"
                    )
                    raise IncorrectDataValue('Заказ уже принят другим водителем')

                user_snap = user_ref.get(transaction=tx)
                if not user_snap.exists:
                    raise IncorrectDataValue('Водитель не найден')
                user_data = user_snap.to_dict() or {}
                queue = list(user_data.get('active_orders_queue') or [])
                if len(queue) >= max_queue:
                    logger.info(
                        f"[extra_accept] queue_full uid={driver_uid} size={len(queue)}"
                    )
                    raise IncorrectDataValue('Очередь заказов переполнена')

                from datetime import datetime, timezone
                now = datetime.now(timezone.utc)
                tx.update(order_ref, {
                    'status': 'spec_set',
                    'selected_driver': user_ref,
                    'date_upd': now,
                })
                tx.update(user_ref, {
                    'active_orders_queue': ArrayUnion([order_ref]),
                })
                return {
                    'order_id': order_id,
                    'queue_size': len(queue) + 1,
                }

            result = _accept(transaction)
            logger.info(
                f"[extra_accept] success driver_uid={driver_uid} order_id={order_id} "
                f"queue_size={result['queue_size']}"
            )
            return utils.get_answer('', {'extra': result})

        except IncorrectDataValue as e:
            logger.warning(f"[extra_accept] rejected: {e.message}")
            return utils.get_error(e.message, status=409)
        except Exception as e:
            logger.error(
                f"[extra_accept] uncaught: {e}\n{traceback.format_exc()}"
            )
            return utils.get_error(str(e), status=500)

