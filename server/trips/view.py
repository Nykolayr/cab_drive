from flask_jwt_extended import jwt_required
from flask_openapi3 import Tag, APIView
from models import PointModel
from .models import *
from errors import *
from decorators import *
import utils
import trips
import traceback
import geo


tag = Tag(name='Trips', description='Поездки')
app = APIView(url_prefix='/kek/trips', view_tags=[tag], view_responses={
    '401': models.ErrorAnswer
})
security = [{"jwt": []}]


@app.route('/calculation')
class CalculationTripAPI:
    @app.doc(
        summary='[Role=User] Расчёт стоимости поездки',
        description='Данный метод возвращает расчёт стоимости поездки. Необходимо сохранять токен расчёта, так как по нему будет создаваться заказ. Срок жизни расчёта - одна минута.',
        responses={
            '200': CalculationTripResponse,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: CalculateTripRequest, user_id: int):
        if geo.api.check_point(body.start_point) is False:
            return utils.get_error('Сервис не работает в этом месте', 451)

        try:
            calculations_list = trips.api.calculate_trip(body)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'calculations': [res.model_dump() for res in calculations_list]}
        )


@app.route('/create')
class CreateTripAPI:
    @app.doc(
        summary='[Role=User] Создание поездки',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: CreateTripRequest, user_id: int):
        try:
            trip = trips.api.create_trip(user_id, body)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trip': trip}
        )


@app.route('/get/active')
class GetActiveTripAPI:
    @app.doc(
        summary='[Role=Any] Получение текущего активного заказа',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('any')
    def get(self, user_id: int | None, driver_id: int | None):
        try:
            trip = trips.api.get_active_trip(user_id, driver_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trip': trip}
        )


@app.route('/cancel')
class CancelTripAPI:
    @app.doc(
        summary='[Role=Any] Отмена заказа',
        description='Метод отмены заказа<br>Для клиента:<br>- отменить заказ можно до статуса посадки в машину<br><br>Для водителя:<br>- отменить заказ можно до статуса посадки клиента в машину<br>- метод для отказа от принятия заказа',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('any')
    def post(self, user_id: int | None, driver_id: int | None, query: CancelTripRequest):
        try:
            trip = trips.api.cancel_trip(query.trip_id, user_id, driver_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trip': trip}
        )


@app.route('/accept')
class AcceptTripAPI:
    @app.doc(
        summary='[Role=Driver] Принять заказ',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int | None, query: AcceptTripRequest):
        try:
            trip = trips.api.accept_trip(driver_id, query.trip_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trip': trip}
        )


@app.route('/status/next')
class NextTripStatusAPI:
    @app.doc(
        summary='[Role=Driver] Изменение статуса заказа',
        description='Данный метод переводит заказ на следующий статус<br>- ожидание клиента<br>- начало поездки<br>- конец поездки',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int | None, query: NextStatusTripRequest):
        try:
            trip = trips.api.next_status_trip(driver_id, query.trip_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trip': trip}
        )


@app.route('/rating')
class SetRatingTripAPI:
    @app.doc(
        summary='[Role=User] Оставить оценку к завершенной поездке',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, user_id: int | None, query: SendScoreRequest):
        try:
            trip = trips.api.set_score(user_id, query.trip_id, query.rating)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trip': trip}
        )


@app.route('/list')
class GetTripsListView:
    @app.doc(
        summary='[Role=Any] Получить историю поездок',
        responses={
            '200': GetTripsListResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('any')
    def post(self, user_id: int | None = None, driver_id: int = None):
        try:
            if driver_id:
                trips_list = trips.api.get_trips_by_driver_id(driver_id)
            if user_id:
                trips_list = trips.api.get_trips_by_user_id(user_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'trips': trips_list}
        )


@app.route('/waiting/start')
class StartWaitingTripAPI:
    @app.doc(
        summary='[Role=Driver] Включение платного ожидания',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int | None, query: StartWaitingTripRequest):
        try:
            trip = trips.api.start_waiting(driver_id, query.trip_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            'Платное ожидание запущено',
            {'trip': trip}
        )


@app.route('/waiting/stop')
class StopWaitingTripAPI:
    @app.doc(
        summary='[Role=Driver] Выключение платного ожидания',
        responses={
            '200': GetTripResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('driver')
    def post(self, driver_id: int | None, query: StopWaitingTripRequest):
        try:
            trip = trips.api.stop_waiting(driver_id, query.trip_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            'Платное ожидание остановлено',
            {'trip': trip}
        )