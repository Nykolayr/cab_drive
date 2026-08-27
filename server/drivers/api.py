from flask_jwt_extended import create_access_token
from sqlalchemy.orm.attributes import flag_modified
from geoalchemy2.shape import from_shape
from geoalchemy2.shape import to_shape
from geoalchemy2.functions import ST_DistanceSphere, ST_GeomFromText
from shapely.geometry import Point
from typing import List, Tuple
from faker import Faker
from db import Session
from .entities import *
from .models import *
from errors import *
from logger import logger

import requests
import config
import utils
import random
import tariffs
import datetime
import enums
import trips
import geo
import users
import notify


def get_driver_by_id(driver_id, is_blocking: bool = False, session=None) -> Driver | None:
    if session is None:
        with Session() as session:
            driver = session.query(Driver).filter(Driver.id == driver_id)
            if is_blocking:
                driver = driver.with_for_update()
            driver = driver.first()
    else:
        driver = session.query(Driver).filter(Driver.id == driver_id)
        if is_blocking:
            driver = driver.with_for_update()
        driver = driver.first()
    return driver


def get_driver_by_phone(phone, session=None) -> Driver | None:
    if session is None:
        with Session() as session:
            driver = session.query(Driver).filter(Driver.phone == phone, Driver.is_removed == False).first()
    else:
        driver = session.query(Driver).filter(Driver.phone == phone, Driver.is_removed == False).first()
    return driver


def get_drivers(is_all=False, conditions_list=[], session=None) -> List[Driver]:
    if session is None:
        with Session() as session:
            drivers_list = session.query(Driver)

            if is_all is not None and is_all is not True:
                drivers_list = drivers_list.filter(Driver.is_removed == False)

            if is_all is not None:
                if is_all is False:
                    drivers_list = drivers_list.filter(Driver.is_blocked == False)

            if len(conditions_list) > 0:
                for condition in conditions_list:
                    drivers_list = drivers_list.filter(condition)

            drivers_list = drivers_list.all()
    else:
        drivers_list = session.query(Driver)

        if is_all is not None and is_all is not True:
            drivers_list = drivers_list.filter(Driver.is_removed == False)

        if is_all is not None:
            if is_all is False:
                drivers_list = drivers_list.filter(Driver.is_blocked == False)

        if len(conditions_list) > 0:
            for condition in conditions_list:
                drivers_list = drivers_list.filter(condition)

        drivers_list = drivers_list.all()

    return drivers_list


def create_driver(model: CreateDriverModel) -> Driver:
    with Session() as session:
        phone = utils.telephone(model.phone)
        check = get_driver_by_phone(phone, session=session)

        if check is not None:
            raise IncorrectDataValue('Водитель с таким номером телефона уже существует')

        password = str(random.randint(10000, 99999))

        driver = Driver(
            password=password,
            phone=phone,
            name=model.name,
            second_name=model.second_name,
            surname=model.surname,
            car_brand=model.car.brand,
            car_model=model.car.model,
            car_color=model.car.color,
            car_numberplate=model.car.numberplate
        )

        session.add(driver)
        session.commit()
    return driver


def generate_fake_objects(n: int):
    fake = Faker("ru_RU")
    objects = []

    car_brands_models = {
        "Toyota": ["Camry", "Corolla", "RAV4", "Land Cruiser"],
        "BMW": ["X5", "X6", "3 Series", "5 Series"],
        "Mercedes": ["C-Class", "E-Class", "GLC", "GLE"],
        "Lada": ["Vesta", "Granta", "Niva", "XRAY"],
        "Hyundai": ["Solaris", "Elantra", "Tucson", "Santa Fe"]
    }

    colors = ["Белый", "Чёрный", "Серый", "Синий", "Красный", "Зелёный", "Жёлтый"]

    def generate_license_plate():
        letters = "АВЕКМНОРСТУХ"
        return f"{random.choice(letters)}{random.randint(100, 999)}{random.choice(letters)}{random.choice(letters)}{random.randint(10, 99)}"

    for _ in range(n):
        gender = random.choice(["male", "female"])
        if gender == "male":
            last_name = fake.last_name_male()
            first_name = fake.first_name_male()
            middle_name = fake.middle_name_male()
        else:
            last_name = fake.last_name_female()
            first_name = fake.first_name_female()
            middle_name = fake.middle_name_female()

        phone_number = fake.phone_number()

        car_brand = random.choice(list(car_brands_models.keys()))
        car_model = random.choice(car_brands_models[car_brand])
        car_color = random.choice(colors)
        license_plate = generate_license_plate()

        latitude = random.uniform(51.631707, 51.713677)
        longitude = random.uniform(39.141628, 39.310543)

        objects.append({
            "phone": phone_number,
            "last_name": last_name,
            "first_name": first_name,
            "middle_name": middle_name,
            "car_brand": car_brand,
            "car_model": car_model,
            "car_color": car_color,
            "license_plate": license_plate,
            "coordinates": (latitude, longitude)
        })

    return objects

def edit_driver(model: EditDriverModel):
    with Session() as session:
        driver = get_driver_by_id(model.id, session=session, is_blocking=True)
        if driver is None:
            raise IncorrectDataValue('Водитель не найден')

        model.phone = utils.telephone(model.phone)
        if driver.phone != model.phone:
            check = get_driver_by_phone(model.phone, session=session)
            if check is not None:
                raise IncorrectDataValue('Такой номер телефона уже используется в системе')

        if model.photo_uuid is None or len(model.photo_uuid) == 0:
            model.photo_uuid = None

        values = model.model_dump()

        for key in values:
            setattr(driver, key, values[key])

        session.commit()


def save_tariffs(driver_id, tariffs_dict):
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise IncorrectDataValue('Водитель не найден')

        tariffs_list = tariffs.api.get_tariffs(session=session)

        result = []

        for tariff in tariffs_list:
            status = tariffs_dict.get(str(tariff.id))
            if status is None or status is False:
                result.append(TariffStatusModel(id=tariff.id, name=tariff.name, status=False, driver_status=False))
            else:
                result.append(
                    TariffStatusModel(
                        id=tariff.id,
                        name=tariff.name,
                        status=True,
                        driver_status=get_driver_tariff_status(
                            driver=driver,
                            tariff_id=tariff.id
                        )
                    )
                )

        driver.tariffs_json = [t.model_dump() for t in result]

        flag_modified(driver, 'tariffs_json')
        session.commit()


def save_docs(driver_id, docs: List[DriverDoc]):
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise IncorrectDataValue('Водитель не найден')

        driver.documents_json = utils.to_json([d.model_dump() for d in docs])

        flag_modified(driver, 'documents_json')
        session.commit()


def api_auth(model: AuthDriverRequest) -> Tuple[Driver, str]:
    with Session() as session:
        phone = utils.telephone(model.phone)
        if phone is None:
            raise IncorrectDataValue('Введите корректный номер телефона')

        driver = session.query(Driver).filter(Driver.phone == phone, Driver.password == model.password).first()
        if driver is None:
            raise IncorrectDataValue('Неверный логин или пароль')

    access_token = create_access_token(
        identity={
            'account_type': 'driver',
            'id': driver.id
        },
        expires_delta=datetime.timedelta(days=365)
    )
    return driver, access_token


def api_get_me(driver_id) -> Driver:
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session)
    return driver


def api_append_payment_method(driver_id, model: ChangePaymentMethod) -> Driver:
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise AuthEmptyException()

        if model.payment_method_code not in driver.payment_methods:
            driver.payment_methods.append(model.payment_method_code)
            flag_modified(driver, 'payment_methods')
            session.commit()
    return driver


def api_remove_payment_method(driver_id, model: ChangePaymentMethod) -> Driver:
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise AuthEmptyException()

        if model.payment_method_code in driver.payment_methods:
            driver.payment_methods.remove(model.payment_method_code)
            flag_modified(driver, 'payment_methods')
            session.commit()
    return driver


def api_change_tariff(driver_id, model: ChangeTariff) -> Driver:
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise AuthEmptyException()

        check = False
        for tariff in driver.tariffs:
            if tariff.id == model.tariff_id:
                if tariff.status is False:
                    raise IncorrectDataValue('Вам недоступен этот тариф')
                tariff.driver_status = model.status
                check = True
                break

        if check is False:
            raise IncorrectDataValue('Некорректный ID тарифа')

        driver.tariffs_json = [t.model_dump() for t in driver.tariffs]
        flag_modified(driver, 'tariffs_json')
        session.commit()
    return driver


def get_driver_tariff_status(driver: Driver, tariff_id: int) -> bool:
    for tariff in driver.tariffs:
        if tariff.id == tariff_id:
            return tariff.driver_status
    return False


def api_set_status(driver_id: int, status: Literal['offline', 'online']) -> Driver:
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise AuthEmptyException()

        if driver.status == enums.DriverStatus.ACTIVE:
            raise IncorrectDataValue('Пока вы находитесь на заказе, вы не можете менять статус')

        if status == 'offline':
            if driver.status == enums.DriverStatus.ONLINE:
                driver.status = enums.DriverStatus.OFFLINE
        elif status == 'online':
            if driver.check_expiration() is False:
                raise IncorrectDataValue('Оплатите подписку')
            if driver.status == enums.DriverStatus.OFFLINE:
                driver.status = enums.DriverStatus.ONLINE

        session.commit()
    return driver


def api_update_last_position(driver_id: int, model: UpdatePosition) -> Driver:
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session, is_blocking=True)
        if driver is None:
            raise AuthEmptyException()

        driver.last_position = from_shape(
            Point(model.point.latitude, model.point.longitude),
            srid=4326
        )
        driver.last_point_updated = datetime.datetime.now()
        logger.info('DRIVER_POSITION_UPDATED:{}:{},{}'.format(driver_id, model.point.latitude, model.point.longitude))

        Driver.send_position(driver.id, model.point)

        if driver.status == enums.DriverStatus.ACTIVE and driver.current_trip_id is not None:
            trip = trips.api.get_trip_by_id(driver.current_trip_id, session=session)
            dist = None
            if trip.status < 4:
                dist = geo.api.get_distance(model.point, trip.s_position)
            else:
                dist = geo.api.get_distance(model.point, trip.f_position)

            users.User.send_ws(
                user_id=trip.user_id,
                event='driverPositionUpdated',
                data={
                    'point': model.point.model_dump(),
                    'distance': dist.model_dump() if dist is not None else None
                },
                description='Местоположение водителя обновлено'
            )

            # distance = geo.api.get_distance(model.point, trip.f_position)
            if dist is not None:
                Driver.send_ws(
                    driver_id=driver.id,
                    event='geoUpdated',
                    data={
                        'distance': dist.model_dump()
                    },
                    description='Обновление навигации'
                )

        session.commit()
    return driver


def generate_fakes(count):
    fake_drivers = generate_fake_objects(count)
    drivers = []

    for data in fake_drivers:
        phone = data['phone']
        if phone is None:
            continue
        driver = Driver(
            phone=utils.telephone(phone),
            password=str(random.randint(10000, 99999)),
            name=data['first_name'],
            second_name=data['middle_name'],
            surname=data['last_name'],
            car_brand=data['car_brand'],
            car_model=data['car_model'],
            car_color=data['car_color'],
            car_numberplate=data['license_plate'],
            last_position=from_shape(Point(data['coordinates'][0], data['coordinates'][1]), srid=4326),
            status=enums.DriverStatus.ONLINE
        )
        drivers.append(driver)

    with Session() as session:
        session.bulk_save_objects(drivers)
        session.commit()


def get_nearby_drivers(point: models.PointModel, radius_km: float, conditions_list=[], session=None) -> List[Driver]:
    point_wkt = f'POINT({point.latitude} {point.longitude})'
    radius_m = radius_km * 1000

    if session is None:
        with Session() as session:
            query = session.query(
                Driver,
                ST_DistanceSphere(Driver.last_position, ST_GeomFromText(point_wkt, 4326)).label("distance")
            ).filter(
                ST_DistanceSphere(
                    Driver.last_position,
                    ST_GeomFromText(point_wkt, 4326)) <= radius_m
            )

            if len(conditions_list) > 0:
                for condition in conditions_list:
                    query = query.filter(condition)

            query = query.order_by("distance")

            results = query.all()
    else:
        query = session.query(
            Driver,
            ST_DistanceSphere(Driver.last_position, ST_GeomFromText(point_wkt, 4326)).label("distance")
        ).filter(
            ST_DistanceSphere(
                Driver.last_position,
                ST_GeomFromText(point_wkt, 4326)) <= radius_m
        )

        if len(conditions_list) > 0:
            for condition in conditions_list:
                query = query.filter(condition)

        query = query.order_by("distance")

        results = query.all()

    drivers_list = []
    for result in results:
        result[0].distance = result[1]
        drivers_list.append(result[0])

    return drivers_list


def update_rating(driver_id):
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session)
        if driver is None:
            return

        rating_info = trips.api.get_driver_rating(session, driver_id)

        driver.rating = rating_info['rating']
        driver.trips_count = rating_info['count']
        session.commit()


def get_online() -> List[int]:
    url = '{}/online'.format(config.Production.TROIKA_S_BASE_URL)

    try:
        response = requests.get(url)
    except:
        return []

    if response.status_code != 200:
        return []

    return response.json()


def remove_driver(driver_id):
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session)
        if driver is None:
            raise IncorrectDataValue('Водитель не найден')

        driver.is_removed = True
        session.commit()


def set_photo(driver_id, photo_uuid):
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session)
        if driver is None:
            raise IncorrectDataValue('Водитель не найден')

        driver.photo_uuid = photo_uuid
        session.commit()
    return driver


def set_fcm_token(driver_id, fcm_token):
    with Session() as session:
        driver = get_driver_by_id(driver_id, session=session)
        if driver is None:
            raise IncorrectDataValue('driver не найден')

        res = notify.push_service.subscribe_to_topic([fcm_token], 'all')
        if 'error' in res:
            raise IncorrectDataValue(res['error'])
        if res['success_count'] == 0:
            raise IncorrectDataValue('Укажите корректный FCM токен')

        driver.fcm_token = fcm_token
        session.commit()
    return driver