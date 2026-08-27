from pydantic import BaseModel, Field, field_validator
from typing import List, Literal
import models
import datetime
import enums


class TariffStatusModel(BaseModel):
    id: int = Field(description='ID тарифа')
    name: str = Field(description='Название тарифа')
    status: bool = Field(description='Статус доступности тарифа для водителя')
    driver_status: bool = Field(description='Статус активности тарифа для водителя', default=False)


class CarModel(BaseModel):
    brand: str = Field(description='Марка автомобиля')
    model: str = Field(description='Модель автомобиля')
    numberplate: str = Field(description='Гос номер автомобиля')
    color: str = Field(description='Цвет автомобиля')


class DriverDoc(BaseModel):
    id: str = ''
    name: str = ''
    number: str = ''
    serial: str = ''
    date: datetime.date | None
    additional_info: str = ''


class DriverModel(BaseModel):
    id: int = Field(description='ID водителя')
    phone: str = Field(description='Номер телефона')
    name: str = Field(description='Имя')
    second_name: str = Field(description='Отчество')
    surname: str = Field(description='Фамилия')
    photo_uuid: str | None = Field(description='UUID фотографии')
    car: CarModel = Field(description='Описание автомобиля')
    status: enums.DriverStatus = Field(description='Статус')
    created_at: datetime.datetime = Field(description='Дата регистрации водителя')
    payment_methods: List[str] = Field(description='Список выбранных способов оплаты. Возможные значения: cash, card')
    tariffs: List[TariffStatusModel] = Field(description='Статус активности тарифов')
    subscribe_expiration: datetime.datetime | None = Field(description='Дата истечения подписки')
    rating: float = Field(description='Рейтинг водителя')
    trips_count: int = Field(description='Кол-во выполненных поездок')
    last_position: models.PointModel = Field(description='Последнее местоположение водителя')
    fcm_token: str | None = Field(description='FCM Token')


class CreateDriverModel(BaseModel):
    phone: str
    name: str
    second_name: str = ''
    surname: str
    car: CarModel


class EditDriverModel(BaseModel):
    id: int
    photo_uuid: str | None
    phone: str
    password: str
    name: str
    surname: str
    second_name: str
    subscribe_expiration: datetime.datetime | None
    is_blocked: bool
    car_model: str
    car_brand: str
    car_numberplate: str
    car_color: str


class AuthDriverRequest(BaseModel):
    phone: str = Field(description='Номер телефона')
    password: str = Field(description='Пароль')

    @field_validator("password", mode="before")
    @classmethod
    def convert_to_str(cls, v):
        return str(v) if isinstance(v, int) else v

    @field_validator("phone", mode="before")
    @classmethod
    def convert_to_str_phone(cls, v):
        return str(v) if isinstance(v, int) else v


class AuthDriverResponse(models.SuccessAnswer):
    driver: DriverModel = Field(description='Модель водителя')
    access_token: str = Field(description='AccessToken')


class GetDriverResponse(models.SuccessAnswer):
    driver: DriverModel = Field(description='Модель водителя')


class ChangePaymentMethod(BaseModel):
    payment_method_code: Literal['cash', 'card'] = Field(description='Способ оплаты')


class ChangeTariff(BaseModel):
    tariff_id: int = Field(description='ID тарифа')
    status: bool = Field(description='Статус')


class ChangeStatus(BaseModel):
    status: Literal['offline', 'online'] = Field(description='Новый статус водителя')


class UpdatePosition(BaseModel):
    point: models.PointModel = Field(description='Координаты местоположения')


class UpdatePhoto(BaseModel):
    photo_uuid: str = Field(description='UUID аватарки')


class SetFCMRequest(BaseModel):
    fcm_token: str | None = Field(description='FCM Token')