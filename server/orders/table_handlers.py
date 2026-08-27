import json
from flask import Response
from google.cloud.firestore_v1 import GeoPoint
from sqlalchemy import or_, cast, String
from sqlalchemy.sql import func
from typing import Callable, List, Dict, Any, Union, Tuple

import orders.api
import tables.entities
import utils
from db import Session
from tables.entities import TColumn, get_headers, get_sort_field, get_validate_tcolumns
import users
import datetime

from tables.models import TData


class TripsTableHandler:

    def __init__(self, session_factory: Callable = Session):
        self.session_factory = session_factory

    def get_columns(self) -> List[TColumn]:
        return [
            TColumn(name='ID', path='id', db_sort='id'),
            TColumn(name='Дата', path='dateTime_created', db_sort='dateTime_created'),
            TColumn(name='ВОД', path=self.get_driver, db_sort='id', xss_safe=False),
            TColumn(name='КЛИ', path=self.get_user, db_sort='id', xss_safe=False),
            TColumn(name='Откуда', path=self.get_start_point, db_sort='id', xss_safe=False),
            TColumn(name='Куда', path=self.get_finish_point, db_sort='id', xss_safe=False),
            TColumn(name='Цена', path=self.get_cost, db_sort='cost'),
            TColumn(name='Расстояние', path=self.get_distance, db_sort='distance'),
            TColumn(name='Заказ оформлен', path=self.get_operator, db_sort='id', xss_safe=False),
            TColumn(name='', path=self.get_buttons, db_sort='id', xss_safe=False),
        ]

    def get_base_query(self, filters: Dict[str, Any] = None):
        query = orders.api.fetch_firebase_orders()

        return  query

        if filters:
            if 'status_id' in filters and filters['status_id'] is not None:
                query = [order for order in query if order.get('status') == filters['status_id']]
            if 'user_id' in filters and filters['user_id'] is not None:
                query = [order for order in query if order.user_customer == filters['user_id']]
            if 'driver_id' in filters and filters['driver_id'] is not None:
                query = [order for order in query if order.selected_driver == filters['driver_id']]
            if 'start_date' in filters and filters['start_date'] is not None:
                query = [order for order in query if order.get('dateTime_create') >= filters['start_date']]
            if 'finish_date' in filters and filters['finish_date'] is not None:
                query = [order for order in query if order.get('dateTime_create') <= filters['finish_date']]

        return query

    def post_process_entities(self, entities_list: List[dict]) -> List[Any]:
        user_ids = set()
        driver_ids = set()

        for trip in entities_list:
            trip = json.loads(trip)
            user_ids.add(trip.get('user_customer').get('id'))
            if trip.get('selected_driver') is not None:
                driver_ids.add(trip.get('selected_driver').get('id'))

        users_list = users.api.get_firebase_users(None)
        users_dict = {user.get('id'): user for user in users_list}

        for trip in entities_list:
            trip = json.loads(trip)

            if trip.get('selected_driver') is None:
                trip['driver'] = users.api.get_firebase_user_by_id(users.api.firebase_user_to_json(trip.get('selected_driver')))
            if trip.get('user_customer') is None:
                trip['user'] = users.api.get_firebase_user_by_id(users.api.firebase_user_to_json(trip.get('user_customer')))
            trip['operator'] = None

        return entities_list

    def extract_filters(self, data: Dict[str, str]) -> Dict[str, Any]:
        status_id = int(data.get('status_id', -100))
        is_finished = int(data.get('is_finished', -100))
        user_id = int(data.get('user_id', 0))
        driver_id = int(data.get('driver_id', 0))
        start_date = self.parse_date(data.get('start_date', ''))
        finish_date = self.parse_date(data.get('finish_date', ''))

        return {
            'status_id': status_id if status_id != -100 else None,
            'is_finished': bool(is_finished) if is_finished != -100 else None,
            'user_id': user_id if user_id != 0 else None,
            'driver_id': driver_id if driver_id != 0 else None,
            'start_date': start_date,
            'finish_date': finish_date,
        }

    def parse_date(self, date_str: str) -> Any:
        try:
            return datetime.datetime.strptime(date_str, '%Y-%m-%dT%H:%M')
        except ValueError:
            return None

    def get_buttons(self, trip) -> str:
        return """<div class="d-flex gap-2"><a href="/d/order?id={}" class="btn btn-sm btn-secondary">Управление</a>""".format(
            trip.id
        )

    def get_operator(self, trip) -> str:
        if trip.operator_id is None:
            return 'Через приложение'
        return """Диспетчером
            <a href="/d/user?id={}" target="_blank">
                {} | [+7{}] {}
            </a>""".format(trip.operator_id, trip.operator_id, trip.operator.phone, trip.operator.name)

    def get_distance(self, trip) -> str:
        return f"{trip.distance} м"

    def get_cost(self, trip) -> str:
        return """{} ₽""".format(trip.budget)

    def get_start_point(self, trip) -> str:
        return """<a href="https://yandex.ru/maps/?pt={},{}&z=16&l=map" target="_blank">{}</a>""".format(
            trip.pointB.latlng[1], trip.pointB.latlng[0], trip.pointB.address
        )

    def get_finish_point(self, trip) -> str:
        return """<a href="https://yandex.ru/maps/?pt={},{}&z=16&l=map" target="_blank">{}</a>""".format(
            trip.pointA.latlng[1], trip.pointA.latlng[0], trip.pointA.address
        )

    def get_user(self, order) -> str:
        if order.user_customer is None:
            return '-'
        driver = users.api.get_firebase_user_by_id(order.selected_driver)

        return """<a href="/d/user?id={}" target="_blank">{} | [{}] {}</a>""".format(
            driver.id, driver.id, driver.email, driver.display_name
        )

    def get_driver(self, order) -> str:
        if order.selected_driver is None:
            return '-'
        driver = users.api.get_firebase_user_by_id(order.selected_driver)

        return """<a href="/d/user?id={}" target="_blank">{} | [{}] {}</a>""".format(
            driver.id, driver.id, driver.email, driver.display_name
        )

    def get_table(self, data: Dict[str, str], user: Any):
        """Получает данные таблицы в формате JSON"""
        draw = int(data.get('draw', 0))

        rows, headers, count = self.get_rows(data)
        if rows is None:
            answer = {
                'headers': headers,
            }
        else:
            rows = (rows)  # Сериализуем строки перед отправкой
            answer = {
                'draw': draw,
                'recordsFiltered': count,
                'recordsTotal': count,
                'data': rows,
                'headers': headers,
            }


        return Response(
            status=200,
            response=json.dumps(answer, ensure_ascii=False, indent=3, default=utils.json_serial),
            mimetype='application/json'
        )


    def get_rows(self, data: Dict[str, str], user: Any) -> Tuple[
        Union[None, List[List[str]]], List[str], Union[None, int]]:

        columns = self.get_columns()
        tdata = TData.model_validate(data)

        filters = self.extract_filters(data, user)

        if tdata.only_headers == 1:
            return None, get_headers(columns, tdata), None

        sort_field = get_sort_field(tdata.sort_index, get_validate_tcolumns(columns, tdata))
        entities_list, entities_count = tables.entities.get_entities_with_count(tdata, sort_field, filters)

        rows = tables.get_table_rows(entities_list, columns, user, tdata)

        if len(rows) > tdata.page_count and not tdata.is_export:
            rows = rows[:tdata.page_count]

        return rows, get_headers(columns, tdata), entities_count

    def _apply_search(self, query: List[Any], search_query: str) -> List[Any]:
        if not search_query:
            return query

        search_query = search_query.lower()
        return [item for item in query if any(search_query in str(value).lower() for value in item.values())]

