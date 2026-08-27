from sqlalchemy import Column, orm
from geoalchemy2 import Geometry
from geoalchemy2.shape import to_shape
from .models import *
from models import PointModel
from db import Base
import sqlalchemy as db
import datetime
import enums
import config
import requests
import utils


PAYMENT_METHODS = ['cash', 'card']


class Driver(Base):
    tariffs = None
    documents = None
    position = None
    __tablename__ = 'drivers'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    phone = Column(db.String(24))
    password = Column(db.String(64))
    name = Column(db.String(64))
    second_name = Column(db.String(64))
    surname = Column(db.String(64))
    photo_uuid = Column(db.String(64))
    car_brand = Column(db.String(64))
    car_model = Column(db.String(64))
    car_numberplate = Column(db.String(64))
    car_color = Column(db.String(64))
    status = Column(db.Enum(enums.DriverStatus), default=enums.DriverStatus.OFFLINE)
    created_at = Column(db.DateTime, default=datetime.datetime.now)
    payment_methods = Column(db.JSON, default=[])
    tariffs_json = Column(db.JSON, default=[])
    subscribe_expiration = Column(db.DateTime, default=None)
    is_blocked = Column(db.Boolean, default=False)
    rating = Column(db.DECIMAL(4, 2), default=5)
    trips_count = Column(db.Integer, default=0)
    documents_json = Column(db.JSON, default=[])
    files = Column(db.JSON, default=[])
    last_position = Column(Geometry('POINT'))
    last_point_updated = Column(db.DateTime, default=None)
    current_trip_id = Column(db.Integer, default=None)
    is_removed = Column(db.Boolean, default=False)
    fcm_token = Column(db.String(256), default=None)

    def schema(self):
        position = self.get_position
        if position is not None:
            position = position.model_dump()
        data = {
            'id': self.id,
            'phone': '+7' + self.phone,
            'name': self.name,
            'second_name': self.second_name,
            'surname': self.surname,
            'photo_uuid': self.photo_uuid,
            'car': {
                'brand': self.car_brand,
                'model': self.car_model,
                'numberplate': self.car_numberplate,
                'color': self.car_color
            },
            'status': self.status,
            'created_at': self.created_at,
            'payment_methods': self.payment_methods,
            'tariffs': [v.model_dump() for v in self.tariffs],
            'subscribe_expiration': self.subscribe_expiration,
            'rating': self.rating,
            'trips_count': self.trips_count,
            'last_position': position,
            'fcm_token': self.fcm_token
        }
        return data

    @orm.reconstructor
    def init_on_load(self):
        self.tariffs = [TariffStatusModel.model_validate(t) for t in self.tariffs_json]
        self.documents = [DriverDoc.model_validate(d) for d in self.documents_json]

    @property
    def get_position(self) -> PointModel | None:
        if self.last_position is None:
            return None
        point = to_shape(self.last_position)
        return PointModel(latitude=point.x, longitude=point.y)

    def fio(self) -> str:
        result = '{}'.format(self.surname if self.surname is not None else '')

        if len(result) > 0:
            if self.name is not None and len(self.name) > 0:
                result += ' {}'.format(self.name)
        else:
            result += '{}'.format(self.name)

        if len(result) > 0:
            if self.second_name is not None and len(self.second_name) > 0:
                result += ' {}'.format(self.second_name)
        else:
            result += '{}'.format(self.second_name)

        return result

    def __repr__(self) -> str:
        position = '---'
        point = self.get_position
        if point is not None:
            position = '{}, {}'.format(point.latitude, point.longitude)
        return f"<Driver [ID: {self.id}] [Name: {self.fio()}] [LastPosition: {position}]>"

    def send_socket(self, event, data, description) -> bool:
        return self.send_ws(self.id, event, data, description)

    @staticmethod
    def send_ws(driver_id, event, data, description) -> bool:
        url = '{}/driver'.format(config.Production.TROIKA_S_BASE_URL)
        data = {
            'id': driver_id,
            'event': event,
            'data': utils.to_json(data),
            'description': description
        }

        try:
            response = requests.post(url, json=data)
        except:
            return False
        if response.status_code != 200:
            return False

        data = response.json()
        return data['status']

    @staticmethod
    def send_position(driver_id, point: models.PointModel) -> bool:
        url = '{}/position'.format(config.Production.TROIKA_S_BASE_URL)
        params = {
            'driver_id': driver_id
        }
        data = point.model_dump()

        try:
            response = requests.post(url, json=data, params=params)
        except:
            return False
        if response.status_code != 200:
            return False

        data = response.json()
        return data['status']

    def check_expiration(self) -> bool:
        if self.subscribe_expiration is None:
            return False

        now = datetime.datetime.now()
        return now <= self.subscribe_expiration
