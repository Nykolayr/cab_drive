from typing import Dict
from decimal import Decimal
import redis
import config
import datetime

connection_pool = redis.ConnectionPool(
    max_connections=12,
    host=config.Production.REDIS_ADDRESS,
    port=config.Production.REDIS_PORT,
    password=config.Production.REDIS_PASSWORD,
    db=12,
    decode_responses=True,
)


def get_r() -> redis.Redis:
    return redis.Redis(connection_pool=connection_pool)


def set_cache(prefix, key, value, minutes=None):
    ex = None if minutes is None else datetime.timedelta(minutes=minutes)
    get_r().set('{}_{}'.format(prefix, key), value, ex=ex)


def get_cache(prefix, key, t=None):
    value = get_r().get('{}_{}'.format(prefix, key))
    if value is not None and t is not None:
        return t(value)
    return value


def remove_value(prefix, key):
    get_r().delete('{}_{}'.format(prefix, key))