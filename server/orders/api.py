import json
import math
import time
import traceback
from datetime import datetime, timedelta, timezone, tzinfo
from typing import List, Tuple, Dict, Any, Optional

from firebase_admin import firestore
from google.api_core.datetime_helpers import DatetimeWithNanoseconds
from google.cloud.firestore_v1 import DocumentReference, GeoPoint, DocumentSnapshot
from google.cloud.firestore_v1.types import Document

import settings
import users.api
from errors import *
import utils
from logger import logger
from orders.table_handlers import TripsTableHandler

def _parse_dt(val):
    if val is None:
        return None
    if isinstance(val, datetime):
        return val
    # ожидаем ISO-строку
    try:
        return datetime.fromisoformat(val)
    except Exception:
        return None


def _parse_firestore_dt(val):
    """Парсит значение Firestore Timestamp / datetime / unix-секунды / ISO-строку в datetime."""
    if val is None:
        return None
    if hasattr(val, "to_datetime") and callable(getattr(val, "to_datetime")):
        try:
            return val.to_datetime()
        except Exception:
            return None
    if isinstance(val, datetime):
        return val
    if isinstance(val, (int, float)):
        try:
            return datetime.fromtimestamp(val, tz=timezone.utc)
        except Exception:
            return None
    try:
        return datetime.fromisoformat(str(val))
    except Exception:
        return None

def fetch_firebase_orders(client_id: Optional[str] = None,
                          driver_id: Optional[str] = None,
                          status: Optional[str] = None,
                          start_date: Optional[str] = None,
                          finish_date: Optional[str] = None,
                          price_from: Optional[str] = None,
                          price_to: Optional[str] = None,
                          distance_from: Optional[str] = None,
                          distance_to: Optional[str] = None,
                          page: int = 1,
                          per_page: int = 10) -> Dict:
    """
    Возвращает dict:
    {
        "orders": data,
        "total_pages": total_pages,
        "total_orders": total_orders,
        "current_page": page,
    }
    """
    # Postgres SoT: фильтры + пагинация (FS только fallback).
    try:
        import app_pg

        if app_pg.enabled():
            if page is None or page < 1:
                page = 1
            if per_page is None or per_page <= 0:
                per_page = 10
            start_dt = _parse_dt(start_date)
            finish_dt = _parse_dt(finish_date)

            def _num(v):
                if v is None or v == "":
                    return None
                try:
                    return float(v)
                except (TypeError, ValueError):
                    return None

            # client_id/driver_id в dashboard иногда приходят как path или id
            def _uid(v):
                if not v:
                    return None
                s = str(v).strip()
                if "/" in s:
                    s = s.rsplit("/", 1)[-1]
                return s or None

            offset = (page - 1) * per_page
            result = app_pg.list_orders_filtered(
                status=status or None,
                customer_id=_uid(client_id),
                driver_id=_uid(driver_id),
                start_dt=start_dt,
                end_dt=finish_dt,
                budget_min=_num(price_from),
                budget_max=_num(price_to),
                distance_min=_num(distance_from),
                distance_max=_num(distance_to),
                limit=per_page,
                offset=offset,
            )
            rows = result.get("orders") or []
            total_orders = int(result.get("total") or 0)
            total_pages = max(1, (total_orders + per_page - 1) // per_page) if total_orders else 1
            return {
                "orders": rows,
                "total_pages": total_pages,
                "total_orders": total_orders,
                "current_page": page,
                "source": "postgres",
            }
    except Exception:
        logger.exception("[orders.fetch_firebase_orders] app_pg list failed, fallback Firestore")

    try:
        db = firestore.client()
        collection_ref = db.collection("order")

        # Построим базовый запрос с where-условиями
        query = collection_ref

        if client_id:
            query = query.where('user_customer', '==', client_id)
        if driver_id:
            query = query.where('selected_driver', '==', driver_id)
        if status:
            query = query.where('status', '==', status)

        start_dt = _parse_dt(start_date)
        finish_dt = _parse_dt(finish_date)
        if start_dt:
            query = query.where('dateTime_created', '>=', start_dt)
        if finish_dt:
            query = query.where('dateTime_created', '<=', finish_dt)

        if price_from and isinstance(price_from, int):
            query = query.where('budget', '>=', price_from)
        if price_to and isinstance(price_to, int):
            query = query.where('budget', '<=', price_to)

        if distance_from and isinstance(distance_from, int):
            query = query.where('distance', '>=', distance_from)
        if distance_to and isinstance(distance_to, int):
            query = query.where('distance', '<=', distance_to)

        # Попытка получить общее количество через агрегат count() (если поддерживается SDK)
        total_orders = None
        try:
            count_query = query.count()
            count_result = count_query.get()
            # В разных версиях SDK результат может выглядеть по-разному:
            if hasattr(count_result, 'count'):
                total_orders = int(count_result.count)
            else:
                # иногда возвращается список или другое представление — пробуем взять первый элемент
                try:
                    total_orders = int(count_result[0])
                except Exception:
                    total_orders = None
        except Exception:
            total_orders = None

        # Жёсткий потолок: полный stream коллекции сжигает Firestore quota (429).
        # Сортировка по-прежнему на Python — но не больше hard_cap документов.
        hard_cap = min(250, max(per_page * max(page, 1), per_page, 50))
        documents = list(query.limit(hard_cap).stream())

        # Преобразуем в JSON и сортируем на клиенте
        data = []
        for doc in documents:
            doc_data = doc.to_dict()
            doc_data['id'] = doc.id
            json_item = firebase_order_to_json(doc_data, True)
            if json_item is None:
                continue
            data.append(json_item)

        # Сортировка на стороне Python (от новых к старым)
        def get_sort_key(item):
            dt_val = item.get('dateTime_created')
            if dt_val is None:
                return datetime.min
            if isinstance(dt_val, str):
                try:
                    return datetime.fromisoformat(dt_val)
                except:
                    return datetime.min
            if isinstance(dt_val, datetime):
                return dt_val
            return datetime.min

        data.sort(key=get_sort_key, reverse=True)

        total_orders = len(data)

        # Пагинация на стороне Python
        if page is None or page < 1:
            page = 1
        if per_page is None or per_page <= 0:
            per_page = 20

        offset = (page - 1) * per_page
        data = data[offset:offset + per_page]

        total_pages = math.ceil(total_orders / per_page) if per_page > 0 else 1

        return {
            "orders": data,
            "total_pages": total_pages,
            "total_orders": total_orders,
            "current_page": page,
        }

    except Exception as e:
        raise IncorrectDataValue(f'Ошибка при получении заказов из Firebase: {e}')

def create_trips_table_handler() -> TripsTableHandler:
    return TripsTableHandler()

def firebase_order_to_json(doc, is_dict_already: bool = False):
    try:
        import datetime
        import traceback

        def _extract_latlng(value):
            # Try attribute access (GeoPoint-like)
            lat = lng = None
            if value is None:
                return None, None
            if isinstance(value, GeoPoint):
                return value.latitude, value.longitude

            # Attribute style: latitude / longitude
            if hasattr(value, "latitude") and hasattr(value, "longitude"):
                lat = getattr(value, "latitude")
                lng = getattr(value, "longitude")
            # Attribute style: lat / lng
            elif hasattr(value, "lat") and hasattr(value, "lng"):
                lat = getattr(value, "lat")
                lng = getattr(value, "lng")
            # Mapping style: dict-like with keys
            elif isinstance(value, dict):
                lat = value.get("latitude", value.get("lat"))
                lng = value.get("longitude", value.get("lng"))
                # sometimes nested point object under 'latlng'
                if lat is None and lng is None and "latlng" in value:
                    return _extract_latlng(value["latlng"])
            # Sequence style: [lat, lng] or (lat, lng)
            elif isinstance(value, (list, tuple)) and len(value) >= 2:
                lat, lng = value[0], value[1]
            # Fallback: try indexing
            else:
                try:
                    lat = value[0]
                    lng = value[1]
                except Exception:
                    lat = lng = None

            # Unwrap Decimal/complex-like numeric wrappers
            try:
                if hasattr(lat, "real"):
                    lat = lat.real
                if hasattr(lng, "real"):
                    lng = lng.real
                lat = float(lat) if lat is not None else None
                lng = float(lng) if lng is not None else None
            except Exception:
                lat = lng = None

            return lat, lng

        if doc is None:
            return None

        # Obtain a dict copy of the document data
        if not is_dict_already:
            data = doc.to_dict() or {}
            # attach id if available on DocumentSnapshot
            data["id"] = getattr(doc, "id", data.get("id"))
        else:
            # ensure we work on a shallow copy
            data = dict(doc)

        # selected_driver -> store id if possible
        driver = data.get("selected_driver")
        if driver is not None:
            driver_id = getattr(driver, "id", None)
            if driver_id is None and isinstance(driver, dict):
                driver_id = driver.get("id")
            data["selected_driver"] = driver_id

            # driver_location -> [lat, lng]
            dl = data.get("driver_location")
            if dl is not None:
                lat, lng = _extract_latlng(dl)
                if lat is not None and lng is not None:
                    data["driver_location"] = [lat, lng]

        # user_customer -> store id if a reference-like object
        user_customer = data.get("user_customer")
        if user_customer is not None:
            uc_id = getattr(user_customer, "id", None)
            if uc_id is None and isinstance(user_customer, dict):
                uc_id = user_customer.get("id")
            # if it's a plain scalar (str/int), keep it
            if uc_id is None and isinstance(user_customer, (str, int)):
                uc_id = user_customer
            data["user_customer"] = uc_id

        # pointA and pointB: normalize latlng to [lat, lng]
        pointA = data.get("pointA")
        if pointA and isinstance(pointA, dict):
            p_latlng = pointA.get("latlng")
            if p_latlng is not None:
                lat, lng = _extract_latlng(p_latlng)
                if lat is not None and lng is not None:
                    new_pointA = dict(pointA)
                    new_pointA["latlng"] = [lat, lng]
                    data["pointA"] = new_pointA

        pointB = data.get("pointB")
        if pointB and isinstance(pointB, dict):
            p_latlng = pointB.get("latlng")
            if p_latlng is not None:
                lat, lng = _extract_latlng(p_latlng)
                if lat is not None and lng is not None:
                    new_pointB = dict(pointB)
                    new_pointB['latlng'] = [lat, lng]
                    data["pointB"] = new_pointB


        # dateTime_created: parse Firestore Timestamp or numeric timestamp into ISO datetime
        ts = data.get("dateTime_created")
        if ts is not None:
            parsed_dt = None
            # Firestore Timestamp-like objects have to_datetime()
            if hasattr(ts, "to_datetime") and callable(getattr(ts, "to_datetime")):
                try:
                    parsed_dt = ts.to_datetime()
                except Exception:
                    parsed_dt = None
            # If it's already a datetime
            elif isinstance(ts, datetime.datetime):
                parsed_dt = ts
            # If it's a numeric unix timestamp (seconds)
            elif isinstance(ts, (int, float)):
                try:
                    # assume seconds
                    parsed_dt = datetime.datetime.fromtimestamp(ts, tz=datetime.timezone.utc).astimezone()
                except Exception:
                    parsed_dt = None
            else:
                # Try ISO string parsing
                try:
                    parsed_dt = datetime.datetime.fromisoformat(str(ts))
                except Exception:
                    parsed_dt = None

            if parsed_dt is not None:
                # store as ISO 8601 string (date and time)
                data["dateTime_created"] = parsed_dt.isoformat()

        # ensure the field exists
        data.update({"user_who_responced": None})
        return utils.to_json(data)

    except Exception as e:
        logger.error("Ошибка в firebase_order_to_json: %s", str(e))
        logger.error("Источник ошибки:\n%s", traceback.format_exc())

# New method to get order statistics
def _is_firestore_quota_error(exc: BaseException) -> bool:
    msg = str(exc).lower()
    return (
        "429" in msg
        or "quota" in msg
        or "resource_exhausted" in msg
        or "resource exhausted" in msg
    )


def get_order_statistics_result(user_id, driver_id, start_date, end_date, city) -> dict:
    """stats + флаг квоты Firestore. stats — прежний tuple для шаблона."""
    empty = (
        0, 0, 0, 0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        [0.0] * 12,
        {},
    )
    stats_doc_cap = 400
    stats_days = 120

    def _compute():
        try:
            db = utils.init_firebase_client()
            order_collection_ref = db.collection("order")
        except Exception as e:
            logger.error(f'get_order_statistics init failed: {e}')
            return {
                "stats": empty,
                "quota_exhausted": _is_firestore_quota_error(e),
            }

        today = datetime.utcnow()
        yesterday = today - timedelta(days=1)
        last_week = today - timedelta(weeks=1)
        last_month = today - timedelta(days=30)

        order_counts = {
            "last_day": 0,
            "last_week": 0,
            "last_month": 0,
            "all_time": 0,
        }

        earnings = {
            "last_day": 0.0,
            "last_week": 0.0,
            "last_month": 0.0,
            "all_time": 0.0,
        }
        commission_earnings = {
            "last_day": 0.0,
            "last_week": 0.0,
            "last_month": 0.0,
            "all_time": 0.0,
        }

        monthly_earnings = [0.0] * 12
        status_counts = {}

        try:
            cutoff = today - timedelta(days=stats_days)
            docs = []
            try:
                docs = list(
                    order_collection_ref
                    .where("dateTime_created", ">=", cutoff)
                    .limit(stats_doc_cap)
                    .stream()
                )
            except Exception as e:
                if _is_firestore_quota_error(e):
                    logger.error(f"get_order_statistics quota: {e}")
                    return {"stats": empty, "quota_exhausted": True}
                logger.warning(
                    f"get_order_statistics date filter failed, limit-only: {e}"
                )
                docs = list(order_collection_ref.limit(stats_doc_cap).stream())

            for doc in docs:
                order_data = doc.to_dict() or {}
                time_val = order_data.get('dateTime_created')
                if time_val is None:
                    continue
                try:
                    order_created = datetime.fromtimestamp(time_val.timestamp())
                except Exception:
                    continue
                order_status = order_data.get('status')
                add_to_currentPrice = order_status == 'completed'
                json = firebase_order_to_json(order_data, is_dict_already=True)

                if json is None:
                    continue

                if user_id and json.get('user_customer', {}) != user_id:
                    continue
                if driver_id and json.get('selected_driver', {}) != driver_id:
                    continue
                if start_date and json.get('dateTime_created') is not None:
                    try:
                        date_time_create = datetime.fromtimestamp(json['dateTime_created'])
                    except Exception:
                        date_time_create = datetime.fromisoformat(json['dateTime_created'])
                    if date_time_create.timestamp() < start_date.timestamp():
                        continue
                if end_date and json.get('dateTime_created') is not None:
                    try:
                        date_time_create = datetime.fromtimestamp(json['dateTime_created'])
                    except Exception:
                        date_time_create = datetime.fromisoformat(json['dateTime_created'])
                    if date_time_create.timestamp() > end_date.timestamp():
                        continue
                if city and json.get('pointA') and json.get('pointA').get('city').lower() != city.lower():
                    continue

                order_counts["all_time"] += 1
                currentPrice = order_data.get('currentPrice', 0.0) or 0.0
                commission_percent = order_data.get('commissionPercent') or 17.0
                currentCommission = (currentPrice / 100) * commission_percent

                if order_status in status_counts:
                    status_counts[order_status] += 1
                else:
                    status_counts[order_status] = 1

                if add_to_currentPrice:
                    earnings['all_time'] += currentPrice
                    commission_earnings["all_time"] += currentCommission
                    monthly_earnings[order_created.month - 1] += currentPrice
                if order_created >= yesterday:
                    order_counts["last_day"] += 1
                    if add_to_currentPrice:
                        earnings["last_day"] += currentPrice
                        commission_earnings["last_day"] += currentCommission
                if order_created >= last_week:
                    order_counts["last_week"] += 1
                    if add_to_currentPrice:
                        earnings["last_week"] += currentPrice
                        commission_earnings["last_week"] += currentCommission
                if order_created >= last_month:
                    order_counts["last_month"] += 1
                    if add_to_currentPrice:
                        earnings["last_month"] += currentPrice
                        commission_earnings["last_month"] += currentCommission
        except Exception as e:
            logger.error(f'get_order_statistics failed: {e}')
            return {
                "stats": empty,
                "quota_exhausted": _is_firestore_quota_error(e),
            }

        return {
            "stats": (
                order_counts["last_day"],
                order_counts["last_week"],
                order_counts["last_month"],
                order_counts["all_time"],
                earnings["last_day"] if earnings["last_day"] != 0 else 0.0,
                earnings["last_week"] if earnings["last_week"] != 0 else 0.0,
                earnings["last_month"] if earnings["last_month"] != 0 else 0.0,
                earnings["all_time"],
                commission_earnings["last_day"],
                commission_earnings["last_week"],
                commission_earnings["last_month"],
                commission_earnings["all_time"],
                monthly_earnings,
                status_counts,
            ),
            "quota_exhausted": False,
        }

    import ttl_cache
    cache_key = (
        f"order_stats_result:{user_id}:{driver_id}:{start_date}:{end_date}:{city}"
    )
    return ttl_cache.get_or_set(cache_key, 300, _compute)


def get_order_statistics(user_id, driver_id, start_date, end_date, city) -> tuple[
    int, int, int, int, float, float, float, float, float, float, float, float, list[float], dict[Any, int]]:
    return get_order_statistics_result(
        user_id, driver_id, start_date, end_date, city
    )["stats"]


from datetime import datetime, timedelta
import pandas as pd
from io import BytesIO

def export_order_statistics_to_excel(order_counts, earnings, commission_earnings, monthly_earnings, status_counts) -> BytesIO:
    logger.info("=== export_order_statistics_to_excel: начало ===")
    try:
        logger.info(f"Входные данные: order_counts type={type(order_counts)}, earnings type={type(earnings)}")
        logger.info(f"commission_earnings type={type(commission_earnings)}, monthly_earnings type={type(monthly_earnings)}")
        logger.info(f"status_counts type={type(status_counts)}")

        output = BytesIO()
        logger.info("BytesIO создан")

        # Проверка на пустые входные данные
        if not order_counts:
            logger.warning("order_counts пустой, используем значение по умолчанию")
            order_counts = {'Нет данных': 0}

        if not earnings:
            logger.warning("earnings пустой, используем значение по умолчанию")
            earnings = {'Нет данных': 0}

        if not commission_earnings:
            logger.warning("commission_earnings пустой, используем значение по умолчанию")
            commission_earnings = {'Нет данных': 0}

        if not monthly_earnings:
            logger.warning("monthly_earnings пустой, используем значение по умолчанию")
            monthly_earnings = [0] * 12

        if not status_counts:
            logger.warning("status_counts пустой, используем значение по умолчанию")
            status_counts = {'Нет статусов': 0}

        # Формирование периодов
        logger.info(f"Формирование order_counts_df, len(order_counts)={len(order_counts)}")
        if len(order_counts) == 4:
            order_periods = ['День', 'Неделя', 'Месяц', 'Всего']
        else:
            order_periods = [f'Период {i + 1}' for i in range(len(order_counts))]

        order_counts_df = pd.DataFrame(
            [(order_periods[i], val) for i, val in enumerate(order_counts)],
            columns=['Период', 'Количество']
        )
        logger.info(f"order_counts_df создан: {order_counts_df.shape}")

        logger.info(f"Формирование earnings_df, len(earnings)={len(earnings)}")
        if len(earnings) == 4:
            earnings_periods = ['День', 'Неделя', 'Месяц', 'Всего']
        else:
            earnings_periods = [f'Период {i + 1}' for i in range(len(earnings))]

        earnings_df = pd.DataFrame(
            [(earnings_periods[i], val) for i, val in enumerate(earnings)],
            columns=['Период', 'Заработок']
        )
        logger.info(f"earnings_df создан: {earnings_df.shape}")

        logger.info("Формирование commission_earnings_df")
        if len(earnings) == 4:
            commission_earnings_periods = ['День', 'Неделя', 'Месяц', 'Всего']
        else:
            commission_earnings_periods = [f'Период {i + 1}' for i in range(len(earnings))]

        commission_earnings_df = pd.DataFrame(
            [(commission_earnings_periods[i], val) for i, val in enumerate(commission_earnings)],
            columns=['Период', 'Комиссия']
        )
        logger.info(f"commission_earnings_df создан: {commission_earnings_df.shape}")

        # Правильное создание DataFrame для monthly_earnings
        logger.info(f"Формирование monthly_earnings_df, len(monthly_earnings)={len(monthly_earnings)}")
        month_names = ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
                       'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь']

        yearly_total = sum(monthly_earnings)
        monthly_data = [(month_names[i], val) for i, val in enumerate(monthly_earnings)]
        monthly_data.append(('Итого за год', yearly_total))
        monthly_earnings_df = pd.DataFrame(monthly_data, columns=['Месяц', 'Заработок'])
        logger.info(f"monthly_earnings_df создан: {monthly_earnings_df.shape}")

        # Перевод статусов на русский
        logger.info(f"Формирование status_counts_df, status_counts={status_counts}")
        status_translations = {
            'newOrder': 'Новый заказ',
            'completed': 'Завершён',
            'cancelled': 'Отменён',
            'inProgress': 'В процессе',
            'accepted': 'Принят',
            'arrived': 'Прибыл',
            'waiting': 'Ожидание',
            'started': 'Начат',
            'pending': 'Ожидает',
        }
        translated_status_counts = {
            status_translations.get(status, status): count
            for status, count in status_counts.items()
        }
        status_counts_df = pd.DataFrame(list(translated_status_counts.items()), columns=['Статус', 'Количество'])
        logger.info(f"status_counts_df создан: {status_counts_df.shape}")

        logger.info("Запись в Excel с помощью pd.ExcelWriter...")
        with pd.ExcelWriter(output, engine='openpyxl') as writer:
            logger.info("ExcelWriter создан, записываем листы...")
            order_counts_df.to_excel(writer, sheet_name='Заказы', index=False)
            logger.info("Лист 'Заказы' записан")
            earnings_df.to_excel(writer, sheet_name='Заработок', index=False)
            logger.info("Лист 'Заработок' записан")
            commission_earnings_df.to_excel(writer, sheet_name='Комиссия', index=False)
            logger.info("Лист 'Комиссия' записан")
            monthly_earnings_df.to_excel(writer, sheet_name='Заработок по месяцам', index=False)
            logger.info("Лист 'Заработок по месяцам' записан")
            status_counts_df.to_excel(writer, sheet_name='Статусы', index=False)
            logger.info("Лист 'Статусы' записан")

        output.seek(0)
        logger.info(f"=== export_order_statistics_to_excel: успешно завершено, размер={output.getbuffer().nbytes} байт ===")
        return output
    except Exception as e:
        logger.error("Ошибка в export_order_statistics_to_excel: %s", str(e))
        logger.error("Источник ошибки:\n%s", traceback.format_exc())
        return None

def update_order_point(order_id: str, point: str, position_data: Any, description: Optional[str] = None, city: Optional[str] = None) -> Optional[dict]:
    """
    Обновляет точку pointA или pointB у заказа.
    Postgres SoT; Firestore soft_fs только если APP_FS_MIRROR=1.

    position_data можно передавать как dict или JSON-строку. Ожидаемые ключи: lat/lon или latitude/longitude,
    либо latlng (список/кортеж или dict). Также могут присутствовать city и description.
    description и city из аргументов имеют приоритет перед теми, что в position_data.

    Возвращает обновлённый заказ в формате firebase_order_to_json или выбрасывает IncorrectDataValue при ошибке.
    """
    try:
        import app_fs_mirror
        import app_pg

        if point not in ("pointA", "pointB"):
            raise IncorrectDataValue("Поле 'point' должно быть 'pointA' или 'pointB'")

        existing = app_pg.get_order(order_id)
        if not existing:
            raise IncorrectDataValue(f"Заказ с id={order_id} не найден")

        # Подготовка position_data
        pd = position_data
        if isinstance(pd, str):
            try:
                pd = json.loads(pd)
            except Exception:
                # Попытка восстановить немного плохой JSON (одинарные кавычки)
                try:
                    pd = json.loads(pd.replace("'", '"'))
                except Exception:
                    raise IncorrectDataValue("position_data не является валидной JSON-строкой или dict")

        if pd is None:
            pd = {}

        if not isinstance(pd, dict):
            raise IncorrectDataValue("position_data должен быть dict или JSON-строкой, содержащей объект")

        def _extract_latlon(d: dict):
            lat = d.get("lat") if "lat" in d else d.get("latitude")
            lon = d.get("lon") if "lon" in d else d.get("lng") if "lng" in d else d.get("longitude")
            if (lat is None or lon is None) and "latlng" in d:
                latlng = d.get("latlng")
                if isinstance(latlng, (list, tuple)) and len(latlng) >= 2:
                    lat, lon = latlng[0], latlng[1]
                elif isinstance(latlng, dict):
                    lat = lat or latlng.get("lat") or latlng.get("latitude")
                    lon = lon or latlng.get("lon") or latlng.get("lng") or latlng.get("longitude")
            # Попытка кастовать в float
            try:
                if lat is not None:
                    lat = float(lat)
                if lon is not None:
                    lon = float(lon)
            except Exception:
                lat = lon = None
            return lat, lon

        lat, lon = _extract_latlon(pd)

        existing_point = existing.get(point) or {}
        if not isinstance(existing_point, dict):
            existing_point = {}

        new_point = dict(existing_point)  # shallow copy

        # Приоритет: аргументы функции -> данные в position_data -> существующие значения
        new_city = city or pd.get("city") or pd.get("town") or new_point.get("city")
        if new_city is not None:
            new_point["city"] = new_city

        new_description = description or pd.get("description") or new_point.get("description")
        if new_description is not None:
            new_point["address"] = new_description
            new_point["fullAddress"] = new_description
        if lat is not None and lon is not None:
            new_point["latlng"] = [lat, lon]
        else:
            # Если координат нет, но есть полное описание адреса, сохраняем его
            addr = pd.get("address") or pd.get("formatted_address")
            if addr and not new_point.get("address"):
                new_point["address"] = addr
                new_point["fullAddress"] = addr

        if not app_pg.mirror_order_fields(order_id, {point: new_point}):
            raise IncorrectDataValue(f"Не удалось обновить точку {point} заказа {order_id} в Postgres")

        def _fs():
            fs_point = dict(new_point)
            if lat is not None and lon is not None:
                fs_point["latlng"] = GeoPoint(lat, lon)
            doc_ref = firestore.client().collection("order").document(order_id)
            try:
                doc_ref.update({point: fs_point})
            except Exception as e:
                logger.warning(
                    "Не удалось обновить %s у заказа %s напрямую: %s. Попытка установки целиком.",
                    point, order_id, str(e),
                )
                doc_ref.set({point: fs_point}, merge=True)

        app_fs_mirror.soft_fs("update_order_point", _fs)

        updated = app_pg.get_order(order_id) or {**existing, point: new_point, "id": order_id}
        updated["id"] = order_id
        return firebase_order_to_json(updated, is_dict_already=True)

    except IncorrectDataValue:
        raise
    except Exception as e:
        logger.error("Ошибка при обновлении точки %s у заказа %s: %s", point, order_id, str(e))
        logger.error("Источник ошибки:\n%s", traceback.format_exc())
        raise IncorrectDataValue(f"Ошибка при обновлении точки: {e}")

def get_order_by_id(order_id: str) -> Optional[dict]:
    """
    Возвращает заказ по его идентификатору или None, если не найден.
    """
    try:
        try:
            import app_pg
            pg_order = app_pg.get_order(order_id)
            if pg_order:
                # Нормализуем через тот же пайплайн, что и Firestore
                return firebase_order_to_json(pg_order, is_dict_already=True)
        except Exception:
            logger.exception("[orders.get_order_by_id] app_pg failed id=%s", order_id)

        db = firestore.client()
        doc_ref = db.collection("order").document(order_id)
        doc_snapshot = doc_ref.get()
        if not doc_snapshot.exists:
            return None
        doc_data = doc_snapshot.to_dict() or {}
        doc_data['id'] = doc_snapshot.id
        return firebase_order_to_json(doc_data, is_dict_already=True)
    except Exception as e:
        logger.error("Ошибка при получении заказа по id %s: %s", order_id, str(e))
        logger.error("Источник ошибки:\n%s", traceback.format_exc())
        return None

def edit_order(order_id: str, budget, distance, currentPrice, status) -> Optional[dict]:
    """
    Обновляет поля budget, currentPrice, distance / status у заказа.
    Postgres SoT; Firestore soft_fs только если APP_FS_MIRROR=1.
    """
    try:
        import app_fs_mirror
        import app_pg

        existing = app_pg.get_order(order_id)
        if not existing:
            raise IncorrectDataValue(f"Заказ с id={order_id} не найден")

        pg_fields: dict = {}
        if budget:
            pg_fields.update({
                'budget': budget,
                'distance': distance,
                'currentPrice': currentPrice,
            })
        if status:
            pg_fields['status'] = status
        if pg_fields:
            if not app_pg.mirror_order_fields(order_id, pg_fields):
                raise IncorrectDataValue(f"Не удалось обновить заказ {order_id} в Postgres")

        def _fs():
            db = firestore.client()
            doc_ref = db.collection("order").document(order_id)
            if pg_fields:
                doc_ref.update(pg_fields)

        app_fs_mirror.soft_fs("edit_order", _fs)

        updated = app_pg.get_order(order_id) or {**existing, **pg_fields, "id": order_id}
        updated["id"] = order_id
        return firebase_order_to_json(updated, is_dict_already=True)

    except IncorrectDataValue:
        raise
    except Exception as e:
        raise IncorrectDataValue(f"Не удалось обновить заказ: {e}")




def check_order_status():
    """Таймеры: авто-cancel устаревших newOrder и auto-hide completed (Postgres SoT)."""
    poll_sec = 60
    batch_limit = 50
    while True:
        logger.info("START check_orders_status CHECK")
        try:
            import app_pg

            utc_tz = timezone(timedelta(hours=0))
            now = datetime.now(utc_tz)
            model = settings.get_model()

            for order in app_pg.list_orders(status="newOrder", limit=batch_limit):
                oid = order.get("id")
                if not oid:
                    continue
                logger.info(f"START check_orders_status CHECK {oid}")
                created_val = order.get("dateTime_created") or order.get("date_created")
                if not created_val:
                    continue
                try:
                    if isinstance(created_val, datetime):
                        v = created_val
                        if v.tzinfo is None:
                            v = v.replace(tzinfo=utc_tz)
                    else:
                        v = datetime.fromisoformat(str(created_val)).replace(tzinfo=utc_tz)
                except Exception:
                    continue
                if now - v >= timedelta(minutes=model.minutes_for_delete_order):
                    edit_order(oid, None, None, None, status="cancelled")

            for order in app_pg.list_orders(status="completed", limit=batch_limit):
                oid = order.get("id")
                if not oid:
                    continue
                date_upd = order.get("date_upd") or order.get("dateUpd")
                if isinstance(date_upd, str):
                    try:
                        date_upd = datetime.fromisoformat(date_upd)
                    except Exception:
                        date_upd = None
                if date_upd is None:
                    continue
                if date_upd.tzinfo is None:
                    date_upd = date_upd.replace(tzinfo=utc_tz)
                if now - date_upd >= timedelta(minutes=model.deadline_minutes):
                    logger.info(f"AUTO-HIDE completed order {oid}")
                    try:
                        app_pg.mirror_order_fields(
                            oid,
                            {"status": "hidden", "status_do_hidden": "completed"},
                        )
                        import app_fs_mirror

                        def _fs_hide(order_id=oid):
                            firestore.client().collection("order").document(order_id).update({
                                "status": "hidden",
                                "status_do_hidden": "completed",
                            })

                        app_fs_mirror.soft_fs("check_order_status.auto_hide", _fs_hide)
                    except Exception as e:
                        logger.error(
                            f"[check_order_status.auto_hide] failed {oid}: {e}"
                        )
        except Exception as e:
            logger.error(f"[check_order_status] loop error: {e}")
        time.sleep(poll_sec)


# --------------------------------------------------------------------------
#  multi-orders / «по пути» — рассылка занятым водителям
# --------------------------------------------------------------------------

def notify_busy_drivers_about_new_orders():
    """
    Периодически ищет свежие newOrder и шлёт FCM data-push
    подходящим (по маршруту и тарифу) занятым водителям.

    Запускается в отдельном потоке из app.py. PG-first + soft FS meta.
    """
    import config
    import app_fs_mirror
    from orders.extra_orders import find_busy_drivers_for_order
    from users.api import send_push_to_firebase_users

    api_key = getattr(config.Production, 'GOOGLE_API_KEY', '') or ''
    poll_interval_sec = 30

    def _parse_notified_at(val):
        if val is None:
            return None
        if isinstance(val, datetime):
            if val.tzinfo is None:
                return val.replace(tzinfo=timezone.utc)
            return val
        if isinstance(val, str):
            try:
                dt = datetime.fromisoformat(val.replace("Z", "+00:00"))
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=timezone.utc)
                return dt
            except Exception:
                return None
        if hasattr(val, "to_datetime") and callable(val.to_datetime):
            try:
                return val.to_datetime()
            except Exception:
                return None
        return None

    def _persist_meta(order_id, tick_start, new_notified):
        fields = {"extra_notified_at": tick_start.isoformat()}
        if new_notified is not None:
            fields["extra_notified_drivers"] = new_notified
        try:
            import app_pg

            if app_pg.enabled():
                app_pg.mirror_order_fields(order_id, fields)
        except Exception:
            logger.exception("[extra_notify.persist] PG meta failed order=%s", order_id)

        def _fs():
            db = firestore.client()
            patch = {"extra_notified_at": tick_start}
            if new_notified is not None:
                patch["extra_notified_drivers"] = new_notified
            db.collection("order").document(order_id).update(patch)

        app_fs_mirror.soft_fs("extra_notify_meta", _fs)

    def _list_new_orders():
        try:
            import app_pg

            if app_pg.enabled():
                rows = app_pg.list_orders(status="newOrder", limit=50)
                if rows is not None:
                    return rows
        except Exception:
            logger.exception("[extra_notify.loop] PG list newOrder failed")

        db = firestore.client()
        snaps = list(
            db.collection("order").where("status", "==", "newOrder").limit(50).stream()
        )
        out = []
        for snap in snaps:
            raw = snap.to_dict() or {}
            order = firebase_order_to_json({**raw, "id": snap.id}, is_dict_already=True)
            if order:
                out.append(order)
        return out

    while True:
        try:
            model = settings.get_model()
            cooldown_sec = model.extra_order_notify_cooldown_sec
            tick_start = datetime.now(timezone.utc)
            new_orders = _list_new_orders()
            logger.info(
                f"[extra_notify.loop] tick new_orders_count={len(new_orders)}"
            )

            for order in new_orders:
                order_id = str(order.get("id") or "")
                if not order_id:
                    continue
                if (order.get("status") or "").lower() != "neworder":
                    continue

                last_notified = _parse_notified_at(order.get("extra_notified_at"))
                if last_notified is not None:
                    elapsed = (tick_start - last_notified).total_seconds()
                    if elapsed < cooldown_sec:
                        continue

                notified_uids_raw = order.get("extra_notified_drivers") or []
                notified_uids = [str(u) for u in notified_uids_raw if u]
                logger.info(
                    f"[extra_notify.dedup] order={order_id} already_notified={notified_uids}"
                )

                try:
                    candidates = find_busy_drivers_for_order(order, api_key)
                except Exception as e:
                    logger.error(
                        f"[extra_notify.dispatch] route check failed order={order_id}: {e}\n"
                        f"{traceback.format_exc()}"
                    )
                    candidates = []

                fresh = [
                    c for c in candidates if str(c.get("driver_uid")) not in notified_uids
                ]
                logger.info(
                    f"[extra_notify.dispatch] order={order_id} "
                    f"candidates={[c.get('driver_uid') for c in candidates]} "
                    f"fresh={[c.get('driver_uid') for c in fresh]}"
                )

                if not fresh:
                    _persist_meta(order_id, tick_start, None)
                    continue

                target = fresh[0]
                target_uid = target["driver_uid"]
                data = {
                    "type": "additional_order",
                    "order_id": order_id,
                    "current_order_id": target.get("current_order_id") or "",
                    "delta_min": str(target.get("delta_min", "")),
                    "delta_km": str(target.get("delta_km", "")),
                }

                try:
                    send_push_to_firebase_users(
                        user_ids=[target_uid],
                        title="Дополнительный заказ",
                        text="Заказ по пути",
                        data=data,
                    )
                    logger.info(
                        f"[extra_notify.dispatch] FCM sent order={order_id} "
                        f"driver={target_uid} delta_min={target.get('delta_min')}"
                    )
                except Exception as e:
                    logger.error(
                        f"[extra_notify.dispatch] FCM failed order={order_id} "
                        f"driver={target_uid}: {e}\n{traceback.format_exc()}"
                    )

                new_notified = list(dict.fromkeys(notified_uids + [str(target_uid)]))
                try:
                    _persist_meta(order_id, tick_start, new_notified)
                    logger.info(
                        f"[extra_notify.persist] order={order_id} "
                        f"extra_notified_drivers <- {new_notified}"
                    )
                except Exception as e:
                    logger.error(
                        f"[extra_notify.dispatch] failed to update order meta {order_id}: {e}\n"
                        f"{traceback.format_exc()}"
                    )
        except Exception as e:
            logger.error(
                f"[extra_notify.loop] uncaught: {e}\n{traceback.format_exc()}"
            )
        time.sleep(poll_interval_sec)
