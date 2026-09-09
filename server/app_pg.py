"""
Postgres app DB (зеркало Firestore). Пока dual-write: ошибки PG не валят основной поток.
DATABASE_URL из env или /root/cab_drive_database_url.txt
"""
from __future__ import annotations

import json
import logging
import os
from contextlib import contextmanager
from typing import Any, Optional

logger = logging.getLogger(__name__)

_pool = None
_disabled_logged = False

_DEFAULT_URL_FILE = "/root/cab_drive_database_url.txt"


def _database_url() -> Optional[str]:
    url = (os.environ.get("DATABASE_URL") or "").strip()
    if url:
        return url
    try:
        if os.path.isfile(_DEFAULT_URL_FILE):
            with open(_DEFAULT_URL_FILE, "r", encoding="utf-8") as f:
                return f.read().strip() or None
    except Exception:
        pass
    return None


def enabled() -> bool:
    return bool(_database_url())


def _get_pool():
    global _pool, _disabled_logged
    url = _database_url()
    if not url:
        if not _disabled_logged:
            logger.warning("[app_pg] DATABASE_URL not set — dual-write disabled")
            _disabled_logged = True
        return None
    if _pool is not None:
        return _pool
    try:
        from psycopg2 import pool as pg_pool

        _pool = pg_pool.ThreadedConnectionPool(1, 8, url)
        logger.info("[app_pg] connection pool ready")
        return _pool
    except Exception:
        logger.exception("[app_pg] failed to init pool")
        return None


@contextmanager
def connection():
    p = _get_pool()
    if p is None:
        yield None
        return
    conn = p.getconn()
    try:
        yield conn
        conn.commit()
    except Exception:
        try:
            conn.rollback()
        except Exception:
            pass
        raise
    finally:
        p.putconn(conn)


def soft_execute(fn_name: str, fn) -> bool:
    """Выполнить fn(conn); при ошибке — лог, False."""
    try:
        with connection() as conn:
            if conn is None:
                return False
            fn(conn)
        return True
    except Exception:
        logger.exception("[app_pg] %s failed", fn_name)
        return False


def mirror_user_fields(user_id: str, fields: dict[str, Any]) -> bool:
    """Частичный UPDATE app_users. Неизвестные ключи игнорируются."""
    if not user_id or not fields:
        return False
    allowed = {
        "email",
        "display_name",
        "photo_url",
        "phone_number",
        "is_driver",
        "is_blocked",
        "block_comment",
        "verif_compl",
        "verif_ne_proidena",
        "on_verif_now",
        "verif_id",
        "login_complete",
        "admin",
        "dfb",
        "car_json",
        "addresses_json",
        "balance",
        "bonus_balance",
        "commission_percent",
        "current_commision",
        "on_shift",
        "fine",
        "surname",
        "city",
        "region",
        "email_user",
        "last_online",
        "shift_start_date_time",
        "shift_completion_date_time",
        "driver_lat",
        "driver_lng",
        "fb_id",
        "chat_with_support_id",
        "current_order_json",
    }
    jsonb_keys = {"car_json", "addresses_json", "current_order_json"}

    cols = []
    vals = []
    for k, v in fields.items():
        if k not in allowed:
            continue
        if k in jsonb_keys:
            cols.append(f"{k} = %s::jsonb")
            vals.append(json.dumps(v, ensure_ascii=False) if v is not None else None)
        else:
            cols.append(f"{k} = %s")
            vals.append(v)
    if not cols:
        return False
    cols.append("updated_at = NOW()")
    vals.append(user_id)

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                f"UPDATE app_users SET {', '.join(cols)} WHERE id = %s",
                vals,
            )
            if cur.rowcount == 0:
                # пользователя ещё нет в PG — создаём минимальную строку
                cur.execute(
                    """
                    INSERT INTO app_users (id, updated_at)
                    VALUES (%s, NOW())
                    ON CONFLICT (id) DO NOTHING
                    """,
                    (user_id,),
                )
                cur.execute(
                    f"UPDATE app_users SET {', '.join(cols)} WHERE id = %s",
                    vals,
                )

    return soft_execute("mirror_user_fields", _run)


def increment_user_balance(user_id: str, delta: float) -> bool:
    if not user_id or not delta:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_users (id, balance, updated_at)
                VALUES (%s, %s, NOW())
                ON CONFLICT (id) DO UPDATE SET
                    balance = COALESCE(app_users.balance, 0) + EXCLUDED.balance,
                    updated_at = NOW()
                """,
                (user_id, delta),
            )

    return soft_execute("increment_user_balance", _run)


def increment_user_bonus(user_id: str, delta: float) -> bool:
    if not user_id or not delta:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_users (id, bonus_balance, updated_at)
                VALUES (%s, %s, NOW())
                ON CONFLICT (id) DO UPDATE SET
                    bonus_balance = COALESCE(app_users.bonus_balance, 0) + EXCLUDED.bonus_balance,
                    updated_at = NOW()
                """,
                (user_id, delta),
            )

    return soft_execute("increment_user_bonus", _run)


def mirror_pay_order_paid(
    pay_order_id: str,
    *,
    is_paid: bool = True,
    tinkoff_status: str | None = None,
    payment_id: str | None = None,
) -> bool:
    if not pay_order_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_pay_orders (id, is_paid, tinkoff_status, payment_id, updated_at)
                VALUES (%s, %s, %s, %s, NOW())
                ON CONFLICT (id) DO UPDATE SET
                    is_paid = EXCLUDED.is_paid,
                    tinkoff_status = COALESCE(EXCLUDED.tinkoff_status, app_pay_orders.tinkoff_status),
                    payment_id = COALESCE(EXCLUDED.payment_id, app_pay_orders.payment_id),
                    updated_at = NOW()
                """,
                (pay_order_id, is_paid, tinkoff_status, payment_id),
            )

    return soft_execute("mirror_pay_order_paid", _run)


def upsert_pay_order(pay_order_id: str, data: dict[str, Any]) -> bool:
    if not pay_order_id:
        return False
    payload = _jsonable(data)
    payload["id"] = pay_order_id
    user_id = _ref_id(payload.get("user") or payload.get("user_id"))
    driver_id = _ref_id(payload.get("driver") or payload.get("driver_id"))
    order_id = payload.get("order_id") or payload.get("orderId")
    current_order_id = _ref_id(
        payload.get("current_order_doc_ref") or payload.get("current_order_id")
    )
    amount = payload.get("amount_in_cop") or payload.get("amountInCop")
    payment_id = payload.get("paymentId") or payload.get("payment_id")
    is_paid = bool(payload.get("is_paid") or payload.get("isPaid") or False)
    payment_type = payload.get("payment_type") or payload.get("paymentType")
    list_users = payload.get("list_users_upd_ballance") or payload.get("list_users_upd_balance") or []
    if isinstance(list_users, list):
        list_users = [_ref_id(x) for x in list_users if _ref_id(x)]
    else:
        list_users = []
    summ = payload.get("summ_upd_ballance") or payload.get("summ_upd_balance")

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_pay_orders (
                    id, order_id, amount_in_cop, user_id, driver_id, is_paid,
                    payment_id, current_order_id, payment_type,
                    list_users_upd_balance, summ_upd_balance, tinkoff_status,
                    raw_json, updated_at
                ) VALUES (
                    %s, %s, %s, %s, %s, %s,
                    %s, %s, %s,
                    %s, %s, %s,
                    %s::jsonb, NOW()
                )
                ON CONFLICT (id) DO UPDATE SET
                    order_id = COALESCE(EXCLUDED.order_id, app_pay_orders.order_id),
                    amount_in_cop = COALESCE(EXCLUDED.amount_in_cop, app_pay_orders.amount_in_cop),
                    user_id = COALESCE(EXCLUDED.user_id, app_pay_orders.user_id),
                    driver_id = COALESCE(EXCLUDED.driver_id, app_pay_orders.driver_id),
                    is_paid = EXCLUDED.is_paid OR app_pay_orders.is_paid,
                    payment_id = COALESCE(EXCLUDED.payment_id, app_pay_orders.payment_id),
                    current_order_id = COALESCE(EXCLUDED.current_order_id, app_pay_orders.current_order_id),
                    payment_type = COALESCE(EXCLUDED.payment_type, app_pay_orders.payment_type),
                    list_users_upd_balance = COALESCE(EXCLUDED.list_users_upd_balance, app_pay_orders.list_users_upd_balance),
                    summ_upd_balance = COALESCE(EXCLUDED.summ_upd_balance, app_pay_orders.summ_upd_balance),
                    tinkoff_status = COALESCE(EXCLUDED.tinkoff_status, app_pay_orders.tinkoff_status),
                    raw_json = COALESCE(app_pay_orders.raw_json, '{}'::jsonb) || EXCLUDED.raw_json,
                    updated_at = NOW()
                """,
                (
                    pay_order_id,
                    order_id,
                    amount,
                    user_id,
                    driver_id,
                    is_paid,
                    str(payment_id) if payment_id is not None else None,
                    current_order_id,
                    str(payment_type) if payment_type is not None else None,
                    list_users,
                    summ,
                    payload.get("tinkoff_status"),
                    json.dumps(payload, ensure_ascii=False),
                ),
            )

    return soft_execute("upsert_pay_order", _run)


def find_pay_orders_by_payment_id(payment_id: str) -> list[dict]:
    if not payment_id or not enabled():
        return []

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, order_id, amount_in_cop, user_id, driver_id, is_paid,
                       payment_id, current_order_id, payment_type,
                       list_users_upd_balance, summ_upd_balance, tinkoff_status,
                       tinkoff_error_code, tinkoff_message, raw_json
                FROM app_pay_orders
                WHERE payment_id = %s OR payment_id = %s
                LIMIT 10
                """,
                (str(payment_id), str(payment_id)),
            )
            desc = [c[0] for c in cur.description]
            out = []
            for row in cur.fetchall():
                d = dict(zip(desc, row))
                raw = _loads_json(d.get("raw_json")) or {}
                if isinstance(raw, dict):
                    merged = dict(raw)
                else:
                    merged = {}
                merged.update(
                    {
                        "id": d["id"],
                        "is_paid": d.get("is_paid"),
                        "paymentId": d.get("payment_id"),
                        "amount_in_cop": d.get("amount_in_cop"),
                        "user_id": d.get("user_id"),
                        "current_order_id": d.get("current_order_id"),
                        "list_users_upd_ballance": d.get("list_users_upd_balance") or [],
                        "summ_upd_ballance": float(d["summ_upd_balance"])
                        if d.get("summ_upd_balance") is not None
                        else None,
                        "tinkoff_status": d.get("tinkoff_status"),
                        "_source": "postgres",
                    }
                )
                out.append(merged)
            return out

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] find_pay_orders_by_payment_id failed")
        return []


def get_pay_order(pay_order_id: str) -> Optional[dict]:
    if not pay_order_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, order_id, amount_in_cop, user_id, driver_id, is_paid, payment_id,
                       current_order_id, payment_type, list_users_upd_balance,
                       summ_upd_balance, tinkoff_status, tinkoff_error_code,
                       tinkoff_message, raw_json
                FROM app_pay_orders WHERE id = %s
                """,
                (pay_order_id,),
            )
            row = cur.fetchone()
            if not row:
                return None
            desc = [c[0] for c in cur.description]
            d = dict(zip(desc, row))
            raw = _loads_json(d.get("raw_json")) or {}
            merged = dict(raw) if isinstance(raw, dict) else {}
            merged.update(
                {
                    "id": d["id"],
                    "is_paid": d.get("is_paid"),
                    "isPaid": d.get("is_paid"),
                    "paymentId": d.get("payment_id"),
                    "amount_in_cop": d.get("amount_in_cop"),
                    "user_id": d.get("user_id"),
                    "driver_id": d.get("driver_id"),
                    "current_order_id": d.get("current_order_id"),
                    "tinkoff_status": d.get("tinkoff_status"),
                    "tinkoff_error_code": d.get("tinkoff_error_code"),
                    "tinkoff_message": d.get("tinkoff_message"),
                    "_source": "postgres",
                }
            )
            return merged

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_pay_order failed")
        return None


def mirror_order_paid(order_id: str, is_paid: bool = True) -> bool:
    if not order_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_orders (id, is_paid, updated_at)
                VALUES (%s, %s, NOW())
                ON CONFLICT (id) DO UPDATE SET
                    is_paid = EXCLUDED.is_paid,
                    updated_at = NOW()
                """,
                (order_id, is_paid),
            )

    return soft_execute("mirror_order_paid", _run)


def _json_default(obj: Any):
    from datetime import date, datetime
    from decimal import Decimal

    if isinstance(obj, datetime):
        return obj.isoformat()
    if isinstance(obj, date):
        return obj.isoformat()
    if isinstance(obj, Decimal):
        return float(obj)
    try:
        from google.cloud.firestore_v1 import DocumentReference, GeoPoint

        if isinstance(obj, DocumentReference):
            return {"_ref": obj.path}
        if isinstance(obj, GeoPoint):
            return {"_geo": {"lat": obj.latitude, "lng": obj.longitude}}
    except Exception:
        pass
    if hasattr(obj, "path"):
        return {"_ref": str(obj.path)}
    return str(obj)


def _jsonable(obj: Any) -> Any:
    return json.loads(json.dumps(obj, default=_json_default))


def _ref_id(val: Any) -> Optional[str]:
    if val is None:
        return None
    if isinstance(val, dict) and "_ref" in val:
        return str(val["_ref"]).rsplit("/", 1)[-1]
    if hasattr(val, "id"):
        return str(val.id)
    if isinstance(val, str) and "/" in val:
        return val.rsplit("/", 1)[-1]
    if isinstance(val, str) and val:
        return val
    return None


# Firestore-имя поля → колонка app_orders (остальное только в raw_json)
_ORDER_FIELD_COLS = {
    "status": "status",
    "status_do_hidden": "status_do_hidden",
    "budget": "budget",
    "distance": "distance",
    "currentPrice": "current_price",
    "current_price": "current_price",
    "commissionPercent": "commission_percent",
    "commission_percent": "commission_percent",
    "is_paid": "is_paid",
    "description": "description",
    "date_upd": "date_upd",
    "pointA": "point_a_json",
    "pointB": "point_b_json",
    "pointC": "point_c_json",
    "selected_driver": "selected_driver_id",
    "selected_driver_id": "selected_driver_id",
    "user_customer": "user_customer_id",
    "user_customer_id": "user_customer_id",
    "driver_lat": "driver_lat",
    "driver_lng": "driver_lng",
    "time_left": "time_left",
    "km_left": "km_left",
    "statusDoHidden": "status_do_hidden",
}


def mirror_order_fields(order_id: str, fields: dict[str, Any]) -> bool:
    """Частичный UPDATE app_orders + merge в raw_json. Ошибки → soft False."""
    if not order_id or not fields:
        return False

    patch = _jsonable(fields)
    set_parts: list[str] = []
    vals: list[Any] = []
    seen_cols: set[str] = set()

    for key, val in patch.items():
        col = _ORDER_FIELD_COLS.get(key)
        if not col or col in seen_cols:
            continue
        seen_cols.add(col)
        if col in ("point_a_json", "point_b_json", "point_c_json"):
            set_parts.append(f"{col} = %s::jsonb")
            vals.append(json.dumps(val, ensure_ascii=False))
        elif col in ("selected_driver_id", "user_customer_id"):
            set_parts.append(f"{col} = %s")
            vals.append(_ref_id(val) if not isinstance(val, str) or "/" in str(val) else val)
        else:
            set_parts.append(f"{col} = %s")
            vals.append(val)

    set_parts.append("raw_json = COALESCE(raw_json, '{}'::jsonb) || %s::jsonb")
    vals.append(json.dumps(patch, ensure_ascii=False))
    set_parts.append("updated_at = NOW()")
    vals.append(order_id)

    sql = f"UPDATE app_orders SET {', '.join(set_parts)} WHERE id = %s"

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(sql, vals)
            if cur.rowcount == 0:
                cur.execute(
                    """
                    INSERT INTO app_orders (id, updated_at)
                    VALUES (%s, NOW())
                    ON CONFLICT (id) DO NOTHING
                    """,
                    (order_id,),
                )
                cur.execute(sql, vals)

    return soft_execute("mirror_order_fields", _run)


def mirror_user_queue_add(user_id: str, order_id: str) -> bool:
    """Добавить order_id в active_orders_queue (аналог ArrayUnion)."""
    if not user_id or not order_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_users (id, active_orders_queue, updated_at)
                VALUES (%s, ARRAY[%s]::text[], NOW())
                ON CONFLICT (id) DO UPDATE SET
                    active_orders_queue = (
                        SELECT ARRAY(
                            SELECT DISTINCT x
                            FROM unnest(
                                COALESCE(app_users.active_orders_queue, '{}'::text[])
                                || ARRAY[EXCLUDED.active_orders_queue[1]]
                            ) AS t(x)
                        )
                    ),
                    updated_at = NOW()
                """,
                (user_id, order_id),
            )

    return soft_execute("mirror_user_queue_add", _run)


def mirror_user_queue_remove(user_id: str, order_id: str) -> bool:
    """Убрать order_id из active_orders_queue (аналог ArrayRemove)."""
    if not user_id or not order_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE app_users SET
                    active_orders_queue = array_remove(
                        COALESCE(active_orders_queue, '{}'::text[]),
                        %s
                    ),
                    updated_at = NOW()
                WHERE id = %s
                """,
                (order_id, user_id),
            )

    return soft_execute("mirror_user_queue_remove", _run)


def get_user_queue(user_id: str) -> list[str]:
    if not user_id or not enabled():
        return []

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                "SELECT active_orders_queue FROM app_users WHERE id = %s",
                (user_id,),
            )
            row = cur.fetchone()
            if not row or row[0] is None:
                return []
            return [str(x) for x in row[0]]

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn) or []
    except Exception:
        logger.exception("[app_pg] get_user_queue failed id=%s", user_id)
        return []


def create_order(order_id: str, data: dict[str, Any]) -> bool:
    """INSERT/UPSERT полного заказа в app_orders (+ raw_json)."""
    if not order_id or not data:
        return False
    payload = _jsonable(data)
    payload["id"] = order_id
    customer = _ref_id(payload.get("user_customer") or payload.get("user_customer_id"))
    driver = _ref_id(payload.get("selected_driver") or payload.get("selected_driver_id"))
    status = payload.get("status") or "newOrder"
    budget = payload.get("budget")
    current_price = payload.get("currentPrice") or payload.get("current_price")
    distance = payload.get("distance")
    description = payload.get("description")
    point_a = payload.get("pointA")
    point_b = payload.get("pointB")
    created = payload.get("dateTime_created") or payload.get("date_time_created")

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_orders (
                    id, status, user_customer_id, selected_driver_id,
                    budget, current_price, distance, description,
                    point_a_json, point_b_json, date_time_created, raw_json, updated_at
                ) VALUES (
                    %s, %s, %s, %s,
                    %s, %s, %s, %s,
                    %s::jsonb, %s::jsonb, %s, %s::jsonb, NOW()
                )
                ON CONFLICT (id) DO UPDATE SET
                    status = EXCLUDED.status,
                    user_customer_id = COALESCE(EXCLUDED.user_customer_id, app_orders.user_customer_id),
                    selected_driver_id = COALESCE(EXCLUDED.selected_driver_id, app_orders.selected_driver_id),
                    budget = COALESCE(EXCLUDED.budget, app_orders.budget),
                    current_price = COALESCE(EXCLUDED.current_price, app_orders.current_price),
                    distance = COALESCE(EXCLUDED.distance, app_orders.distance),
                    description = COALESCE(EXCLUDED.description, app_orders.description),
                    point_a_json = COALESCE(EXCLUDED.point_a_json, app_orders.point_a_json),
                    point_b_json = COALESCE(EXCLUDED.point_b_json, app_orders.point_b_json),
                    raw_json = EXCLUDED.raw_json,
                    updated_at = NOW()
                """,
                (
                    order_id,
                    status,
                    customer,
                    driver,
                    budget,
                    current_price,
                    distance,
                    description,
                    json.dumps(point_a, ensure_ascii=False) if point_a is not None else None,
                    json.dumps(point_b, ensure_ascii=False) if point_b is not None else None,
                    created,
                    json.dumps(payload, ensure_ascii=False),
                ),
            )

    return soft_execute("create_order", _run)


def list_orders_for_user(
    *,
    customer_id: Optional[str] = None,
    driver_id: Optional[str] = None,
    status: Optional[str] = None,
    limit: int = 50,
) -> list[dict]:
    if not enabled():
        return []
    if not customer_id and not driver_id and not status:
        return list_orders(status=status, limit=limit)

    def _run(conn):
        sql = [
            """
            SELECT id, status, selected_driver_id, user_customer_id, budget, distance,
                   date_time_created, is_paid, point_a_json, point_b_json, description, raw_json
            FROM app_orders WHERE 1=1
            """
        ]
        params: list[Any] = []
        if customer_id:
            sql.append(" AND user_customer_id = %s")
            params.append(customer_id)
        if driver_id:
            sql.append(
                " AND (selected_driver_id = %s"
                " OR %s = ANY(COALESCE(user_who_responced, '{}'::text[])))"
            )
            params.append(driver_id)
            params.append(driver_id)
        if status:
            sql.append(" AND status = %s")
            params.append(status)
        sql.append(
            " ORDER BY date_upd DESC NULLS LAST,"
            " date_time_created DESC NULLS LAST LIMIT %s"
        )
        params.append(limit)
        with conn.cursor() as cur:
            cur.execute("".join(sql), params)
            desc = [c[0] for c in cur.description]
            return [_order_row_to_admin_json(dict(zip(desc, row))) for row in cur.fetchall()]

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_orders_for_user failed")
        return []


def _row_to_user_json(row: dict) -> dict:
    """Формат как users.api.firebase_user_to_json (для админки)."""
    value = {
        "id": row.get("id"),
        "admin": row.get("admin"),
        "email": row.get("email"),
        "display_name": row.get("display_name"),
        "is_driver": row.get("is_driver"),
        "login_complete": row.get("login_complete"),
        "created_time": row.get("created_time"),
        "fcm_tokens": [],
        "photo_url": row.get("photo_url"),
        "phone_number": row.get("phone_number"),
        "verif_ne_proidena": row.get("verif_ne_proidena"),
        "on_verif_now": row.get("on_verif_now"),
        "verif_compl": row.get("verif_compl"),
        "verif_id": int(row["verif_id"]) if row.get("verif_id") is not None else None,
        "balance": float(row["balance"]) if row.get("balance") is not None else 0,
        "bonus_balance": float(row["bonus_balance"]) if row.get("bonus_balance") is not None else 0,
        "commission": float(row["commission_percent"]) if row.get("commission_percent") is not None else None,
        "fb_id": row.get("fb_id"),
        "_source": "postgres",
    }
    if row.get("is_blocked") is not None:
        value["is_blocked"] = row.get("is_blocked")
        value["block_comment"] = row.get("block_comment")
    return value


def _row_to_me_json(row: dict) -> dict:
    """Профиль МП: баланс + флаги смены/долга + поля сессии UI."""
    base = _row_to_user_json(row)
    queue = row.get("active_orders_queue") or []
    if not isinstance(queue, list):
        queue = list(queue) if queue else []
    addresses = _loads_json(row.get("addresses_json"))
    car = _loads_json(row.get("car_json"))
    current_order = _loads_json(row.get("current_order_json"))
    base.update(
        {
            "surname": row.get("surname"),
            "city": row.get("city"),
            "region": row.get("region"),
            "on_shift": bool(row.get("on_shift")) if row.get("on_shift") is not None else False,
            "fine": bool(row.get("fine")) if row.get("fine") is not None else False,
            "current_commision": float(row["current_commision"])
            if row.get("current_commision") is not None
            else 0,
            "email_user": row.get("email_user"),
            "active_orders_queue": [str(x) for x in queue],
            "driver_lat": row.get("driver_lat"),
            "driver_lng": row.get("driver_lng"),
            "dfb": row.get("dfb").isoformat() if row.get("dfb") is not None else None,
            "city_lat": row.get("city_lat"),
            "city_lng": row.get("city_lng"),
            "shift_start_date_time": row.get("shift_start_date_time").isoformat()
            if row.get("shift_start_date_time") is not None
            else None,
            "shift_completion_date_time": row.get("shift_completion_date_time").isoformat()
            if row.get("shift_completion_date_time") is not None
            else None,
            "average_rating": float(row["average_rating"])
            if row.get("average_rating") is not None
            else 0,
            "number_of_reviews": int(row["number_of_reviews"])
            if row.get("number_of_reviews") is not None
            else 0,
            "additional_phone_number": row.get("additional_phone_number"),
            "chat_with_support_id": row.get("chat_with_support_id"),
            "addresses": addresses if isinstance(addresses, list) else addresses,
            "car": car if isinstance(car, dict) else None,
            "current_order": current_order if isinstance(current_order, dict) else None,
        }
    )
    return base


def get_me(user_id: str) -> Optional[dict]:
    """Профиль для GET /api/app/me."""
    if not user_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, admin, email, display_name, is_driver, login_complete, created_time,
                       photo_url, phone_number, verif_ne_proidena, on_verif_now, verif_compl,
                       verif_id,
                       balance, bonus_balance, commission_percent, fb_id, is_blocked, block_comment,
                       surname, city, region, on_shift, fine, current_commision, email_user,
                       active_orders_queue, driver_lat, driver_lng,
                       dfb, city_lat, city_lng, shift_start_date_time, shift_completion_date_time,
                       average_rating, number_of_reviews, additional_phone_number,
                       chat_with_support_id, car_json, addresses_json, current_order_json
                FROM app_users WHERE id = %s
                """,
                (user_id,),
            )
            desc = [c[0] for c in cur.description]
            row = cur.fetchone()
            if not row:
                return None
            return _row_to_me_json(dict(zip(desc, row)))

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_me failed id=%s", user_id)
        return None


def get_public_user(user_id: str) -> Optional[dict]:
    """Публичный профиль peer для карточек МП (без balance/admin/queue)."""
    if not user_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, display_name, surname, photo_url, phone_number,
                       is_driver, verif_compl, commission_percent,
                       average_rating, number_of_reviews, last_online,
                       car_json
                FROM app_users WHERE id = %s
                """,
                (user_id,),
            )
            desc = [c[0] for c in cur.description]
            row = cur.fetchone()
            if not row:
                return None
            d = dict(zip(desc, row))
            car = _loads_json(d.get("car_json"))
            return {
                "id": d.get("id"),
                "uid": d.get("id"),
                "display_name": d.get("display_name"),
                "surname": d.get("surname"),
                "photo_url": d.get("photo_url"),
                "phone_number": d.get("phone_number"),
                "is_driver": d.get("is_driver"),
                "verif_compl": d.get("verif_compl"),
                "commission": float(d["commission_percent"])
                if d.get("commission_percent") is not None
                else None,
                "commission_percent": float(d["commission_percent"])
                if d.get("commission_percent") is not None
                else None,
                "average_rating": float(d["average_rating"])
                if d.get("average_rating") is not None
                else 0,
                "number_of_reviews": int(d["number_of_reviews"])
                if d.get("number_of_reviews") is not None
                else 0,
                "last_online": d.get("last_online").isoformat()
                if d.get("last_online") is not None
                else None,
                "car": car if isinstance(car, dict) else None,
                "_source": "postgres",
            }

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_public_user failed id=%s", user_id)
        return None


def get_user(user_id: str) -> Optional[dict]:
    if not user_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, admin, email, display_name, is_driver, login_complete, created_time,
                       photo_url, phone_number, verif_ne_proidena, on_verif_now, verif_compl,
                       balance, bonus_balance, commission_percent, fb_id, is_blocked, block_comment
                FROM app_users WHERE id = %s
                """,
                (user_id,),
            )
            desc = [c[0] for c in cur.description]
            row = cur.fetchone()
            if not row:
                return None
            return _row_to_user_json(dict(zip(desc, row)))

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_user failed id=%s", user_id)
        return None


def list_drivers_for_geo(
    *,
    on_shift: bool = True,
    require_location: bool = True,
    limit: int = 500,
) -> list[dict]:
    """
    Водители для pickup/extra: id, on_shift, lat/lng, car, queue, is_blocked.
    Формат совместим с get_me (driver_lat/lng, car, active_orders_queue).
    """
    if not enabled():
        return []

    def _run(conn):
        sql = [
            """
            SELECT id, is_driver, on_shift, is_blocked, driver_lat, driver_lng,
                   car_json, active_orders_queue
            FROM app_users
            WHERE COALESCE(is_driver, false) = true
            """
        ]
        params: list[Any] = []
        if on_shift:
            sql.append(" AND COALESCE(on_shift, false) = true")
        if require_location:
            sql.append(" AND driver_lat IS NOT NULL AND driver_lng IS NOT NULL")
        sql.append(" ORDER BY updated_at DESC NULLS LAST LIMIT %s")
        params.append(limit)
        with conn.cursor() as cur:
            cur.execute("".join(sql), params)
            desc = [c[0] for c in cur.description]
            out: list[dict] = []
            for row in cur.fetchall():
                d = dict(zip(desc, row))
                queue = d.get("active_orders_queue") or []
                if not isinstance(queue, list):
                    queue = list(queue) if queue else []
                car = _loads_json(d.get("car_json"))
                lat = d.get("driver_lat")
                lng = d.get("driver_lng")
                out.append(
                    {
                        "id": d.get("id"),
                        "uid": d.get("id"),
                        "is_driver": True,
                        "on_shift": bool(d.get("on_shift")) if d.get("on_shift") is not None else False,
                        "is_blocked": bool(d.get("is_blocked")) if d.get("is_blocked") is not None else False,
                        "driver_lat": lat,
                        "driver_lng": lng,
                        "driver_location": {
                            "latitude": float(lat),
                            "longitude": float(lng),
                        }
                        if lat is not None and lng is not None
                        else None,
                        "car": car if isinstance(car, dict) else None,
                        "active_orders_queue": [str(x) for x in queue],
                        "_source": "postgres",
                    }
                )
            return out

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_drivers_for_geo failed")
        return []


def list_orders_by_statuses(
    statuses: list[str],
    *,
    limit_per_status: int = 200,
) -> list[dict]:
    """Несколько статусов для busy-drivers / notify."""
    if not statuses or not enabled():
        return []
    out: list[dict] = []
    seen: set[str] = set()
    for st in statuses:
        for row in list_orders(status=st, limit=limit_per_status):
            oid = str(row.get("id") or "")
            if not oid or oid in seen:
                continue
            seen.add(oid)
            out.append(row)
    return out


def list_users(
    *,
    is_driver: Optional[bool] = None,
    on_verif_now: Optional[bool] = None,
    login_complete: Optional[bool] = None,
    query: Optional[str] = None,
    limit: int = 500,
) -> list[dict]:
    if not enabled():
        return []

    def _run(conn):
        sql = [
            """
            SELECT id, admin, email, display_name, is_driver, login_complete, created_time,
                   photo_url, phone_number, verif_ne_proidena, on_verif_now, verif_compl,
                   balance, bonus_balance, commission_percent, fb_id, is_blocked, block_comment
            FROM app_users WHERE 1=1
            """
        ]
        params: list[Any] = []
        if is_driver is not None:
            sql.append(" AND is_driver = %s")
            params.append(is_driver)
        if on_verif_now is not None:
            sql.append(" AND on_verif_now = %s")
            params.append(on_verif_now)
        if login_complete is not None:
            sql.append(" AND login_complete = %s")
            params.append(login_complete)
        if query:
            q = f"%{query.strip()}%"
            sql.append(
                " AND (phone_number ILIKE %s OR display_name ILIKE %s OR email ILIKE %s OR id ILIKE %s)"
            )
            params.extend([q, q, q, q])
        sql.append(" ORDER BY created_time DESC NULLS LAST LIMIT %s")
        params.append(limit)
        with conn.cursor() as cur:
            cur.execute("".join(sql), params)
            desc = [c[0] for c in cur.description]
            return [_row_to_user_json(dict(zip(desc, row))) for row in cur.fetchall()]

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_users failed")
        return []


def list_orders(*, status: Optional[str] = None, limit: int = 100) -> list[dict]:
    result = list_orders_filtered(status=status, limit=limit, offset=0)
    return result.get("orders") or []


def list_orders_filtered(
    *,
    status: Optional[str] = None,
    customer_id: Optional[str] = None,
    driver_id: Optional[str] = None,
    start_dt: Optional[Any] = None,
    end_dt: Optional[Any] = None,
    budget_min: Optional[float] = None,
    budget_max: Optional[float] = None,
    distance_min: Optional[float] = None,
    distance_max: Optional[float] = None,
    limit: int = 100,
    offset: int = 0,
) -> dict:
    """Admin list: filters + COUNT. Returns {orders, total}."""
    if not enabled():
        return {"orders": [], "total": 0}

    def _run(conn):
        where = ["1=1"]
        params: list[Any] = []
        if status:
            where.append("status = %s")
            params.append(status)
        if customer_id:
            where.append("user_customer_id = %s")
            params.append(customer_id)
        if driver_id:
            where.append("selected_driver_id = %s")
            params.append(driver_id)
        if start_dt is not None:
            where.append("date_time_created >= %s")
            params.append(start_dt)
        if end_dt is not None:
            where.append("date_time_created <= %s")
            params.append(end_dt)
        if budget_min is not None:
            where.append("budget >= %s")
            params.append(budget_min)
        if budget_max is not None:
            where.append("budget <= %s")
            params.append(budget_max)
        if distance_min is not None:
            where.append("distance >= %s")
            params.append(distance_min)
        if distance_max is not None:
            where.append("distance <= %s")
            params.append(distance_max)
        wh = " AND ".join(where)
        with conn.cursor() as cur:
            cur.execute(f"SELECT COUNT(*) FROM app_orders WHERE {wh}", params)
            total = int(cur.fetchone()[0] or 0)
            cur.execute(
                f"""
                SELECT id, status, selected_driver_id, user_customer_id, budget, distance,
                       date_time_created, is_paid, point_a_json, point_b_json, description, raw_json
                FROM app_orders WHERE {wh}
                ORDER BY date_time_created DESC NULLS LAST
                LIMIT %s OFFSET %s
                """,
                params + [limit, offset],
            )
            desc = [c[0] for c in cur.description]
            rows = [
                _order_row_to_admin_json(dict(zip(desc, row)))
                for row in cur.fetchall()
            ]
            return {"orders": rows, "total": total}

    try:
        with connection() as conn:
            if conn is None:
                return {"orders": [], "total": 0}
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_orders_filtered failed")
        return {"orders": [], "total": 0}


def sum_driver_completed_budget(
    driver_id: str,
    *,
    start_dt: Optional[Any] = None,
    end_dt: Optional[Any] = None,
) -> Optional[float]:
    if not driver_id or not enabled():
        return None

    def _run(conn):
        sql = [
            """
            SELECT COALESCE(SUM(budget), 0)
            FROM app_orders
            WHERE selected_driver_id = %s AND status = 'completed'
            """
        ]
        params: list[Any] = [driver_id]
        if start_dt is not None:
            sql.append(" AND date_time_created >= %s")
            params.append(start_dt)
        if end_dt is not None:
            sql.append(" AND date_time_created <= %s")
            params.append(end_dt)
        with conn.cursor() as cur:
            cur.execute("".join(sql), params)
            return float(cur.fetchone()[0] or 0)

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] sum_driver_completed_budget failed")
        return None


def driver_order_stats(
    driver_id: str,
    *,
    month_start: Any,
    month_end: Any,
) -> Optional[dict]:
    """
    Stats for dashboard user page.
    monthly_balance: same semantics as legacy FS — SUM budget of ALL completed
    (not only month). total_orders = count of driver's orders in month.
    """
    if not driver_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT COALESCE(SUM(budget), 0), COUNT(*), MAX(date_time_created)
                FROM app_orders
                WHERE selected_driver_id = %s AND status = 'completed'
                """,
                (driver_id,),
            )
            row = cur.fetchone()
            monthly_balance = float(row[0] or 0)
            completed_orders = int(row[1] or 0)
            last_dt = row[2]
            cur.execute(
                """
                SELECT COUNT(*)
                FROM app_orders
                WHERE selected_driver_id = %s
                  AND date_time_created >= %s
                  AND date_time_created <= %s
                """,
                (driver_id, month_start, month_end),
            )
            total_orders = int(cur.fetchone()[0] or 0)
            return {
                "monthly_balance": monthly_balance,
                "last_transaction_date": last_dt.isoformat() if last_dt is not None else None,
                "total_orders": total_orders,
                "completed_orders": completed_orders,
                "_source": "postgres",
            }

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] driver_order_stats failed")
        return None


def _loads_json(val: Any) -> Any:
    if val is None:
        return None
    if isinstance(val, (dict, list)):
        return val
    if isinstance(val, str):
        try:
            return json.loads(val)
        except Exception:
            return None
    return val


def _order_row_to_admin_json(row: dict) -> dict:
    """Предпочтительно raw_json (полный документ), иначе колонки."""
    raw = _loads_json(row.get("raw_json"))
    if isinstance(raw, dict) and raw:
        data = dict(raw)
        data["id"] = row.get("id") or data.get("id")
        # refs → id как в firebase_order_to_json
        for key in ("selected_driver", "user_customer"):
            ref = data.get(key)
            if isinstance(ref, dict) and "_ref" in ref:
                data[key] = str(ref["_ref"]).rsplit("/", 1)[-1]
            elif hasattr(ref, "id"):
                data[key] = ref.id
        # колонки — SoT для владельца/водителя (raw может хранить только *_id)
        if row.get("user_customer_id"):
            data["user_customer"] = row["user_customer_id"]
            data["user_customer_id"] = row["user_customer_id"]
        elif data.get("user_customer_id") and not data.get("user_customer"):
            data["user_customer"] = data["user_customer_id"]
        if row.get("selected_driver_id"):
            data["selected_driver"] = row["selected_driver_id"]
            data["selected_driver_id"] = row["selected_driver_id"]
        elif data.get("selected_driver_id") and not data.get("selected_driver"):
            data["selected_driver"] = data["selected_driver_id"]
        if row.get("status"):
            data["status"] = row["status"]
        data["_source"] = "postgres"
        return data

    return {
        "id": row.get("id"),
        "status": row.get("status"),
        "selected_driver": row.get("selected_driver_id"),
        "user_customer": row.get("user_customer_id"),
        "budget": row.get("budget"),
        "distance": row.get("distance"),
        "dateTime_created": row.get("date_time_created"),
        "is_paid": row.get("is_paid"),
        "pointA": _loads_json(row.get("point_a_json")),
        "pointB": _loads_json(row.get("point_b_json")),
        "description": row.get("description"),
        "_source": "postgres",
    }


def get_order(order_id: str) -> Optional[dict]:
    if not order_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, status, selected_driver_id, user_customer_id, budget, distance,
                       date_time_created, is_paid, point_a_json, point_b_json, description, raw_json
                FROM app_orders WHERE id = %s
                """,
                (order_id,),
            )
            row = cur.fetchone()
            if not row:
                return None
            desc = [c[0] for c in cur.description]
            return _order_row_to_admin_json(dict(zip(desc, row)))

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_order failed id=%s", order_id)
        return None


def create_order_response(
    order_id: str,
    firestore_id: str,
    raw: dict[str, Any],
    *,
    driver_uid: Optional[str] = None,
) -> bool:
    if not order_id or not firestore_id:
        return False
    payload = _jsonable(raw)
    if driver_uid:
        payload["driver_id"] = driver_uid

    def _run(conn):
        with conn.cursor() as cur:
            # заказ обязан существовать (FK)
            cur.execute(
                """
                INSERT INTO app_orders (id, updated_at)
                VALUES (%s, NOW())
                ON CONFLICT (id) DO NOTHING
                """,
                (order_id,),
            )
            cur.execute(
                """
                INSERT INTO app_order_responses (order_id, firestore_id, raw_json)
                VALUES (%s, %s, %s::jsonb)
                ON CONFLICT (order_id, firestore_id) DO UPDATE SET
                    raw_json = EXCLUDED.raw_json
                """,
                (order_id, firestore_id, json.dumps(payload, ensure_ascii=False)),
            )

    return soft_execute("create_order_response", _run)


def list_order_responses(order_id: str) -> list[dict]:
    if not order_id or not enabled():
        return []

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT firestore_id, raw_json FROM app_order_responses
                WHERE order_id = %s ORDER BY id DESC
                """,
                (order_id,),
            )
            rows = []
            for fid, raw in cur.fetchall():
                data = _loads_json(raw) or {}
                if isinstance(data, dict):
                    data = dict(data)
                    data["id"] = fid or data.get("id")
                    data["_source"] = "postgres"
                    rows.append(data)
            return rows

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_order_responses failed")
        return []


def delete_order_response(
    order_id: str, firestore_id: str, *, driver_uid: Optional[str] = None
) -> bool:
    if not order_id or not firestore_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            if driver_uid:
                cur.execute(
                    """
                    DELETE FROM app_order_responses
                    WHERE order_id = %s AND firestore_id = %s
                      AND (raw_json->>'driver_id' = %s OR raw_json->'user_driver'->>'_ref' LIKE %s)
                    """,
                    (order_id, firestore_id, driver_uid, f"%/{driver_uid}"),
                )
            else:
                cur.execute(
                    """
                    DELETE FROM app_order_responses
                    WHERE order_id = %s AND firestore_id = %s
                    """,
                    (order_id, firestore_id),
                )
            if cur.rowcount == 0:
                raise ValueError("bid not found")

    return soft_execute("delete_order_response", _run)


def add_order_respondent(order_id: str, driver_uid: str) -> bool:
    if not order_id or not driver_uid:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE app_orders SET
                    count_resp = COALESCE(count_resp, 0) + 1,
                    user_who_responced = (
                        SELECT ARRAY(
                            SELECT DISTINCT x FROM unnest(
                                COALESCE(user_who_responced, '{}'::text[]) || ARRAY[%s]::text[]
                            ) AS t(x)
                        )
                    ),
                    raw_json = COALESCE(raw_json, '{}'::jsonb)
                        || jsonb_build_object('count_resp', COALESCE(count_resp, 0) + 1),
                    updated_at = NOW()
                WHERE id = %s
                """,
                (driver_uid, order_id),
            )

    return soft_execute("add_order_respondent", _run)


def remove_order_respondent(order_id: str, driver_uid: str) -> bool:
    if not order_id or not driver_uid:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE app_orders SET
                    count_resp = GREATEST(COALESCE(count_resp, 0) - 1, 0),
                    user_who_responced = array_remove(COALESCE(user_who_responced, '{}'::text[]), %s),
                    updated_at = NOW()
                WHERE id = %s
                """,
                (driver_uid, order_id),
            )

    return soft_execute("remove_order_respondent", _run)


def upsert_fcm_token(user_id: str, token: str) -> bool:
    if not user_id or not token:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_users (id, updated_at)
                VALUES (%s, NOW())
                ON CONFLICT (id) DO NOTHING
                """,
                (user_id,),
            )
            cur.execute(
                """
                INSERT INTO app_user_fcm_tokens (user_id, token)
                VALUES (%s, %s)
                ON CONFLICT (user_id, token) DO NOTHING
                """,
                (user_id, token),
            )

    return soft_execute("upsert_fcm_token", _run)


def list_fcm_tokens(user_ids: list[str]) -> list[str]:
    ids = [str(u).strip() for u in (user_ids or []) if str(u).strip()]
    if not ids or not enabled():
        return []

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT DISTINCT token FROM app_user_fcm_tokens
                WHERE user_id = ANY(%s) AND token IS NOT NULL AND token <> ''
                """,
                (ids,),
            )
            return [str(r[0]) for r in cur.fetchall() if r and r[0]]

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_fcm_tokens failed")
        return []


def delete_fcm_token(token: str) -> bool:
    if not token:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM app_user_fcm_tokens WHERE token = %s",
                (token,),
            )

    return soft_execute("delete_fcm_token", _run)


def create_review(
    review_id: str,
    raw: dict[str, Any],
    *,
    reviewed_uid: str,
    author_uid: str,
) -> bool:
    if not review_id or not reviewed_uid or not author_uid:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_reviews (
                    id, reviewed_user_id, author_user_id, text, rating,
                    name_author, order_id, date_created, raw_json
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, NOW(), %s::jsonb
                )
                ON CONFLICT (id) DO NOTHING
                """,
                (
                    review_id,
                    reviewed_uid,
                    author_uid,
                    raw.get("text") or "",
                    int(raw.get("rating") or 0),
                    raw.get("name_user_who_wrote") or raw.get("name_author"),
                    raw.get("order_id"),
                    json.dumps(raw, ensure_ascii=False),
                ),
            )

    return soft_execute("create_review", _run)


def list_reviews(
    *,
    reviewed_user_id: Optional[str] = None,
    author_user_id: Optional[str] = None,
    limit: int = 100,
) -> list[dict]:
    if not enabled():
        return []
    if not reviewed_user_id and not author_user_id:
        return []

    def _run(conn):
        sql = [
            """
            SELECT id, reviewed_user_id, author_user_id, text, rating,
                   name_author, order_id, date_created, raw_json
            FROM app_reviews WHERE 1=1
            """
        ]
        params: list[Any] = []
        if reviewed_user_id:
            sql.append(" AND reviewed_user_id = %s")
            params.append(reviewed_user_id)
        if author_user_id:
            sql.append(" AND author_user_id = %s")
            params.append(author_user_id)
        sql.append(" ORDER BY date_created DESC NULLS LAST LIMIT %s")
        params.append(limit)
        with conn.cursor() as cur:
            cur.execute("".join(sql), params)
            desc = [c[0] for c in cur.description]
            out = []
            for row in cur.fetchall():
                d = dict(zip(desc, row))
                raw = _loads_json(d.get("raw_json")) or {}
                if not isinstance(raw, dict):
                    raw = {}
                data = dict(raw)
                data["id"] = d.get("id")
                data["reviewed_user_id"] = d.get("reviewed_user_id")
                data["author_user_id"] = d.get("author_user_id")
                data["text"] = d.get("text") if d.get("text") is not None else data.get("text")
                data["rating"] = d.get("rating")
                data["name_user_who_wrote"] = d.get("name_author") or data.get(
                    "name_user_who_wrote"
                )
                data["date"] = (
                    d.get("date_created").isoformat()
                    if d.get("date_created") is not None
                    else data.get("date")
                )
                data["order_id"] = d.get("order_id")
                data["_source"] = "postgres"
                out.append(data)
            return out

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_reviews failed")
        return []


def apply_review_side_effects(
    *,
    reviewed_uid: str,
    rating: int,
    order_id: Optional[str],
    author_is_driver: bool,
) -> bool:
    if not reviewed_uid or not rating:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE app_users SET
                    average_rating = (
                        (COALESCE(average_rating, 0) * COALESCE(number_of_reviews, 0) + %s)
                        / GREATEST(COALESCE(number_of_reviews, 0) + 1, 1)
                    ),
                    number_of_reviews = COALESCE(number_of_reviews, 0) + 1,
                    updated_at = NOW()
                WHERE id = %s
                """,
                (float(rating), reviewed_uid),
            )
            if order_id:
                if author_is_driver:
                    cur.execute(
                        """
                        UPDATE app_orders SET customer_reviewed = TRUE, updated_at = NOW()
                        WHERE id = %s
                        """,
                        (order_id,),
                    )
                else:
                    cur.execute(
                        """
                        UPDATE app_orders SET driver_reviewed = TRUE, updated_at = NOW()
                        WHERE id = %s
                        """,
                        (order_id,),
                    )

    return soft_execute("apply_review_side_effects", _run)


def next_verification_number_id() -> Optional[int]:
    if not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT GREATEST(
                    COALESCE((SELECT MAX(number_id) FROM app_verifications), 0),
                    COALESCE((SELECT last_value FROM app_verifications_number_id_seq), 0)
                )
                """
            )
            base = int(cur.fetchone()[0] or 0)
            nxt = base + 1
            cur.execute("SELECT setval('app_verifications_number_id_seq', %s, true)", (nxt,))
            return nxt

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] next_verification_number_id failed")
        return None


def _verification_row_to_json(d: dict) -> dict:
    raw = _loads_json(d.get("raw_json")) or {}
    if not isinstance(raw, dict):
        raw = {}
    data = dict(raw)
    uid = d.get("user_id")
    data["id"] = d.get("id")
    data["user_id"] = uid
    data["user"] = {"_ref": f"users/{uid}"} if uid else None
    data["number_id"] = d.get("number_id")
    data["status"] = d.get("status")
    data["email"] = d.get("email")
    data["phone_number"] = d.get("phone_number")
    data["city"] = d.get("city")
    data["name"] = d.get("name")
    data["surname"] = d.get("surname")
    data["dfb"] = d.get("dfb").isoformat() if d.get("dfb") is not None else data.get("dfb")
    data["dateCreated"] = (
        d.get("date_created").isoformat()
        if d.get("date_created") is not None
        else data.get("dateCreated")
    )
    data["number_avto"] = d.get("number_avto")
    data["marka"] = d.get("marka")
    data["marka_avto"] = d.get("marka_avto")
    data["avatar"] = d.get("avatar")
    data["photo_doc"] = list(d.get("photo_doc") or [])
    data["photo_avto"] = list(d.get("photo_avto") or [])
    if d.get("commission_percent") is not None:
        data["commission_percent"] = float(d["commission_percent"])
    return data


def create_verification(
    ver_id: str,
    raw: dict[str, Any],
    *,
    user_id: str,
    number_id: int,
) -> bool:
    if not ver_id or not user_id or not number_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_verifications (
                    id, user_id, number_id, status, email, phone_number, city,
                    name, surname, dfb, date_created, number_avto, marka, marka_avto,
                    avatar, photo_doc, photo_avto, commission_percent, raw_json
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s,
                    %s, %s, %s, NOW(), %s, %s, %s,
                    %s, %s, %s, %s, %s::jsonb
                )
                ON CONFLICT (id) DO NOTHING
                """,
                (
                    ver_id,
                    user_id,
                    number_id,
                    raw.get("status") or "onVerif",
                    raw.get("email"),
                    raw.get("phone_number"),
                    raw.get("city"),
                    raw.get("name"),
                    raw.get("surname"),
                    raw.get("dfb"),
                    raw.get("number_avto"),
                    raw.get("marka"),
                    raw.get("marka_avto"),
                    raw.get("avatar"),
                    raw.get("photo_doc") or [],
                    raw.get("photo_avto") or [],
                    raw.get("commission_percent"),
                    json.dumps(raw, ensure_ascii=False),
                ),
            )

    return soft_execute("create_verification", _run)


def get_verification(ver_id: str) -> Optional[dict]:
    if not ver_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, user_id, number_id, status, email, phone_number, city,
                       name, surname, dfb, date_created, number_avto, marka, marka_avto,
                       avatar, photo_doc, photo_avto, commission_percent, raw_json
                FROM app_verifications WHERE id = %s
                """,
                (ver_id,),
            )
            row = cur.fetchone()
            if not row:
                return None
            desc = [c[0] for c in cur.description]
            return _verification_row_to_json(dict(zip(desc, row)))

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_verification failed")
        return None


def list_verifications(
    *,
    user_id: Optional[str] = None,
    status: Optional[str] = None,
    limit: int = 100,
) -> list[dict]:
    if not enabled():
        return []

    def _run(conn):
        sql = [
            """
            SELECT id, user_id, number_id, status, email, phone_number, city,
                   name, surname, dfb, date_created, number_avto, marka, marka_avto,
                   avatar, photo_doc, photo_avto, commission_percent, raw_json
            FROM app_verifications WHERE 1=1
            """
        ]
        params: list[Any] = []
        if user_id:
            sql.append(" AND user_id = %s")
            params.append(user_id)
        if status:
            sql.append(" AND status = %s")
            params.append(status)
        sql.append(" ORDER BY date_created DESC NULLS LAST LIMIT %s")
        params.append(limit)
        with conn.cursor() as cur:
            cur.execute("".join(sql), params)
            desc = [c[0] for c in cur.description]
            return [_verification_row_to_json(dict(zip(desc, row))) for row in cur.fetchall()]

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_verifications failed")
        return []


def count_verifications(*, user_id: str) -> int:
    if not user_id or not enabled():
        return 0

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                "SELECT COUNT(*) FROM app_verifications WHERE user_id = %s",
                (user_id,),
            )
            return int(cur.fetchone()[0] or 0)

    try:
        with connection() as conn:
            if conn is None:
                return 0
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] count_verifications failed")
        return 0


def set_verification_status(ver_id: str, status: str) -> bool:
    if not ver_id or not status:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE app_verifications
                SET status = %s, updated_at = NOW()
                WHERE id = %s
                """,
                (status, ver_id),
            )

    return soft_execute("set_verification_status", _run)


def get_latest_verification_for_user(
    user_id: str,
    *,
    prefer_status: Optional[str] = "onVerif",
) -> Optional[dict]:
    if not user_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            if prefer_status:
                cur.execute(
                    """
                    SELECT id, user_id, number_id, status, email, phone_number, city,
                           name, surname, dfb, date_created, number_avto, marka, marka_avto,
                           avatar, photo_doc, photo_avto, commission_percent, raw_json
                    FROM app_verifications
                    WHERE user_id = %s AND status = %s
                    ORDER BY date_created DESC NULLS LAST
                    LIMIT 1
                    """,
                    (user_id, prefer_status),
                )
                row = cur.fetchone()
                if row:
                    desc = [c[0] for c in cur.description]
                    return _verification_row_to_json(dict(zip(desc, row)))
            cur.execute(
                """
                SELECT id, user_id, number_id, status, email, phone_number, city,
                       name, surname, dfb, date_created, number_avto, marka, marka_avto,
                       avatar, photo_doc, photo_avto, commission_percent, raw_json
                FROM app_verifications
                WHERE user_id = %s
                ORDER BY date_created DESC NULLS LAST
                LIMIT 1
                """,
                (user_id,),
            )
            row = cur.fetchone()
            if not row:
                return None
            desc = [c[0] for c in cur.description]
            return _verification_row_to_json(dict(zip(desc, row)))

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_latest_verification_for_user failed")
        return None


def update_verification(ver_id: str, fields: dict[str, Any]) -> bool:
    """Частичный UPDATE app_verifications + merge raw_json."""
    if not ver_id or not fields:
        return False

    col_map = {
        "status": "status",
        "email": "email",
        "phone_number": "phone_number",
        "city": "city",
        "name": "name",
        "surname": "surname",
        "dfb": "dfb",
        "date_created": "date_created",
        "number_avto": "number_avto",
        "marka": "marka",
        "marka_avto": "marka_avto",
        "avatar": "avatar",
        "photo_doc": "photo_doc",
        "photo_avto": "photo_avto",
        "commission_percent": "commission_percent",
        "number_id": "number_id",
    }

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                "SELECT raw_json FROM app_verifications WHERE id = %s",
                (ver_id,),
            )
            row = cur.fetchone()
            if not row:
                return
            raw = _loads_json(row[0]) or {}
            if not isinstance(raw, dict):
                raw = {}
            raw.update({k: v for k, v in fields.items() if v is not None or k in fields})

            sets = []
            vals: list[Any] = []
            for src, col in col_map.items():
                if src not in fields:
                    continue
                sets.append(f"{col} = %s")
                vals.append(fields[src])
            sets.append("raw_json = %s::jsonb")
            vals.append(json.dumps(raw, ensure_ascii=False, default=str))
            sets.append("updated_at = NOW()")
            vals.append(ver_id)
            cur.execute(
                f"UPDATE app_verifications SET {', '.join(sets)} WHERE id = %s",
                vals,
            )

    return soft_execute("update_verification", _run)


def create_saved_card(card_id: str, user_id: str, raw: dict[str, Any]) -> bool:
    if not card_id or not user_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_saved_cards (
                    id, user_id, pan, rebill_id, card_id, kind, raw_json
                ) VALUES (%s, %s, %s, %s, %s, %s, %s::jsonb)
                ON CONFLICT (id) DO NOTHING
                """,
                (
                    card_id,
                    user_id,
                    raw.get("pan") or "",
                    raw.get("rebill_id") or raw.get("RebillId"),
                    raw.get("card_id"),
                    raw.get("kind") or "payout",
                    json.dumps(raw, ensure_ascii=False),
                ),
            )

    return soft_execute("create_saved_card", _run)


def get_saved_card(card_id: str) -> Optional[dict]:
    if not card_id or not enabled():
        return None

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, user_id, pan, rebill_id, card_id, kind, raw_json, created_at
                FROM app_saved_cards WHERE id = %s
                """,
                (card_id,),
            )
            row = cur.fetchone()
            if not row:
                return None
            desc = [c[0] for c in cur.description]
            d = dict(zip(desc, row))
            raw = _loads_json(d.get("raw_json")) or {}
            if not isinstance(raw, dict):
                raw = {}
            data = dict(raw)
            data.update(
                {
                    "id": d.get("id"),
                    "user_id": d.get("user_id"),
                    "pan": d.get("pan") or "",
                    "rebill_id": d.get("rebill_id"),
                    "RebillId": d.get("rebill_id"),
                    "card_id": d.get("card_id"),
                    "kind": d.get("kind") or "payout",
                    "created_at": d.get("created_at").isoformat()
                    if d.get("created_at") is not None
                    else None,
                }
            )
            return data

    try:
        with connection() as conn:
            if conn is None:
                return None
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] get_saved_card failed")
        return None


def list_saved_cards(*, user_id: str, limit: int = 50) -> list[dict]:
    if not user_id or not enabled():
        return []

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, user_id, pan, rebill_id, card_id, kind, raw_json, created_at
                FROM app_saved_cards
                WHERE user_id = %s
                ORDER BY created_at DESC NULLS LAST
                LIMIT %s
                """,
                (user_id, limit),
            )
            desc = [c[0] for c in cur.description]
            out = []
            for row in cur.fetchall():
                d = dict(zip(desc, row))
                raw = _loads_json(d.get("raw_json")) or {}
                if not isinstance(raw, dict):
                    raw = {}
                data = dict(raw)
                data.update(
                    {
                        "id": d.get("id"),
                        "user_id": d.get("user_id"),
                        "pan": d.get("pan") or "",
                        "rebill_id": d.get("rebill_id"),
                        "RebillId": d.get("rebill_id"),
                        "card_id": d.get("card_id"),
                        "kind": d.get("kind") or "payout",
                        "created_at": d.get("created_at").isoformat()
                        if d.get("created_at") is not None
                        else None,
                    }
                )
                out.append(data)
            return out

    try:
        with connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_pg] list_saved_cards failed")
        return []


def delete_saved_card(card_id: str) -> bool:
    if not card_id:
        return False

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute("DELETE FROM app_saved_cards WHERE id = %s", (card_id,))

    return soft_execute("delete_saved_card", _run)
