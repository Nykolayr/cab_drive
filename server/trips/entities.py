from sqlalchemy import Column, orm
from geoalchemy2 import Geometry
from geoalchemy2.shape import to_shape
from models import PointModel
from db import Base
import polyline
import sqlalchemy as db
import datetime
import models
import enums
import utils


class Trip(Base):
    __tablename__ = 'trips'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = Column(db.Integer)
    driver_id = Column(db.Integer, default=None)
    start_position = Column(Geometry('POINT'))
    start_position_description = Column(db.String(128))
    finish_position = Column(Geometry('POINT'))
    finish_position_description = Column(db.String(128))
    distance = Column(db.Integer)
    cost = Column(db.DECIMAL(12, 2))
    payment_method = Column(db.String(64))
    tariff_id = Column(db.Integer)
    created_at = Column(db.DateTime, default=datetime.datetime.now)
    finished_at = Column(db.DateTime, default=None)
    driver_accept_expiration = Column(db.DateTime, default=None)
    status = Column(db.Integer, default=0)
    exclude_drivers = Column(db.JSON, default=[])
    search_radius = Column(db.Integer, default=10)
    client_comment = Column(db.Text, default='')
    cancel_comment = Column(db.Text, default='')
    geometry = Column(db.Text, default='')
    rating = Column(db.DECIMAL(5, 2), default=None)
    is_finished = Column(db.Boolean, default=False)
    search_expiration = Column(db.DateTime, default=None)
    duration = Column(db.Integer, default=None)
    client_phone = Column(db.String(64), default=None)
    distance_city = Column(db.Integer, default=0)
    operator_id = Column(db.Integer, default=None)
    paid_waiting_seconds = Column(db.Integer, default=0)
    paid_waiting_cost = Column(db.Integer, default=0)
    boarding_at = Column(db.DateTime, default=None)

    def schema(self):
        data = {
            'id': self.id,
            'user_id': self.user_id,
            'driver_id': self.driver_id,
            'start_position': self.s_position.model_dump(),
            'start_position_description': self.start_position_description,
            'finish_position': self.f_position.model_dump(),
            'finish_position_description': self.finish_position_description,
            'distance': self.distance,
            'distance_city': self.distance_city,
            'cost': self.cost,
            'payment_method': self.payment_method,
            'tariff_id': self.tariff_id,
            'created_at': self.created_at,
            'finished_at': self.finished_at,
            'status': self.status,
            'status_text': self.status_text(by_user=True),
            'client_comment': self.client_comment,
            'cancel_comment': self.cancel_comment,
            'geometry': self.geometry,
            'rating': self.rating,
            'duration': self.duration,
            'client_phone': '+7' + self.client_phone,
            'paid_waiting_seconds': self.paid_waiting_seconds,
            'paid_waiting_cost': self.paid_waiting_cost,
            'boarding_at': self.boarding_at
        }

        if hasattr(self, '_driver'):
            data['driver'] = self._driver
        else:
            data['driver'] = None

        if data['driver'] is None and hasattr(self, 'driver'):
            data['driver'] = self.driver
        return data

    @staticmethod
    def get_status_name(status_id, by_user=False) -> str:
        if by_user is False:
            if status_id == 0:
                return 'Поиск машины'
            elif status_id == 1:
                return 'Ожидаем ответ водителя'
            elif status_id == 2:
                return 'Водитель едет на заказ'
            elif status_id == 3:
                return 'Ожидание клиента'
            elif status_id == 4:
                return 'Клиент в машине'
            elif status_id == 10:
                return 'Поездка завершена'
            elif status_id == -10:
                return 'Поездка отменена'
            else:
                return 'Неизвестный статус'
        else:
            if status_id in [0, 1]:
                return 'Поиск машины'
            elif status_id in [2]:
                return 'Водитель едет на заказ'
            elif status_id in [3]:
                return 'Автомобиль ожидает'
            elif status_id in [4]:
                return 'Поездка выполняется'
            elif status_id in [10]:
                return 'Поездка завершена'
            elif status_id in [-10]:
                return 'Поездка отменена'
            else:
                return 'Неизвестный статус'

    def status_text(self, by_user=False):
        return self.get_status_name(self.status, by_user)

    @property
    def s_position(self) -> models.PointModel:
        point = to_shape(self.start_position)
        return models.PointModel(latitude=point.x, longitude=point.y)

    @property
    def f_position(self) -> models.PointModel:
        point = to_shape(self.finish_position)
        return models.PointModel(latitude=point.x, longitude=point.y)

    def get_payment_method(self) -> str:
        if self.payment_method == 'cash':
            return 'Наличные'
        else:
            return 'Перевод на карту'

    def get_polyline(self):
        return polyline.decode(self.geometry)


class TripEvent(Base):
    __tablename__ = 'trips_events'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    trip_id = Column(db.Integer)
    date = Column(db.DateTime, default=datetime.datetime.now)
    event = Column(db.Text, default='')