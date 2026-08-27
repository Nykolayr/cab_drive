from pydantic import BaseModel, Field
from typing import List
import models


class TariffModel(BaseModel):
    id: int = Field(description='ID тарифа')
    name: str = Field(description='Название тарифа')
    icon_uuid: str = Field(description='UUID иконки')
    base_distance: float = Field(description='Базовое расстояние, в км (посадка)')
    base_cost: float = Field(description='Стоимость базового расстояния (цена посадки)')
    base_distance_night: float = Field(description='Базовое расстояние, в км (посадка) (ночь)')
    base_cost_night: float = Field(description='Стоимость базового расстояния (цена посадки) (ночь)')
    cost_by_km_day: float = Field(description='Цена за 1 км (межгород), днём')
    cost_by_km_night: float = Field(description='Цена за 1 км (межгород), ночью')
    cost_city_by_km_day: float = Field(description='Цена за 1 км по городу, днём')
    cost_city_by_km_night: float = Field(description='Цена за 1 км по городу, ночью')
    free_waiting: int = Field(description='Кол-во минут бесплатного ожидания')
    cost_waiting: int = Field(description='Стоимость одной минуты платного ожидания')


class GetTariffsList(models.SuccessAnswer):
    tariffs: List[TariffModel] = Field(description='Список тарифов')