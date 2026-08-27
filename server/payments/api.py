from typing import List, Union
from db import Session
from .entities import *
from .models import *
from errors import *

import datetime
import drivers
import settings
import yookassa


def get_payment_by_id(payment_id, session=None) -> Payment | None:
    if session is None:
        with Session() as session:
            payment = session.query(Payment).get(payment_id)
    else:
        payment = session.query(Payment).get(payment_id)
    return payment


def get_payment_by_pay_token(pay_token, session=None) -> Payment | None:
    if session is None:
        with Session() as session:
            payment = session.query(Payment).filter(Payment.pay_token == pay_token).first()
    else:
        payment = session.query(Payment).filter(Payment.pay_token == pay_token).first()
    return payment


def get_payments(status: Union[int, None] = None, session=None) -> List[Payment]:
    if session is None:
        with Session() as session:
            payments_list = session.query(Payment)

            if status:
                payments_list = payments_list.filter(Payment.status == status)

            payments_list = payments_list.all()
    else:
        payments_list = session.query(Payment)

        if status:
            payments_list = payments_list.filter(Payment.status == status)

        payments_list = payments_list.all()
    return payments_list


def create_payment(driver_id, tariff_id):
    model = settings.get_model()

    tariff = None
    for _tariff in model.driver_tariffs:
        if _tariff.id == tariff_id:
            tariff = _tariff
            break

    if tariff is None:
        raise IncorrectDataValue('Укажите корректный ID тарифа')

    description = f'Оплата подписки по тарифу \"{tariff.name}\"'

    with Session() as session:
        driver = drivers.api.get_driver_by_id(driver_id, session=session)
        pay_token, payment_url = yookassa.create_payment(tariff.cost, description, driver.phone)

        payment = Payment(pay_token=pay_token, payment_url=payment_url, driver_id=driver_id, amount=tariff.cost,
                          tariff_hours=tariff.hours, tariff_name=tariff.name)
        session.add(payment)
        session.commit()
    return get_payment_by_pay_token(pay_token)


def approve_payment(pay_token, status: bool):
    with Session() as session:
        payment = get_payment_by_pay_token(pay_token, session)

        if payment is None:
            raise IncorrectDataValue('Платеж не найден')

        if status:
            payment.status = 10
            payment.finished_at = datetime.datetime.now()

            driver = drivers.api.get_driver_by_id(payment.driver_id, session=session)

            if driver.subscribe_expiration is None:
                driver.subscribe_expiration = datetime.datetime.now()
            elif driver.subscribe_expiration < datetime.datetime.now():
                driver.subscribe_expiration = datetime.datetime.now()

            driver.subscribe_expiration += datetime.timedelta(hours=payment.tariff_hours)
        else:
            if payment.status != 0:
                raise IncorrectDataValue('Неверный статус')
            payment.status = -10
            payment.finished_at = datetime.datetime.now()

        session.commit()