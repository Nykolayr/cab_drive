from flask_jwt_extended import jwt_required
from flask_openapi3 import Tag, APIView
from drivers.entities import Driver
from .models import *
from decorators import *
from errors import *
import utils
import drivers
import traceback


tag = Tag(name='Drivers', description='Водители')
app = APIView(url_prefix='/kek/drivers', view_tags=[tag])
security = [{"jwt": []}]


@app.route('/auth')
class AuthDriverView:
    @app.doc(
        summary='Авторизация',
        responses={
            '200': AuthDriverResponse,
            '500': models.ErrorAnswer
        },
        security=None
    )
    def post(self, form: AuthDriverRequest):
        try:
            driver, access_token = drivers.api.api_auth(form)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver, 'access_token': access_token}
        )


@app.route('/me')
class GetMeDriverView:
    @app.doc(
        summary='[Role=Driver] Получение информации о водителе',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def get(self, driver_id: int):
        try:
            driver = drivers.api.api_get_me(driver_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )


@app.route('/payment_method')
class ChangePaymentMethodDriverView:
    @app.doc(
        summary='[Role=Driver] Включение способа оплаты',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int, query: ChangePaymentMethod):
        try:
            driver = drivers.api.api_append_payment_method(driver_id, query)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )

    @app.doc(
        summary='[Role=Driver] Выключение способа оплаты',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def delete(self, driver_id: int, query: ChangePaymentMethod):
        try:
            driver = drivers.api.api_remove_payment_method(driver_id, query)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )


@app.route('/tariff')
class ChangeTariffStatusDriverView:
    @app.doc(
        summary='[Role=Driver] Включение/выключение тарифа',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int, query: ChangeTariff):
        try:
            driver = drivers.api.api_change_tariff(driver_id, query)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )


@app.route('/status')
class ChangeStatusDriverView:
    @app.doc(
        summary='[Role=Driver] Включение/выключение статуса "На линии"',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int, query: ChangeStatus):
        try:
            driver = drivers.api.api_set_status(driver_id, query.status)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )


@app.route('/position')
class UpdatePositionDriverView:
    @app.doc(
        summary='[Role=Driver] Обновление местоположения',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int, body: UpdatePosition):
        try:
            driver = drivers.api.api_update_last_position(driver_id, body)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )


@app.route('/photo')
class UpdatePhotoDriverView:
    @app.doc(
        summary='[Role=Driver] Обновление аватарки',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int, body: UpdatePhoto):
        try:
            driver = drivers.api.set_photo(driver_id, body.photo_uuid)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            'Фото успешно обновлено',
            {'driver': driver}
        )


@app.route('/fcm')
class SetFCMDriverView:
    @app.doc(
        summary='[Role=Driver] Установка FCM токена',
        responses={
            '200': GetDriverResponse,
            '500': models.ErrorAnswer,
            '401': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, body: SetFCMRequest, driver_id: int):
        try:
            driver = drivers.api.set_fcm_token(driver_id, body.fcm_token)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'driver': driver}
        )