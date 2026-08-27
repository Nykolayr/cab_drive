from sqlalchemy import Column, orm
from db import Base
import sqlalchemy as db
import datetime
import utils


class Tariff(Base):
    __tablename__ = 'tariffs'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    name = Column(db.String(64))
    icon_uuid = Column(db.String(64))
    base_distance = Column(db.DECIMAL(16, 2))
    base_cost = Column(db.DECIMAL(16, 2))
    cost_by_km_day = Column(db.DECIMAL(16, 2))
    cost_by_km_night = Column(db.DECIMAL(16, 2))
    index = Column(db.Integer, default=0)
    is_removed = Column(db.Boolean, default=False)
    cost_city_by_km_day = Column(db.DECIMAL(16, 2))
    cost_city_by_km_night = Column(db.DECIMAL(16, 2))
    free_waiting = Column(db.Integer, default=3)
    cost_waiting = Column(db.Integer, default=8)
    base_distance_night = Column(db.DECIMAL(16, 2))
    base_cost_night = Column(db.DECIMAL(16, 2))

    def schema(self):
        data = {
            'id': self.id,
            'name': self.name,
            'icon_uuid': self.icon_uuid,
            'base_distance': self.base_distance,
            'base_cost': self.base_cost,
            'base_distance_night': self.base_distance_night,
            'base_cost_night': self.base_cost_night,
            'cost_by_km_day': self.cost_by_km_day,
            'cost_by_km_night': self.cost_by_km_night,
            'cost_city_by_km_day': self.cost_city_by_km_day,
            'cost_city_by_km_night': self.cost_city_by_km_night,
            'free_waiting': self.free_waiting,
            'cost_waiting': self.cost_waiting
        }
        return data

    def calculate_trip_cost(self, distance: float, distance_city: float, is_night: bool | None = None) -> int:
        if is_night is None:
            is_night = self.is_night()

        distance_km = distance / 1000
        distance_city_km = distance_city / 1000

        cost_per_km_intercity = float(self.cost_by_km_night if is_night else self.cost_by_km_day)
        cost_per_km_city = float(self.cost_city_by_km_night if is_night else self.cost_city_by_km_day)

        total_distance_km = distance_km + distance_city_km

        base_distance = self.base_distance
        base_cost = self.base_cost

        if is_night:
            base_distance = self.base_distance_night
            base_cost = self.base_cost_night

        if total_distance_km <= float(base_distance):
            return int(base_cost)

        extra_distance = total_distance_km - float(base_distance)

        intercity_share = min(distance_km, extra_distance)
        city_share = max(0, extra_distance - intercity_share)

        total_cost = float(base_cost)
        total_cost += intercity_share * cost_per_km_intercity
        total_cost += city_share * cost_per_km_city

        return int(total_cost)

    def is_night(self) -> bool:
        now = datetime.datetime.now().time()
        if 6 <= now.hour <= 21:
            return False
        else:
            return True
