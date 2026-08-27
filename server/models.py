from pydantic import BaseModel, Field
from typing import Union, Optional, List, Dict
import datetime


class SuccessAnswer(BaseModel):
    message: str = Field('', title='Дополнительная информация')
    status: str = Field('ok', title='Статус ответа')


class ErrorAnswer(BaseModel):
    message: str = Field('', title='Информация об ошибке')
    status: str = Field('error', title='Статус ответа')


class PointModel(BaseModel):
    latitude: float = Field(description='Широта')
    longitude: float = Field(description='Долгота')


class OutEvent(BaseModel):
    id: int
    event: str
    data: Dict
    description: str = ''
