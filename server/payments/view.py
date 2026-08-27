from flask_jwt_extended import jwt_required
from flask_openapi3 import Tag, APIView
from drivers.entities import Driver
from .models import *
from decorators import *
from errors import *
import utils
import payments
import traceback
import settings


tag = Tag(name='Payments', description='Платежи')
app = APIView(url_prefix='/kek/payments', view_tags=[tag])
security = [{"jwt": []}]


@app.route('/driver/create')
class CreateDriverPayment:
    @app.doc(
        summary='[Role=Driver] Создание платежа на оплату подписки',
        responses={
            '200': CreateDriverPaymentModel,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def get(self, driver_id: int, query: CreateDriverPaymentRequest):
        try:
            payment = payments.api.create_payment(driver_id, query.tariff_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'payment': payment}
        )


@app.route('/driver/tariffs')
class GetDriverTariffsView:
    @app.doc(
        summary='[Role=Driver] Получение тарифов для оплаты',
        responses={
            '200': GetDriversTariffsModel,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def get(self, driver_id: int):
        try:
            model = settings.get_model()
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'tariffs': [tariff.model_dump() for tariff in model.driver_tariffs]}
        )