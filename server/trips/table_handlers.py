from sqlalchemy import or_, cast, String
from sqlalchemy.sql import func
from typing import Type, Callable, List, Dict, Any
from db import Session
from tables.entities import BaseTableHandler
from tables.entities import TColumn
from users.entities import User
from drivers.entities import Driver
from .entities import Trip

import tariffs
import datetime
import drivers
import users
import utils
import enums


class TripsTableHandler(BaseTableHandler):

    def __init__(self, user_class: Type, session_factory: Callable = Session):
        super().__init__(user_class, session_factory)

    def get_columns(self) -> List[TColumn]:
        return [
            TColumn(name='ID', path='id', db_sort='id'),
            TColumn(name='Статус', path='status_text', db_sort='status'),
            TColumn(name='Дата', path='created_at', db_sort='created_at'),
            TColumn(name='Водитель', path=self.get_driver, db_sort='id', xss_safe=False),
            TColumn(name='Клиент', path=self.get_user, db_sort='id', xss_safe=False),
            TColumn(name='Откуда', path=self.get_start_point, db_sort='id', xss_safe=False),
            TColumn(name='Куда', path=self.get_finish_point, db_sort='id', xss_safe=False),
            TColumn(name='Тариф', path='tariff.name', db_sort='id'),
            TColumn(name='Цена', path=self.get_cost, db_sort='cost'),
            TColumn(name='Расстояние', path=self.get_distance, db_sort='distance'),
            TColumn(name='Заказ оформлен', path=self.get_operator, db_sort='id', xss_safe=False),
            TColumn(name='', path=self.get_buttons, db_sort='id', xss_safe=False),
        ]

    def get_base_query(self, session: Session, filters: Dict[str, Any] = None):
        query = session.query(self.entity_class)
        if filters and 'status_id' in filters:
            status_id = filters.get('status_id')
            if status_id is not None:
                query = query.filter(self.entity_class.status == status_id)
        if filters and 'is_finished' in filters:
            is_finished = filters.get('is_finished')
            if is_finished is not None:
                query = query.filter(self.entity_class.is_finished == is_finished)
        if filters and 'user_id' in filters:
            user_id = filters.get('user_id')
            if user_id is not None:
                query = query.filter(self.entity_class.user_id == user_id)
        if filters and 'driver_id' in filters:
            driver_id = filters.get('driver_id')
            if driver_id is not None:
                query = query.filter(self.entity_class.driver_id == driver_id)
        if filters and 'tariff_id' in filters:
            tariff_id = filters.get('tariff_id')
            if tariff_id is not None:
                query = query.filter(self.entity_class.tariff_id == tariff_id)
        if filters and 'start_date' in filters:
            start_date = filters.get('start_date')
            if start_date is not None:
                query = query.filter(self.entity_class.created_at >= start_date)
        if filters and 'finish_date' in filters:
            finish_date = filters.get('finish_date')
            if finish_date is not None:
                query = query.filter(self.entity_class.created_at <= finish_date)
        return query

    def _apply_search(self, query, search_query: str):
        if search_query:
            search_term = '%{}%'.format(search_query)
            query = query.join(User, self.entity_class.user_id == User.id)
            query = query.join(Driver, self.entity_class.driver_id == Driver.id)
            query = query.filter(
                or_(
                    # Trip
                    cast(Trip.id, String).ilike(search_term),
                    cast(Trip.created_at, String).ilike(search_term),
                    # или func.to_char(Trip.created_at, 'YYYY-MM-DD HH24:MI:SS').ilike(term)
                    Trip.start_position_description.ilike(search_term),
                    Trip.finish_position_description.ilike(search_term),

                    # User
                    cast(User.id, String).ilike(search_term),
                    User.name.ilike(search_term),
                    User.phone.ilike(search_term),

                    # Driver
                    cast(Driver.id, String).ilike(search_term),
                    Driver.phone.ilike(search_term),
                    Driver.name.ilike(search_term),
                    Driver.surname.ilike(search_term),
                    Driver.second_name.ilike(search_term),
                )
            )
        return query

    def post_process_entities(self, entities_list: List[Any], session: Session) -> List[Any]:
        user_ids = []
        driver_ids = []

        for trip in entities_list:
            if trip.user_id not in user_ids:
                user_ids.append(trip.user_id)
            if trip.driver_id not in driver_ids:
                driver_ids.append(trip.driver_id)
            if trip.operator_id and trip.operator_id not in user_ids:
                user_ids.append(trip.operator_id)

        drivers_list = drivers.api.get_drivers(
            is_all=True,
            conditions_list=[drivers.Driver.id.in_(driver_ids)],
            session=session
        )

        users_list = users.api.get_users(
            [users.User.id.in_(user_ids)],
            is_all=True,
            session=session
        )

        tariffs_list = tariffs.api.get_tariffs(is_all=True, session=session)

        drivers_dict = {driver.id: driver for driver in drivers_list}
        users_dict = {user.id: user for user in users_list}
        tariffs_dict = {tariff.id: tariff for tariff in tariffs_list}

        for trip in entities_list:
            trip.driver = drivers_dict.get(trip.driver_id)
            trip.user = users_dict.get(trip.user_id)
            trip.tariff_id = tariffs_dict.get(trip.tariff_id)

            if trip.operator_id:
                trip.operator = users_dict.get(trip.operator_id)
            else:
                trip.operator = None

        return entities_list

    def extract_filters(self, data: Dict[str, str], user) -> Dict[str, Any]:
        status_id = int(data.get('status_id', -100))
        is_finished = int(data.get('is_finished', -100))
        user_id = int(data.get('user_id', 0))
        driver_id = int(data.get('driver_id', 0))
        tariff_id = int(data.get('tariff_id', 0))
        start_date = data.get('start_date', '')
        finish_date = data.get('finish_date', '')

        status_id = status_id if status_id != -100 else None
        is_finished = is_finished if is_finished != -100 else None
        if is_finished is not None:
            is_finished = bool(is_finished)

        user_id = user_id if user_id != 0 else None
        driver_id = driver_id if driver_id != 0 else None
        tariff_id = tariff_id if tariff_id != 0 else None

        try:
            start_date = datetime.datetime.strptime(start_date, '%Y-%m-%dT%H:%M')
        except:
            start_date = None
        try:
            finish_date = datetime.datetime.strptime(finish_date, '%Y-%m-%dT%H:%M')
        except:
            finish_date = None

        return {
            'status_id': status_id,
            'is_finished': is_finished,
            'user_id': user_id,
            'driver_id': driver_id,
            'tariff_id': tariff_id,
            'start_date': start_date,
            'finish_date': finish_date,
        }

    def get_buttons(self, trip: Trip) -> str:
        return """<div class="d-flex gap-2"><a href="/d/trip?id={}" class="btn btn-sm btn-secondary">Управление</a>
                    <a href="/d/operator?trip_id={}" class="btn btn-sm btn-secondary ms-3">Повторить</a></div>""".format(
            trip.id, trip.id
        )

    def get_operator(self, trip: Trip) -> str:
        if trip.operator_id is None:
            return 'Через приложение'
        else:
            return """Диспетчером
            <a href="/d/user?id={}" target="_blank">
                {} | [+7{}] {}
            </a>""".format(trip.operator_id, trip.operator_id, trip.operator.phone, trip.operator.name)

    def get_distance(self, trip: Trip) -> str:
        return """{} км.""".format(
            round(trip.distance / 1000, 2)
        )

    def get_cost(self, trip: Trip) -> str:
        return """{} ₽""".format(
            trip.cost
        )

    def get_start_point(self, trip: Trip) -> str:
        return """<a href="https://yandex.ru/maps/?pt={},{}&z=16&l=map" target="_blank">{}</a>""".format(
            trip.s_position.longitude, trip.s_position.latitude, trip.start_position_description
        )

    def get_finish_point(self, trip: Trip) -> str:
        return """<a href="https://yandex.ru/maps/?pt={},{}&z=16&l=map" target="_blank">{}</a>""".format(
            trip.f_position.longitude, trip.f_position.latitude, trip.finish_position_description
        )

    def get_user(self, trip: Trip) -> str:
        if trip.user is None:
            return '-'

        return """<a href="/d/user?id={}" target="_blank">{} | [+7{}] {}</a>""".format(
            trip.user_id, trip.user_id, trip.user.phone, trip.user.name
        )

    def get_driver(self, trip: Trip) -> str:
        if trip.driver is None:
            return '-'

        return """<a href="/d/driver?id={}" target="_blank">{} | [+7{}] {}</a>""".format(
            trip.driver_id, trip.driver_id, trip.driver.phone, trip.driver.fio()
        )