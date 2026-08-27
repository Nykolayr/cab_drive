from pydantic import BaseModel, Field
from typing import Union, List
import datetime
import models


class PaymentModel(BaseModel):
    id: int = Field(description='ID платежа')
    amount: int = Field(description='Сумма платежа')
    status: int = Field(description='ID статуса')
    status_text: str = Field(description='Название статуса')
    created_at: datetime.datetime = Field(description='Дата создания платежа')
    finished_at: Union[datetime.datetime, None] = Field(description='Дата завершения платежа', default=None)
    tariff_hours: int = Field(description='Кол-во часов тарифа')
    tariff_name: str = Field(description='Название тарифа')
    payment_url: str = Field(description='Ссылка на оплату')


class CreateDriverPaymentRequest(BaseModel):
    tariff_id: str = Field(description='ID тарифа')


class CreateDriverPaymentModel(models.SuccessAnswer):
    payment: PaymentModel = Field(description='Платеж')


class DriverTariffModel(BaseModel):
    id: str = Field(description='ID тарифа')
    name: str = Field(description='Название тарифа')
    hours: int = Field(description='Кол-во часов')
    is_discount: bool = Field(description='Является ли скидкой')
    cost: int = Field(description='Цена')


class GetDriversTariffsModel(models.SuccessAnswer):
    tariffs: List[DriverTariffModel] = Field(description='Список тарифов')