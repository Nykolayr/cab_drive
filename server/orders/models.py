
from enum import Enum
from typing import Dict, Optional

from pydantic import BaseModel, Field

from models import SuccessAnswer


class Tariff(str, Enum):
    LARGUS = "largusTermo"
    LARGUS_MEDIUM = "largus"
    LARGUS_MAX = "fiat"


# --- multi-orders / extra_accept ---

class ExtraAcceptRequest(BaseModel):
    order_id: str = Field(..., description="ID заказа (Firestore doc id), который принимает водитель")
    driver_uid: str = Field(..., description="UID водителя (Firestore doc id в коллекции users)")


class ExtraAcceptData(BaseModel):
    order_id: str
    queue_size: int = Field(..., description="Размер очереди активных заказов после акцепта")


class ExtraAcceptResponse(SuccessAnswer):
    extra: ExtraAcceptData = Field(..., description="Данные принятого доп.заказа")


class LocationModel(BaseModel):
    lat: float = Field(..., description="Широта")
    lng: float = Field(..., description="Долгота")


class DriverModel(BaseModel):
    uid: str = Field(..., description="UID водителя (doc id в Firestore)")
    display_name: Optional[str] = Field(None, description="Имя / отображаемое имя")
    phone_number: Optional[str] = Field(None, description="Телефон")
    mark: Optional[str] = Field(None, description="Марка/тип автомобиля (поле mark)")
    commission_percent: Optional[float] = Field(None, description="Процент комиссии у водителя")
    is_blocked: Optional[bool] = Field(None, description="Заблокирован ли водитель")
    on_shift: Optional[bool] = Field(None, description="На смене ли водитель")
    lat: float = Field(..., description="Широта текущей позиции водителя")
    lng: float = Field(..., description="Долгота текущей позиции водителя")
    distance_km: float = Field(..., description="Прямая дистанция от пассажира до водителя, км")


class ETAItem(BaseModel):
    eta_seconds: int = Field(..., description="Время подачи в секундах (реальное по маршруту)")
    eta_text: str = Field(..., description="Человеко-понятное время (например, '5 мин')")
    driver: DriverModel = Field(..., description="Информация о выбранном водителе (тот, чей ETA используется)")


# Ответ: словарь тариф -> ETAItem | None (None если нет доступных водителей для тарифа)
class ETAResponse(SuccessAnswer):
    etas: Dict[Tariff, Optional[ETAItem]] = Field(..., description="ETA для каждого тарифа (None если недоступно)")


class PriceBreakdown(BaseModel):
    price_base: float = Field(..., description="Базовая цена без учета тарифа и загруженности")
    price_after_tariff: float = Field(..., description="Цена после применения тарифного множителя")


class PriceItem(BaseModel):
    price: float = Field(..., description="Итоговая цена для пассажира")
    distance_km: float = Field(..., description="Дистанция маршрута в километрах")
    duration_sec: int = Field(..., description="Длительность маршрута в секундах")
    tariff_multiplier: float = Field(..., description="Множитель тарифа (1.0 / 1.2 / 1.4)")
    congestion_multiplier: float = Field(..., description="Множитель загруженности (surge)")
    available_drivers_in_radius: int = Field(..., description="Кол-во доступных водителей в радиусе")
    breakdown: PriceBreakdown = Field(..., description="Разбивка по этапам расчёта цены")


# Ответ: словарь тариф -> PriceItem | None (None если невозможно рассчитать)
class PricesResponse(SuccessAnswer):
    prices: Dict[Tariff, Optional[PriceItem]] = Field(..., description="Цены для каждого тарифа (None если недоступно)")


# Входные модели для view:
class GetETARequest(BaseModel):
    user_location: LocationModel = Field(..., description="Позиция пассажира")


class GetPricesRequest(BaseModel):
    user_location: LocationModel = Field(..., description="Позиция пассажира (начало маршрута)")
    dest_location: LocationModel = Field(..., description="Позиция назначения (конец маршрута)")
    intermediate_location: LocationModel = Field(description="Промежуточная позиция", default=None)
    movers: Optional[int | None] = Field(description="Грузчики", default=None)