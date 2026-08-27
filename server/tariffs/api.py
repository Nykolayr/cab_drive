from typing import List
from db import Session
from .entities import *
from .models import *
from errors import *

import files


def get_tariff_by_id(tariff_id, session=None) -> Tariff | None:
    if session is None:
        with Session() as session:
            tariff = session.query(Tariff).get(tariff_id)
    else:
        tariff = session.query(Tariff).get(tariff_id)
    return tariff


def get_tariffs(is_all=False, session=None) -> List[Tariff]:
    if session is None:
        with Session() as session:
            tariffs_list = session.query(Tariff)

            if is_all is not None:
                if is_all is False:
                    tariffs_list = tariffs_list.filter(Tariff.is_removed == False)

            tariffs_list = tariffs_list.order_by(Tariff.index).all()
    else:
        tariffs_list = session.query(Tariff)

        if is_all is not None:
            if is_all is False:
                tariffs_list = tariffs_list.filter(Tariff.is_removed == False)

        tariffs_list = tariffs_list.order_by(Tariff.index).all()
    return tariffs_list


def create_tariff(name: str, icon_uuid: str, base_distance, base_cost, cost_day, cost_night, cost_city_day, cost_city_night,
                  free_waiting, cost_waiting, base_distance_night, base_cost_night) -> Tariff:
    if len(name) == 0:
        raise IncorrectDataValue('Укажите название тарифа')

    if base_distance < 0:
        raise IncorrectDataValue('Расстояние посадки не может быть меньше 0')
    if base_cost < 0:
        raise IncorrectDataValue('Цена посадки не может быть меньше 0')
    if base_distance_night < 0:
        raise IncorrectDataValue('Расстояние посадки (ночь) не может быть меньше 0')
    if base_cost_night < 0:
        raise IncorrectDataValue('Цена посадки (ночь) не может быть меньше 0')
    if cost_day < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if cost_night < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if cost_city_day < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if cost_city_night < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if free_waiting < 0:
        raise IncorrectDataValue('Бесплатное ожидание не может быть отрицательным')
    if cost_waiting < 0:
        raise IncorrectDataValue('Цена бесплатного ожидания не может быть отрицательной')

    with Session() as session:
        file = files.api.get_file_by_uuid(icon_uuid, session=session)
        if file is None:
            raise IncorrectDataValue('Загрузите иконку тарифа')

        tariff = Tariff(
            name=name,
            icon_uuid=icon_uuid,
            base_distance=base_distance,
            base_cost=base_cost,
            base_distance_night=base_distance_night,
            base_cost_night=base_cost_night,
            cost_by_km_day=cost_day,
            cost_by_km_night=cost_night,
            cost_city_by_km_day=cost_city_day,
            cost_city_by_km_night=cost_city_night,
            free_waiting=free_waiting,
            cost_waiting=cost_waiting
        )
        session.add(tariff)
        session.commit()

    update_indexes()
    return tariff


def edit_tariff(tariff_id, name: str, icon_uuid: str, base_distance, base_cost, cost_day, cost_night, cost_city_day, cost_city_night,
                  free_waiting, cost_waiting, base_distance_night, base_cost_night):
    if len(name) == 0:
        raise IncorrectDataValue('Укажите название тарифа')

    if base_distance < 0:
        raise IncorrectDataValue('Расстояние посадки не может быть меньше 0')
    if base_cost < 0:
        raise IncorrectDataValue('Цена посадки не может быть меньше 0')
    if base_distance_night < 0:
        raise IncorrectDataValue('Расстояние посадки (ночь) не может быть меньше 0')
    if base_cost_night < 0:
        raise IncorrectDataValue('Цена посадки (ночь) не может быть меньше 0')
    if cost_day < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if cost_night < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if cost_city_day < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if cost_city_night < 1:
        raise IncorrectDataValue('Цена за километр не может быть меньше 1')
    if free_waiting < 0:
        raise IncorrectDataValue('Бесплатное ожидание не может быть отрицательным')
    if cost_waiting < 0:
        raise IncorrectDataValue('Цена бесплатного ожидания не может быть отрицательной')

    with Session() as session:
        tariff = get_tariff_by_id(tariff_id, session=session)
        if tariff is None or tariff.is_removed:
            raise IncorrectDataValue('Тариф не найден')

        file = files.api.get_file_by_uuid(icon_uuid, session=session)
        if file is None:
            raise IncorrectDataValue('Загрузите иконку тарифа')

        tariff.name = name
        tariff.icon_uuid = icon_uuid
        tariff.base_distance = base_distance
        tariff.base_cost = base_cost
        tariff.base_distance_night = base_distance_night
        tariff.base_cost_night = base_cost_night
        tariff.cost_by_km_day = cost_day
        tariff.cost_by_km_night = cost_night
        tariff.cost_city_by_km_day = cost_city_day
        tariff.cost_city_by_km_night = cost_city_night
        tariff.free_waiting = free_waiting
        tariff.cost_waiting = cost_waiting

        session.commit()


def remove_tariff(tariff_id):
    with Session() as session:
        tariff = get_tariff_by_id(tariff_id, session=session)

        if tariff is None or tariff.is_removed:
            raise IncorrectDataValue('Тариф не найден')

        tariff.is_removed = True
        session.commit()


def update_indexes(ids=None):
    with Session() as session:
        tariffs_list = get_tariffs(session=session)
        if len(tariffs_list) == 0:
            return

        if ids is None:
            for i in range(0, len(tariffs_list)):
                tariffs_list[i].index = i
        else:
            for i in range(0, len(tariffs_list)):
                step = utils.get_entity_by_id(ids[i], tariffs_list)
                step.index = i

        session.commit()