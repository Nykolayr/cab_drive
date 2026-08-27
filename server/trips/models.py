from pydantic import BaseModel, Field
from typing import Literal
from geo.models import *
from drivers.models import DriverModel

import models
import datetime


class TripModel(BaseModel):
    id: int = Field(description='ID поездки')
    user_id: int = Field(description='ID клиента')
    driver_id: int = Field(description='ID водителя')
    start_position: models.PointModel = Field(description='Точка старта')
    start_position_description: str = Field(description='Адрес посадки')
    finish_position: models.PointModel = Field(description='Точка финиша')
    finish_position_description: str = Field(description='Адрес финиша')
    distance: int = Field(description='Расстояние поездки, в метрах')
    distance_city: int = Field(description='Расстояние поездки (по городу), в метрах')
    cost: float = Field(description='Стоимость поездки')
    payment_method: Literal['cash', 'card'] = Field(description='Способ оплаты')
    tariff_id: int = Field(description='ID тарифа')
    created_at: datetime.datetime = Field(description='Дата создания поездки')
    finished_at: datetime.datetime | None = Field(description='Дата завершения поездки', default=None)
    status: int = Field(description='ID статуса')
    status_text: str = Field(description='Текстовое название статуса')
    client_comment: str = Field(description='Комментарий клиента')
    cancel_comment: str = Field(description='Причина отмены заказа (только для статуса -10)')
    geometry: str = Field(description='Polyline маршрута')
    rating: float = Field(description='Оценка поездки')
    driver: DriverModel | None = Field(description='Модель водителя')
    client_phone: str | None = Field(description='Телефон клиента')
    duration: int | None = Field(description='Продолжительность поездки, в секундах')
    paid_waiting_seconds: int = Field(description='Кол-во секунд платного ожидания')
    paid_waiting_cost: int = Field(description='Стоимость платного ожидания')
    boarding_at: datetime.datetime | None = Field(description='Флаг платного ожидания')


class CalculateTripRequest(BaseModel):
    start_point: models.PointModel = Field(description='Начальная точка')
    finish_point: models.PointModel = Field(description='Конечная точка')


class TripCalculation(BaseModel):
    calculation_token: str | None = Field(description='Токен расчёта стоимости или null, если нет возможности подать авто', default=None)
    tariff_id: int = Field(description='ID тарифа')
    tariff_name: str = Field(description='Название тарифа')
    pickup_time: int | None = Field(description='Время подачи автомобиля или null, если нет возможности подать авто', default=None)
    trip_info: DistanceResult | None = Field(description='Информация о маршруте или null, если нет возможности подать авто', default=None)
    start_point: models.PointModel = Field(description='Начальная точка поездки')
    finish_point: models.PointModel = Field(description='Конечная точка поездки')
    cost: float | None = Field(description='Стоимость поездки или null, если нет возможности подать авто', default=None)


class CalculationTripResponse(models.SuccessAnswer):
    calculations: List[TripCalculation] = Field(description='Список расчётов для каждого тарифа')


class CreateTripRequest(BaseModel):
    calculation_token: str = Field(description='Токен расчёта стоимости')
    comment: str = Field(description='Комментарий для водителя', default='')
    payment_method: Literal['cash', 'card'] = Field(description='Способ оплаты')
    client_phone: str | None = Field(description='Номер телефона клиента (для аккаунта модератора)', default=None)


class GetTripResponse(models.SuccessAnswer):
    trip: TripModel = Field(description='Модель поездки')


class GetTripsListResponse(models.SuccessAnswer):
    trips: List[TripModel] = Field(description='Список моделей поездки')


class CancelTripRequest(BaseModel):
    trip_id: int = Field(description='ID заказа')


class AcceptTripRequest(BaseModel):
    trip_id: int = Field(description='ID заказа')


class NextStatusTripRequest(BaseModel):
    trip_id: int = Field(description='ID заказа')


class SendScoreRequest(BaseModel):
    trip_id: int = Field(description='ID поездки')
    rating: float = Field(description='Оценка')


class StartWaitingTripRequest(BaseModel):
    trip_id: int = Field(description='ID заказа')


class StopWaitingTripRequest(BaseModel):
    trip_id: int = Field(description='ID заказа')