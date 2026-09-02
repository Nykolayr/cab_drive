import socket
import string
from datetime import timezone

from flask import Response, request, Request
from flask import session as flask_session
from google.api_core.datetime_helpers import DatetimeWithNanoseconds
from google.cloud.firestore_v1 import GeoPoint, DocumentReference
from sqlalchemy.ext.declarative import DeclarativeMeta
from string import ascii_uppercase, digits
from typing import Union, Literal, List, Optional

import config
from users.entities import User
from errors import *
import users
import random
import json
import decimal
import datetime
import sys
import os
import inspect
import re
import enum
import html

import firebase_admin
from firebase_admin import credentials, firestore
import google.cloud.firestore_v1._helpers

def get_server_ip():
    return f'{socket.gethostbyname(socket.gethostname())}:{config.Production.PORT}'


def init_firebase_client():
    """
    Инициализация Firebase Admin SDK и получение клиента Firestore.
    Попытается инициализировать приложение только один раз.
    Для конфигурации можно передать путь к service account JSON в переменной окружения FIREBASE_CREDENTIALS.
    Если переменная содержит JSON строку -- используется она как содержимое service account.
    Если переменная не задана, будет вызвана default инициализация (например, если запущено в GCP).
    """
    try:
        if firebase_admin._apps:
            return firestore.client()

        cred_env = os.getenv('s.json')
        print(cred_env)
        if cred_env:
            # если это путь к файлу
            if os.path.exists(cred_env):
                cred = credentials.Certificate(cred_env)
                firebase_admin.initialize_app(cred)
            else:
                # попробуем распознать как JSON-строку с учетными данными
                try:
                    cred_dict = json.loads(cred_env)
                    cred = credentials.Certificate(cred_dict)
                    firebase_admin.initialize_app(cred)
                except Exception:
                    # fallback: инициализация по умолчанию
                    firebase_admin.initialize_app()
        else:
            firebase_admin.initialize_app()
        return firestore.client()
    except Exception as e:
        raise IncorrectDataValue(f'Ошибка инициализации Firebase: {e}')



def make_xss_safe(input_string: str) -> str:
    if not isinstance(input_string, str):
        return ""

    return html.escape(input_string, quote=True)


def str_to_enum(value, obj):
    try:
        return obj(value)
    except:
        return None


def get_user(account_types: List[int] | None = None) -> Union[User, None]:
    if account_types is None:
        account_types = [2]
    user_id = flask_session.get('user_id')
    if user_id is None:
        return None
    user = users.api.get_user_by_id(user_id)
    if user is None:
        return None
    if user.account_type not in account_types:
        return None
    return user


def is_super_admin(user: Optional[User] = None) -> bool:
    if user is None:
        user = get_user()
    if user is None:
        return False
    return bool(getattr(user, 'is_super_admin', False))


def require_super_admin() -> Optional[User]:
    """Текущий пользователь-суперадмин или None."""
    user = get_user()
    if user is None or not is_super_admin(user):
        return None
    return user


def get_jwt():
    return {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT"
    }


def get_addr():
    try:
        if request.environ.get('HTTP_X_FORWARDED_FOR') is None:
            return request.environ['REMOTE_ADDR']
        else:
            ips = str(request.environ['HTTP_X_FORWARDED_FOR'])
            if ',' in ips:
                ips = ips.split(',')[0]
            return ips
    except:
        return 'no_context'


def to_json(data):
    data_json = json.dumps(data, ensure_ascii=False, indent=3, default=json_serial)
    return json.loads(data_json)


def format_phone(phone):
    try:
        code = phone[0: 3]
        number = phone[3: 6]
        preffix_1 = phone[6: 8]
        preffix_2 = phone[8: 10]
        return '+7 ({}) {}-{}-{}'.format(code, number, preffix_1, preffix_2)
    except:
        return phone


def telephone(tel):
    if str(tel).isdigit() and len(tel) == 10:
        tel = '7' + tel
    pattern = r'(\+7|8|7).*?(\d{3}).*?(\d{3}).*?(\d{2}).*?(\d{2})'
    result = re.findall(pattern, tel)
    phone = ''
    z = 0
    if len(result) == 0:
        return None
    for r in result[0]:
        if z != 0:
            phone += r
        z += 1
    return phone


def get_entity_by_id(entity_id, entities_list):
    result = None
    for entity in entities_list:
        if entity.id == entity_id:
            result = entity
            break
    return result


def get_entity_by_key(key, value, entities_list):
    result = None
    for entity in entities_list:
        try:
            if entity.get(key) == value:
                result = entity
                break
        except:
            try:
                if getattr(entity, key) == value:
                    return entity
            except:
                continue
    return result


class AlchemyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj.__class__, DeclarativeMeta):
            fields = {}
            for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
                data = obj.__getattribute__(field)
                try:
                    json.dumps(data)
                    fields[field] = data
                except TypeError:
                    fields[field] = None
            return fields

        return json.JSONEncoder.default(self, obj)


def json_serial(obj):
    try:
        return obj.schema()
    except:
        pass
    if isinstance(obj, decimal.Decimal):
        return float(obj)
    if isinstance(obj, datetime.datetime):
        return int(obj.timestamp())
    if isinstance(obj, datetime.date):
        return obj.strftime('%Y-%m-%d')
    if isinstance(obj, enum.Enum):
        return obj.value
    if isinstance(obj, GeoPoint) or isinstance(obj, google.cloud.firestore_v1._helpers.GeoPoint):
        # Handle Firestore GeoPoint
        return {'latitude': obj.latitude, 'longitude': obj.longitude}
    if hasattr(obj, 'latitude') and hasattr(obj, 'longitude'):
        # Handle other geo-like objects
        return {'latitude': obj.latitude, 'longitude': obj.longitude}
    elif isinstance(obj.__class__, DeclarativeMeta):
        fields = {}
        for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
            if field in ['query', 'registry']:
                continue
            try:
                data = obj.__getattribute__(field)
                json.dumps(data, default=json_serial)
                fields[field] = data
            except:
                fields[field] = None
        return fields
    raise TypeError("Type %s not serializable" % type(obj))


def get_script_dir(follow_symlinks=True):
    if getattr(sys, 'frozen', False):
        path = os.path.abspath(sys.executable)
    else:
        path = inspect.getabsfile(get_script_dir)
    if follow_symlinks:
        path = os.path.realpath(path)
    return os.path.dirname(path)


def get_error(error_text, status=500):
    res = {
        'status': 'error',
        'message': error_text
    }
    return Response(
        response=json.dumps(res, ensure_ascii=False),
        mimetype='application/json',
        status=status
    )


def get_answer(text, info=None):
    if info is None:
        info = {}
    res = {
        'status': 'ok',
        'message': text
    }
    answer = {**res, **info}
    return Response(
        response=json.dumps(answer, ensure_ascii=False, default=json_serial),
        mimetype='application/json',
        status=200,
    )


def get_random_string(length):
    string = ''.join(random.choice(ascii_uppercase + digits) for i in range(length))
    return string


def requests_to_dict(req: Request) -> dict:
    result = {}
    for key in req.values:
        result[key] = req.values[key]
    return result


def generate_random_password(length=8):
    # Определяем набор символов для пароля
    characters = string.ascii_letters + string.digits + string.punctuation
    # Генерируем пароль
    password = ''.join(random.choice(characters) for _ in range(length))
    return password



def parse_dt_to_utc(value):
    """
    Возвращает datetime (tz-aware, UTC) или None.
    Поддерживает:
      - datetime (aware/naive)
      - int/float unix timestamp (seconds)
      - Firestore Timestamp-like (has .seconds or .to_datetime())
      - ISO/other datetime strings
    """
    if value is None:
        return None

    # Если это уже datetime
    if isinstance(value, datetime.datetime):
        dt = value
        # Если naive — считаем UTC (или можно заменить на локальную зону при необходимости)
        if dt.tzinfo is None:
            return dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)

    # Unix timestamp
    if isinstance(value, (int, float)):
        try:
            return datetime.datetime.fromtimestamp(float(value), tz=timezone.utc)
        except Exception:
            return None

    # Firestore-like Timestamp: try to_datetime() first, then .seconds
    try:
        if hasattr(value, 'to_datetime') and callable(value.to_datetime):
            dt = value.to_datetime()
            if isinstance(dt, datetime.datetime):
                if dt.tzinfo is None:
                    return dt.replace(tzinfo=timezone.utc)
                return dt.astimezone(timezone.utc)
    except Exception:
        pass

    try:
        if hasattr(value, 'seconds'):
            # protobuf-like timestamp
            secs = int(getattr(value, 'seconds'))
            return datetime.datetime.fromtimestamp(secs, tz=timezone.utc)
    except Exception:
        pass

    # Если строка — пробуем разные парсеры
    if isinstance(value, str):
        s = value.strip()
        # Попробуем fromisoformat (работает для большинства ISO без Z)
        try:
            dt = datetime.datetime.fromisoformat(s)
            if dt.tzinfo is None:
                return dt.replace(tzinfo=timezone.utc)
            return dt.astimezone(timezone.utc)
        except Exception:
            pass

        # Попробуем dateutil если установлен
        try:
            from dateutil import parser as dateutil_parser
            dt = dateutil_parser.parse(s)
            if dt.tzinfo is None:
                return dt.replace(tzinfo=timezone.utc)
            return dt.astimezone(timezone.utc)
        except Exception:
            pass

        # Попробуем несколько распространённых форматов
        fmts = ("%Y-%m-%d %H:%M:%S", "%Y-%m-%dT%H:%M:%S",
                "%d.%m.%Y %H:%M:%S", "%Y-%m-%d")
        for f in fmts:
            try:
                dt = datetime.datetime.strptime(s, f)
                return dt.replace(tzinfo=timezone.utc)
            except Exception:
                continue

    # Не удалось распарсить
    return None