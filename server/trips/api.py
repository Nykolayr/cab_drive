from typing import List
from sqlalchemy.orm.attributes import flag_modified
from sqlalchemy import func
from sqlalchemy import or_, and_
from shapely.geometry import Point
from geoalchemy2.shape import from_shape
from db import Session
from .entities import *
from errors import *
from .models import *
from uuid import uuid4
from .table_handlers import TripsTableHandler

import traceback
import datetime
import tariffs
import drivers
import users
import geo
import cache
import utils
import json
import enums
import settings


def get_trip_by_id(trip_id, is_blocking: bool = False, session=None) -> Trip | None:
    if session is None:
        with Session() as session:
            trip = session.query(Trip).filter(Trip.id == trip_id)
            if is_blocking:
                trip = trip.with_for_update()
            trip = trip.first()

        if trip is not None and trip.driver_id is not None:
                trip._driver = drivers.api.get_driver_by_id(trip.driver_id)

    else:
        trip = session.query(Trip).filter(Trip.id == trip_id)
        if is_blocking:
            trip = trip.with_for_update()
        trip = trip.first()

        if trip is not None and trip.driver_id is not None:
            trip._driver = drivers.api.get_driver_by_id(trip.driver_id)
    return trip


def get_trips(conditions_list, session=None) -> List[Trip]:
    if session is None:
        with Session() as session:
            trips_list = session.query(Trip)

            if len(conditions_list) > 0:
                for condition in conditions_list:
                    trips_list = trips_list.filter(condition)

            trips_list = trips_list.all()
    else:
        trips_list = session.query(Trip)

        if len(conditions_list) > 0:
            for condition in conditions_list:
                trips_list = trips_list.filter(condition)

        trips_list = trips_list.all()
    return trips_list


def get_trips_by_operator_id(operator_id) -> List[Trip]:
    with Session() as session:
        min_date = datetime.datetime.now() - datetime.timedelta(hours=4)
        trips_list = session.query(Trip).filter(
            Trip.operator_id == operator_id,
            or_(
                Trip.finished_at == None,
                Trip.finished_at >= min_date
            )
        ).all()
    return trips_list


def calculate_trip(model: CalculateTripRequest) -> List[TripCalculation]:
    distance = geo.api.get_distance(model.start_point, model.finish_point)
    setting = settings.get_model()
    distance_city = setting.route_length_in_cities(distance.geometry)
    distance.distance_city = int(distance_city)

    with Session() as session:
        tariffs_list = tariffs.api.get_tariffs(session=session)

        pickup_model = GetPickupTimeRequest(
            tariff_ids=[tariff.id for tariff in tariffs_list],
            point=model.start_point
        )

        pickup_times = geo.api.get_pickup_time(pickup_model)

    results: List[TripCalculation] = []

    for pickup in pickup_times:
        if distance is None:
            calculation = TripCalculation(
                tariff_id=pickup.tariff_id,
                tariff_name=pickup.tariff_name,
                start_point=model.start_point,
                finish_point=model.finish_point,
            )
        else:
            tariff = utils.get_entity_by_id(pickup.tariff_id, tariffs_list)
            if tariff is None:
                continue

            calculation = TripCalculation(
                calculation_token=str(uuid4()),
                tariff_id=pickup.tariff_id,
                tariff_name=pickup.tariff_name,
                pickup_time=pickup.pickup_time,
                trip_info=distance,
                start_point=model.start_point,
                finish_point=model.finish_point,
                cost=tariff.calculate_trip_cost(distance.distance - distance_city, distance_city=distance_city)
            )
            calc_dump = json.dumps(utils.to_json(calculation.model_dump()))
            cache.set_cache('calc', calculation.calculation_token, calc_dump, minutes=1)
        results.append(calculation)
    return results


def create_trip(user_id: int, model: CreateTripRequest) -> Trip:
    calculation_str = cache.get_cache('calc', model.calculation_token)
    if calculation_str is None:
        raise IncorrectDataValue('Расчёт стоимости не найден')
    
    calculation = TripCalculation.model_validate(json.loads(calculation_str))
    
    with Session() as session:
        operator_id = None
        
        user = users.api.get_user_by_id(user_id, session=session)
        if user is None:
            raise AuthEmptyException()
        
        if user.account_type > 0 and model.client_phone:
            phone = utils.telephone(model.client_phone)
            user = users.api.get_user_by_phone(phone, session=session)
            if user is None:
                user = users.api.create_user_by_phone(phone)

            operator_id = user_id
            if user is None:
                raise IncorrectDataValue('Пользователь не найден')

        check = get_trips([
            Trip.user_id == user.id,
            Trip.is_finished == False
        ], session=session)
        if len(check) > 0:
            if operator_id:
                raise IncorrectDataValue('У клиента уже есть активный заказ')
            else:
                raise IncorrectDataValue('У вас уже есть активный заказ')
        
        start_point = geo.api.get_geo_info_by_two_gis(calculation.start_point)
        start_description = ''
        if len(start_point.results) > 0:
            start_description = '{} {}'.format(start_point.results[0].location, start_point.results[0].name)
        
        finish_point = geo.api.get_geo_info_by_two_gis(calculation.finish_point)
        finish_description = ''
        if len(finish_point.results) > 0:
            finish_description = '{} {}'.format(finish_point.results[0].location, finish_point.results[0].name)

        search_expiration = datetime.datetime.now() + datetime.timedelta(minutes=5)
            
        trip = Trip(
            user_id=user.id,
            start_position=from_shape(Point(calculation.start_point.latitude, calculation.start_point.longitude), srid=4326),
            start_position_description=start_description,
            finish_position=from_shape(Point(calculation.finish_point.latitude, calculation.finish_point.longitude), srid=4326),
            finish_position_description=finish_description,
            distance=calculation.trip_info.distance,
            cost=calculation.cost,
            payment_method=model.payment_method,
            tariff_id=calculation.tariff_id,
            client_comment=model.comment,
            geometry=calculation.trip_info.geometry,
            search_expiration=search_expiration,
            client_phone=user.phone,
            operator_id=operator_id,
            distance_city=calculation.trip_info.distance_city,
        )
        session.add(trip)
        session.commit()

        session.add(create_event(trip.id, 'Заказ создан'))
        session.commit()
    return trip



def create_event(trip_id, event) -> TripEvent:
    return TripEvent(trip_id=trip_id, event=event)


def get_active_trip(user_id: int | None = None, driver_id: int | None = None) -> Trip | None:
    with Session() as session:
        if user_id is not None:
            conditions_list = [Trip.user_id == user_id, Trip.is_finished == False, Trip.status != 10, Trip.status != -10]
        else:
            conditions_list = [Trip.driver_id == driver_id, Trip.is_finished == False, Trip.status != 10, Trip.status != -10]

        trips_list = get_trips(conditions_list, session=session)

    if len(trips_list) == 0:
        return None

    return trips_list[0]


def processing():
    conditions_list = [
        Trip.status.in_([0, 1]),
        Trip.is_finished == False
    ]
    trips_list = get_trips(conditions_list)

    for trip in trips_list:
        try:
            processing_trip(trip.id)
        except:
            print(traceback.format_exc())
            continue


def processing_trip(trip_id):
    print(f'[TripID {trip_id}] Старт процессинг')
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None or trip.status not in [0, 1] or trip.is_finished:
            print(f'[TripID {trip_id}] поездка не найдена, или неверный статус или завершена')
            return

        if trip.status == 0:
            online_drivers = drivers.api.get_online()

            now = datetime.datetime.now()

            driver_conditions = [
                drivers.Driver.status == enums.DriverStatus.ONLINE,
                drivers.Driver.is_removed == False,
                drivers.Driver.subscribe_expiration >= now,
                drivers.Driver.current_trip_id == None,
                drivers.Driver.id.not_in(trip.exclude_drivers),
                drivers.Driver.id.in_(online_drivers)
            ]

            drivers_list = drivers.api.get_nearby_drivers(
                point=trip.s_position,
                radius_km=trip.search_radius,
                conditions_list=driver_conditions,
                session=session
            )

            drivers_list = list(
                filter(
                    lambda driver:
                    drivers.api.get_driver_tariff_status(driver, trip.tariff_id) and trip.payment_method in driver.payment_methods,
                    drivers_list
                )
            )

            if len(drivers_list) == 0:
                if check_expiration_trip(trip, session):
                    session.commit()
                    return

                radius_cnt = cache.get_cache('radius', trip.id, int)
                if radius_cnt is None:
                    radius_cnt = 0

                if radius_cnt < 1:
                    text = 'Водителей в радиусе {} км не найдено. Увеличили радиус поиска на 5 километров'.format(trip.search_radius)
                    session.add(create_event(trip.id, text))
                    trip.search_radius += 5
                    cache.set_cache('radius', trip.id, radius_cnt + 1)
                else:
                    text = 'Водителей в радиусе {} км не найдено. Радиус поиска не увеличили'.format(trip.search_radius)
                    session.add(create_event(trip.id, text))

                session.commit()
                return

            if len(drivers_list) > 5:
                drivers_list = drivers_list[:5]

            distances = geo.api.get_distances(drivers_list, trip.s_position)

            if len(distances) == 0:
                if check_expiration_trip(trip, session):
                    session.commit()
                    return

                radius_cnt = cache.get_cache('radius', trip.id, int)
                if radius_cnt is None:
                    radius_cnt = 0

                if radius_cnt < 4:
                    text = 'Не удалось построить маршрут для водителей: {}. Увеличили радиус поиска на 5 километров'.format(drivers_list)
                    session.add(create_event(trip.id, text))
                    trip.search_radius += 5
                    cache.set_cache('radius', trip.id, radius_cnt + 1)
                else:
                    text = 'Не удалось построить маршрут для водителей: {}. Радиус поиска не увеличивали'.format(
                        drivers_list)
                    session.add(create_event(trip.id, text))

                session.commit()
                return

            distance = distances[0]

            driver: drivers.Driver = utils.get_entity_by_id(distance.driver_id, drivers_list)
            driver.current_trip_id = trip.id

            trip.driver_id = distance.driver_id
            trip.driver_accept_expiration = datetime.datetime.now() + datetime.timedelta(seconds=20)
            trip.status = 1
            trip._driver = driver

            driver.send_socket(
                event='tripOffer',
                description='Новый заказ',
                data={
                    'trip': trip.schema(),
                    'distance_for_client': distance.model_dump()
                }
            )
            users.User.send_ws(
                user_id=trip.user_id,
                event='tripUpdated',
                description='Заказ обновлён',
                data={
                    'trip': trip.schema(),
                    'driver': driver.schema()
                }
            )

            session.add(create_event(trip.id, 'Заказ предложен водителю ID: {}'.format(driver.id)))
            session.commit()
            return
        elif trip.status == 1:
            now = datetime.datetime.now()

            if now >= trip.driver_accept_expiration:
                driver = drivers.api.get_driver_by_id(trip.driver_id, session=session, is_blocking=True)
                driver.current_trip_id = None

                trip.driver_id = None
                trip.exclude_drivers.append(driver.id)
                trip.driver_accept_expiration = None
                trip.status = 0
                trip._driver = None

                flag_modified(trip, 'exclude_drivers')

                users.User.send_ws(
                    user_id=trip.user_id,
                    event='tripUpdated',
                    description='Заказ обновлён',
                    data={
                        'trip': trip.schema(),
                        'driver': None
                    }
                )

                session.add(create_event(trip.id, 'Водитель ID: {} не ответил на запрос принятия заказа. Повторно запущен поиск водителя'.format(driver.id)))
                session.commit()

                return processing_trip(trip.id)


def check_expiration_trip(trip: Trip, session: Session) -> bool:
    now = datetime.datetime.now()
    if now >= trip.search_expiration:
        trip.status = -10
        trip.cancel_comment = 'Не удалось найти водителя'
        trip.is_finished = True
        trip.finished_at = now

        users.User.send_ws(
            user_id=trip.user_id,
            event='tripFinished',
            description='Заказ завершен',
            data={
                'trip': trip.schema(),
            }
        )

        session.add(create_event(trip.id, 'Заказ отменён, так как не удалось найти водителя в течение пяти минут'))
        return True
    return False


def cancel_trip_by_admin(user, trip_id):
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Заказ не найден')
        if trip.is_finished:
            raise IncorrectDataValue('Заказ уже был завершен ранее')

        if user.account_type == 1 and trip.operator_id != user.id:
            raise IncorrectDataValue('Ошибка доступа')

        if trip.driver_id is not None:
            driver = drivers.api.get_driver_by_id(trip.driver_id, session=session, is_blocking=True)
            driver.current_trip_id = None
            driver.status = enums.DriverStatus.ONLINE

            driver.send_socket(
                event='tripFinished',
                description='Поездка завершена',
                data={
                    'trip': trip.schema()
                }
            )

        trip.status = -10
        trip.cancel_comment = 'Поездка отменена администратором'
        trip.is_finished = True
        trip.finished_at = datetime.datetime.now()

        users.User.send_ws(
            user_id=trip.user_id,
            event='tripFinished',
            description='Заказ завершен',
            data={
                'trip': trip.schema(),
            }
        )

        session.add(create_event(trip.id, 'Администратор отменил поездку'))
        session.commit()

def cancel_trip(trip_id, user_id: int | None = None, driver_id: int | None = None) -> Trip:
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Заказ не найден')
        if trip.is_finished:
            raise IncorrectDataValue('Заказ уже был завершен ранее')

        if driver_id is not None:
            driver = drivers.api.get_driver_by_id(driver_id, session=session, is_blocking=True)
            if driver.id != trip.driver_id:
                raise IncorrectDataValue('Ошибка доступа')

            if trip.status == 1:
                driver.current_trip_id = None

                trip.driver_id = None
                trip.exclude_drivers.append(driver.id)
                trip.driver_accept_expiration = None
                trip.status = 0
                trip._driver = None

                flag_modified(trip, 'exclude_drivers')

                users.User.send_ws(
                    user_id=trip.user_id,
                    event='tripUpdated',
                    description='Заказ обновлён',
                    data={
                        'trip': trip.schema(),
                        'driver': None
                    }
                )

                session.add(create_event(trip.id,
                                         'Водитель ID: {} отказался от принятия заказа. Повторно запущен поиск водителя'.format(
                                             driver.id)))
                session.commit()
                return trip
            elif trip.status in [2, 3]:
                driver.status = enums.DriverStatus.ONLINE
                driver.current_trip_id = None

                trip.driver_id = None
                trip._driver = None
                trip.exclude_drivers.append(driver.id)
                trip.driver_accept_expiration = None
                # trip.search_expiration = datetime.datetime.now() + datetime.timedelta(minutes=5)
                trip.status = -10
                trip.is_finished = True

                users.User.send_ws(
                    user_id=trip.user_id,
                    event='tripFinished',
                    description='Заказ завершен',
                    data={
                        'trip': trip.schema(),
                    }
                )

                flag_modified(trip, 'exclude_drivers')

                session.add(create_event(trip.id,
                                         'Водитель ID: {} снялся с заказа. Заказ отменён'.format(
                                             driver.id)))
                session.commit()
                return trip
            else:
                raise IncorrectDataValue('Неверный статус заказа')

        elif user_id is not None:
            if user_id != trip.user_id:
                raise IncorrectDataValue('Ошибка доступа')
            if trip.status == 0:
                trip.driver_id = None
                trip.driver_accept_expiration = None
                trip.status = -10
                trip.cancel_comment = 'Поездка отменена клиентом'
                trip.is_finished = True
                trip.finished_at = datetime.datetime.now()

                users.User.send_ws(
                    user_id=trip.user_id,
                    event='tripFinished',
                    description='Заказ завершен',
                    data={
                        'trip': trip.schema(),
                    }
                )

                session.add(create_event(trip.id, 'Клиент отменил поездку'))
                session.commit()
                return trip
            elif trip.status in [1, 2, 3]:
                driver = drivers.api.get_driver_by_id(trip.driver_id, session=session, is_blocking=True)

                driver.status = enums.DriverStatus.ONLINE
                driver.current_trip_id = None

                trip.status = -10
                trip.cancel_comment = 'Поездка отменена клиентом'
                trip.is_finished = True
                trip.finished_at = datetime.datetime.now()

                driver.send_socket(
                    event='tripFinished',
                    description='Поездка завершена',
                    data={
                        'trip': trip.schema()
                    }
                )

                users.User.send_ws(
                    user_id=trip.user_id,
                    event='tripFinished',
                    description='Заказ завершен',
                    data={
                        'trip': trip.schema(),
                    }
                )

                session.add(create_event(trip.id, 'Клиент отменил поездку'))
                session.commit()
                return trip
            else:
                raise IncorrectDataValue('Неверный статус заказа')


def accept_trip(driver_id: int, trip_id) -> Trip:
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Поездка не найдена')

        driver = drivers.api.get_driver_by_id(driver_id, session=session, is_blocking=True)

        if trip.driver_id != driver.id:
            raise IncorrectDataValue('Ошибка доступа')

        if trip.status == 1:
            trip.status = 2
            trip._driver = driver
            driver.status = enums.DriverStatus.ACTIVE

        users.User.send_ws(
            user_id=trip.user_id,
            event='tripUpdated',
            description='Заказ обновлен',
            data={
                'trip': trip.schema(),
                'driver': driver.schema()
            }
        )

        session.add(create_event(trip.id, 'Водитель ID: {} принял заказ'.format(driver.id)))
        session.commit()
    return trip


def next_status_trip(driver_id: int, trip_id) -> Trip:
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Поездка не найдена')

        driver = drivers.api.get_driver_by_id(driver_id, session=session, is_blocking=True)

        if trip.driver_id != driver.id:
            raise IncorrectDataValue('Ошибка доступа')

        if trip.status == 2:
            trip.status = 3
            trip.boarding_at = datetime.datetime.now()
            session.add(create_event(trip.id, 'Водитель ID: {} приехал на заказ'.format(driver.id)))
        elif trip.status == 3:
            trip.status = 4
            session.add(create_event(trip.id, 'Водитель ID: {} начал поездку'.format(driver.id)))

            if trip.boarding_at:
                additional_waiting(trip, session=session)
        elif trip.status == 4:
            trip.status = 10
            trip.is_finished = True
            trip.finished_at = datetime.datetime.now()
            trip.duration = (trip.finished_at - trip.created_at).seconds
            driver.status = enums.DriverStatus.ONLINE
            driver.current_trip_id = None
            session.add(create_event(trip.id, 'Водитель ID: {} завершил поездку'.format(driver.id)))

            if trip.paid_waiting_cost > 0:
                trip.cost += trip.paid_waiting_cost
                session.add(create_event(trip.id, 'К стоимости поездки прибавлено {} ₽ за платное ожидание {} сек'.format(
                    trip.paid_waiting_cost, trip.paid_waiting_seconds
                )))
        else:
            raise IncorrectDataValue('Неверный статус')

        users.User.send_ws(
            user_id=trip.user_id,
            event='tripUpdated',
            description='Заказ обновлен',
            data={
                'trip': trip.schema(),
                'driver': driver.schema()
            }
        )

        session.commit()
    return trip


def set_score(user_id: int, trip_id: int, score: float) -> Trip:
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Заказ не найден')
        if trip.user_id != user_id:
            raise IncorrectDataValue('Ошибка доступа')
        if trip.is_finished is False:
            raise IncorrectDataValue('Заказ не завершен')
        if trip.rating is not None:
            raise IncorrectDataValue('Вы уже оценивали этот заказ')

        trip.rating = score
        session.commit()

    drivers.api.update_rating(trip.driver_id)
    return trip


def get_driver_rating(session: Session, driver_id: int):
    result = session.query(
        func.coalesce(func.avg(Trip.rating), 0).label("average_rating"),
        func.count(Trip.id).label("trip_count")
    ).filter(
        Trip.driver_id == driver_id,
        Trip.is_finished == True,
        Trip.rating != None
    ).first()

    return {
        "rating": float(result.average_rating) if result.average_rating else 0.0,
        "count": result.trip_count
    }


def get_events(trip_id) -> List[TripEvent]:
    with Session() as session:
        events_list = session.query(TripEvent).filter(TripEvent.trip_id == trip_id).order_by(TripEvent.id).all()
    return events_list


def get_trips_by_user_id(user_id) -> List[Trip]:
    with Session() as session:
        trips_list = session.query(Trip).filter(
            Trip.user_id == user_id
        ).order_by(Trip.id.desc()).all()

        drivers_ids = [trip.driver_id for trip in trips_list if trip.driver_id is not None]
        drivers_list = drivers.api.get_drivers(
            is_all=True,
            conditions_list=[drivers.Driver.id.in_(drivers_ids)],
            session=session
        )
        drivers_dict = {driver.id: driver for driver in drivers_list}

        for trip in trips_list:
            if trip.driver_id is not None:
                trip.driver = drivers_dict.get(trip.driver_id, None)
            else:
                trip.driver = None
    return trips_list


def get_trips_by_driver_id(driver_id) -> List[Trip]:
    with Session() as session:
        trips_list = session.query(Trip).filter(
            Trip.driver_id == driver_id
        ).order_by(Trip.id.desc()).all()

    return trips_list


def create_trips_table_handler() -> TripsTableHandler:
    return TripsTableHandler(Trip)


def additional_waiting(trip: Trip, tariff=None, session: Session = None):
    if tariff is None:
        tariff = tariffs.api.get_tariff_by_id(trip.tariff_id, session=session)
    if tariff is None:
        return
    if trip.boarding_at is None:
        return

    duration = (datetime.datetime.now() - trip.boarding_at).seconds

    trip.boarding_at = None

    free_waiting = tariff.free_waiting * 60
    trip.paid_waiting_seconds += duration

    session.add(create_event(trip.id, 'Добавлено ожидание {} сек.'.format(duration)))

    if trip.paid_waiting_seconds > free_waiting:
        diff = trip.paid_waiting_seconds - free_waiting
        trip.paid_waiting_cost = int((diff / 60) * tariff.cost_waiting)
        session.add(create_event(trip.id, 'Пересчитана стоимость платного ожидания = {} ₽'.format(trip.paid_waiting_cost)))


def start_waiting(driver_id: int, trip_id) -> Trip:
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Поездка не найдена')

        if trip.status != 4:
            raise IncorrectDataValue('Неверный статус поездки')

        trip.boarding_at = datetime.datetime.now()
        session.commit()
    return trip


def stop_waiting(driver_id: int, trip_id) -> Trip:
    with Session() as session:
        trip = get_trip_by_id(trip_id, session=session, is_blocking=True)
        if trip is None:
            raise IncorrectDataValue('Поездка не найдена')

        if trip.status != 4:
            raise IncorrectDataValue('Неверный статус поездки')

        if trip.boarding_at is None:
            raise IncorrectDataValue('Платное ожидание не было включено')

        additional_waiting(trip, session=session)
        driver = drivers.api.get_driver_by_id(trip.driver_id, session=session)

        users.User.send_ws(
            user_id=trip.user_id,
            event='tripUpdated',
            description='Заказ обновлен',
            data={
                'trip': trip.schema(),
                'driver': driver.schema()
            }
        )

        session.commit()
    return trip