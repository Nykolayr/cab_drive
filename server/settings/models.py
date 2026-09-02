from shapely.geometry import Point, Polygon
from pydantic import BaseModel, Field
from typing import List
from decimal import Decimal
from pydantic import BaseModel
from shapely.geometry import LineString, Polygon
from shapely.ops import unary_union
from geopy.distance import geodesic
from typing import List

import models
import polyline


class DriverTariff(BaseModel):
    id: str = Field(description='ID тарифа')
    name: str = Field(description='Название')
    hours: int = Field(description='Кол-во часов')
    is_discount: bool = Field(description='Флаг скидки')
    cost: int = Field(description='Цена')


class Area(BaseModel):
    coords: List[List[float]]


class SiteModel(BaseModel):
    driver_tariffs: List[DriverTariff] = []
    polygons: List[Area] = []
    cities: List[Area] = []
    minutes_for_delete_order: int = 15
    deadline_minutes: int = 15
    # multi-orders / «по пути» — параметры для логики дополнительных заказов
    extra_order_max_extra_distance_km: float = 5.0
    extra_order_max_extra_time_min: float = 10.0
    extra_order_search_radius_km: float = 5.0
    driver_max_queue_size: int = 2
    extra_order_notify_cooldown_sec: int = 30
    # T‑Bank: режим терминала и базовый URL для МП (без секретов)
    tinkoff_mode: str = 'test'  # test | prod
    payments_base_url: str = 'https://cab.artean.ru'

    def is_point_in_polygons(self, point: models.PointModel):
        point = Point(point.longitude, point.latitude)
        for poly in self.polygons:
            polygon = Polygon([(lng, lat) for lat, lng in poly.coords])
            if polygon.contains(point):
                return True
        return False

    def is_point_in_cities(self, lat: float, lng: float) -> bool:
        pt = Point(lng, lat)
        for area in self.cities:
            polygon = Polygon([(c_lng, c_lat) for c_lat, c_lng in area.coords])
            if polygon.contains(pt):
                return True
        return False


    @staticmethod
    def decode_polyline(encoded):
        """Декодирует polyline в список (lon, lat)"""
        coords = polyline.decode(encoded)  # [(lat, lon)]
        return [(lon, lat) for lat, lon in coords]

    def route_length_in_cities(self, encoded_polyline: str) -> float:
        """
        Возвращает длину маршрута (в метрах), которая проходит внутри хотя бы одного полигона.
        """
        # 1. Декодируем polyline (Google Encoded Polyline → список (lat, lng))
        route_coords = polyline.decode(encoded_polyline)

        # 2. Конвертируем координаты в (lng, lat) для shapely (он работает в X=lng, Y=lat)
        route_coords_xy = [(lng, lat) for lat, lng in route_coords]
        route_line = LineString(route_coords_xy)

        # 3. Создаём shapely полигоны
        shapely_polygons = [
            Polygon([(lng, lat) for lat, lng in area.coords])
            for area in self.cities
        ]

        # 4. Объединяем полигоны в одну геометрию
        merged_polygons = unary_union(shapely_polygons)

        # 5. Пересекаем маршрут с полигонами
        intersection = route_line.intersection(merged_polygons)

        def segment_length(coords):
            total = 0.0
            for i in range(len(coords) - 1):
                total += geodesic(
                    (coords[i][1], coords[i][0]),
                    (coords[i + 1][1], coords[i + 1][0])
                ).meters
            return total

        # intersection может быть LineString, MultiLineString или пустым
        if intersection.is_empty:
            return 0.0
        elif intersection.geom_type == 'LineString':
            return segment_length(list(intersection.coords))
        elif intersection.geom_type == 'MultiLineString':
            return sum(segment_length(list(geom.coords)) for geom in intersection.geoms)
        else:
            return 0.0