from enum import Enum


class DriverStatus(Enum):
    OFFLINE = 'Не на линии'
    ONLINE = 'На линии'
    ACTIVE = 'На заказе'
