from flask_jwt_extended import jwt_required
from flask_openapi3 import Tag, APIView
from models import PointModel
from .models import *
from errors import *
from decorators import *
import utils
import geo
import traceback


tag = Tag(name='Geo', description='География')
app = APIView(url_prefix='/kek/geo', view_tags=[tag], view_responses={
    '401': models.ErrorAnswer
})
security = [{"jwt": []}]


@app.route('/info_by_coords')
class GetGeoInfoAPI:
    @app.doc(
        summary='[Role=User] Получение ближайших адресов по координатам',
        responses={
            '200': GetGeoInfoResponse,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def get(self, query: PointModel, user_id: int):
        if geo.api.check_point(query) is False:
            return utils.get_error('Сервис не работает в этом месте', 451)

        try:
            result = geo.api.get_geo_info_by_two_gis(query)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'results': [res.model_dump() for res in result.results]}
        )


@app.route('/info_by_coords_2gis')
class GetGeoInfoTwoGISAPI:
    @app.doc(
        summary='[Role=User] Получение ближайших адресов по координатам [2GIS]',
        responses={
            '200': GetGeoInfoResponse,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def get(self, query: PointModel, user_id: int):
        if geo.api.check_point(query) is False:
            return utils.get_error('Сервис не работает в этом месте', 451)

        try:
            result = geo.api.get_geo_info_by_two_gis(query)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'results': [res.model_dump() for res in result.results]}
        )


@app.route('/info_by_adress')
class SuggestionAPI:
    @app.doc(
        summary='[Role=User] Получение адреса и координат по текстовому запросу',
        responses={
            '200': SuggestionResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: SuggestionRequest, user_id: int):
        try:
            result = geo.api.suggest(body.query, body.point)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'suggestions': [res.model_dump() for res in result]}
        )


@app.route('/suggest')
class YandexSuggestionAPI:
    @app.doc(
        summary='[Role=User] Получение адреса по текстовому запросу [by Yandex]',
        responses={
            '200': YSuggestionResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: YSuggestionRequest, user_id: int):
        try:
            result = geo.api.yandex_suggest(body.token, body.query, body.point)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'suggestions': [res.model_dump() for res in result]}
        )


@app.route('/suggest_2gis')
class TwoGisSuggestionAPI:
    @app.doc(
        summary='[Role=User] Получение адреса по текстовому запросу [by 2GIS]',
        responses={
            '200': YSuggestionResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: TwoGisSuggestionRequest, user_id: int):
        try:
            result = geo.api.twogis_suggest(body.query, body.point)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'suggestions': [res.model_dump() for res in result]}
        )


@app.route('/point_by_uri')
class GetPointByURIView:
    @app.doc(
        summary='[Role=User] Получение координат по URI [by Yandex]',
        responses={
            '200': GetPointByURIResponse,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def get(self, query: GetPointByURIRequest, user_id: int):
        try:
            result = geo.api.get_point_by_uri(query.uri)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            result.model_dump()
        )


@app.route('/get_pickup_time')
class GetPickupTimeAPI:
    @app.doc(
        summary='[Role=User] Получение времени подачи автомобиля',
        responses={
            '200': GetPickupTimeResponse,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: GetPickupTimeRequest, user_id: int):
        if geo.api.check_point(body.point) is False:
            return utils.get_error('Сервис не работает в этом месте', 451)

        try:
            times = geo.api.get_pickup_time(body)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'times': [res.model_dump() for res in times]}
        )


@app.route('/calculate_trip')
class CalculateTripAPI:
    @app.doc(
        summary='[Role=User] Расчет времени, расстояния и маршрута поездки',
        responses={
            '200': GetTripDurationResponse,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, body: GetTripDurationRequest, user_id: int):
        if geo.api.check_point(body.start_point) is False:
            return utils.get_error('Сервис не работает в этом месте', 451)

        try:
            result = geo.api.get_distance(body.start_point, body.finish_point)
            if result is None:
                return utils.get_error('Невозможно построить маршрут')
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'result': result.model_dump()}
        )
