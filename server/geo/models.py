from pydantic import BaseModel, Field
from typing import List, Union, Literal
import models


class GeoInfoModel(BaseModel):
    name: str = Field(description='Название места')
    description: Union[str, None] = Field(description='Описание места', default=None)
    location: str = Field(description='Локация', default='')


class GetGeoInfoResponse(models.SuccessAnswer):
    results: List[GeoInfoModel] = Field(description='Список результатов')


class Suggest(BaseModel):
    name: str = Field(description='Адрес объекта')
    location: str = Field(description='Название населенного пункта')
    point: models.PointModel = Field(description='Координаты')


class SuggestionRequest(BaseModel):
    query: str = Field(description='Поисковый запрос')
    point: models.PointModel | None = Field(description='Координаты пользователя (для более точного поиска)', default=None)


class YSuggestionRequest(BaseModel):
    token: str = Field(description='Токен поисковой сессии')
    query: str = Field(description='Поисковый запрос')
    point: models.PointModel | None = Field(description='Координаты пользователя (для более точного поиска)', default=None)


class TwoGisSuggestionRequest(BaseModel):
    query: str = Field(description='Поисковый запрос')
    point: models.PointModel | None = Field(description='Координаты пользователя (для более точного поиска)', default=None)


class SuggestionResponse(models.SuccessAnswer):
    suggestions: List[Suggest] = Field(description='Список результатов')


class DriverDistance(BaseModel):
    driver_id: int = Field(description='ID водителя')
    start: models.PointModel = Field(description='Start Point')
    finish: models.PointModel = Field(description='Start Point')


class GetDistances(BaseModel):
    drivers: List[DriverDistance] = Field(description='Список задач')


class DistanceResult(BaseModel):
    distance: int = Field(description='Расстояние, в метрах')
    distance_city: int | None = Field(description='Расстояние по городу', default=None)
    duration: int = Field(description='Время, в секундах')
    geometry: str = Field(description='Polyline маршрута')
    driver_id: int | None = Field(description='ID водителя', default=None)


class GetPickupTimeRequest(BaseModel):
    tariff_ids: List[int] = Field(description='ID тарифов для поиска')
    point: models.PointModel = Field(description='Координаты подачи автомобиля')


class PickupTime(BaseModel):
    tariff_id: int = Field(description='ID тарифа')
    tariff_name: str = Field(description='Название тарифа')
    pickup_time: int | None = Field(description='Время подачи автомобиля, в секундах или null, если подать автомобиль невозможно')
    pickup_distance: int | None = Field(description='Расстояние подачи автомобиля, в метрах или null, если подать автомобиль невозможно', default=None)


class GetPickupTimeResponse(models.SuccessAnswer):
    times: List[PickupTime] = Field(description='Список времён подачи автомобиля по тарифам')


class GetTripDurationRequest(BaseModel):
    start_point: models.PointModel = Field(description='Стартовая точка')
    finish_point: models.PointModel = Field(description='Конечная точка')


class GetTripDurationResponse(models.SuccessAnswer):
    result: DistanceResult = Field(description='Модель с информацией о поездке и маршруте')


class YandexSuggestAddressComponent(BaseModel):
    name: str = Field(description='Название компонента адреса')
    kind: List[str] = Field(description='Тип компонента адреса')


class YandexSuggestAddress(BaseModel):
    formatted_address: str = Field(description='Адрес объекта')
    component: List[YandexSuggestAddressComponent] = Field(description='Компоненты адреса')


class YandexSuggest(BaseModel):
    title: str = Field(description='Название объекта')
    subtitle: str | None = Field(description='Название объекта')
    tags: List[str] = Field(description='Тип найденного объекта')
    address: YandexSuggestAddress = Field(description='Адрес найденного объекта')
    uri: str = Field(description='URI объекта')
    line_1: str | None = Field(description='Основной текст адреса', default=None)
    line_2: str | None = Field(description='Дополнительный текст адреса', default=None)


class TwoGisSuggest(BaseModel):
    name: str = Field(description='Название места')
    full_name: str | None = Field(description='Полное название', default=None)
    address_name: str | None = Field(description='Адрес', default=None)
    point: models.PointModel = Field(description='Координаты')
    location: str = Field(description='Район')
    type: str = Field(description='Тип адреса')


class YSuggestionResponse(models.SuccessAnswer):
    suggestions: List[YandexSuggest] = Field(description='Список результатов')


class GetPointByURIRequest(BaseModel):
    uri: str = Field(description='uri полученные из метода suggest yandex')


class GetPointByURIResponse(models.SuccessAnswer):
    point: models.PointModel = Field(description='Координаты')
