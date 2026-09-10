#!/usr/bin/env python3
"""
Миграция данных Firestore → Postgres (P0: users, order, pay_order).

Примеры:
  # 1) Только выгрузка в JSONL (безопасно, без Postgres)
  python scripts/migrate_firestore_to_postgres.py export --out D:/Temp/cab_fs_export

  # 2) Создать схему
  set DATABASE_URL=postgresql://user:pass@127.0.0.1:5432/cab_drive
  python scripts/migrate_firestore_to_postgres.py init-schema

  # 3) Импорт из JSONL
  python scripts/migrate_firestore_to_postgres.py import --in D:/Temp/cab_fs_export --apply

  # 4) Сверка балансов / counts
  python scripts/migrate_firestore_to_postgres.py verify --in D:/Temp/cab_fs_export

По умолчанию import без --apply — dry-run (читает и считает, не пишет).
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any

# server/ на PYTHONPATH
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

DEFAULT_CREDS = ROOT / "s.json"
SCHEMA_SQL = ROOT / "migrations" / "postgres" / "001_app_core.sql"


def _init_firebase(creds: Path):
    import firebase_admin
    from firebase_admin import credentials, firestore

    if not firebase_admin._apps:
        if not creds.exists():
            raise SystemExit(f"Нет credentials: {creds}")
        firebase_admin.initialize_app(credentials.Certificate(str(creds)))
    return firestore.client()


def _json_default(obj: Any):
    if isinstance(obj, datetime):
        return obj.astimezone(timezone.utc).isoformat()
    if isinstance(obj, Decimal):
        return float(obj)
    # Firestore types
    try:
        from google.cloud.firestore_v1 import DocumentReference, GeoPoint
        from google.api_core.datetime_helpers import DatetimeWithNanoseconds

        if isinstance(obj, DocumentReference):
            return {"_ref": obj.path}
        if isinstance(obj, GeoPoint):
            return {"_geo": {"lat": obj.latitude, "lng": obj.longitude}}
        if isinstance(obj, DatetimeWithNanoseconds):
            return obj.isoformat()
    except Exception:
        pass
    return str(obj)


def _serialize_doc(doc_id: str, data: dict) -> dict:
    return {"id": doc_id, "data": json.loads(json.dumps(data, default=_json_default))}


def _ref_id(val: Any) -> str | None:
    if val is None:
        return None
    if isinstance(val, dict) and "_ref" in val:
        return str(val["_ref"]).rsplit("/", 1)[-1]
    if isinstance(val, str) and "/" in val:
        return val.rsplit("/", 1)[-1]
    if isinstance(val, str):
        return val
    return None


def _geo(val: Any) -> tuple[float | None, float | None]:
    if isinstance(val, dict) and "_geo" in val:
        g = val["_geo"]
        return g.get("lat"), g.get("lng")
    if isinstance(val, dict) and "latitude" in val:
        return val.get("latitude"), val.get("longitude")
    return None, None


def _parse_ts(val: Any):
    if not val:
        return None
    if isinstance(val, datetime):
        return val
    if isinstance(val, str):
        try:
            return datetime.fromisoformat(val.replace("Z", "+00:00"))
        except Exception:
            return None
    return None


def cmd_export(args: argparse.Namespace) -> None:
    db = _init_firebase(Path(args.creds))
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    collections = args.collections or ["users", "order", "pay_order"]
    for coll in collections:
        path = out / f"{coll}.jsonl"
        n = 0
        with path.open("w", encoding="utf-8") as f:
            for doc in db.collection(coll).stream():
                row = _serialize_doc(doc.id, doc.to_dict() or {})
                # subcollections for users
                if coll == "users":
                    tokens = []
                    for t in doc.reference.collection("fcm_tokens").stream():
                        tokens.append(_serialize_doc(t.id, t.to_dict() or {}))
                    row["fcm_tokens"] = tokens
                if coll == "order":
                    responses = []
                    for r in doc.reference.collection("responses").stream():
                        responses.append(_serialize_doc(r.id, r.to_dict() or {}))
                    row["responses"] = responses
                f.write(json.dumps(row, ensure_ascii=False) + "\n")
                n += 1
                if n % 500 == 0:
                    print(f"  {coll}: {n}...")
        print(f"OK export {coll}: {n} -> {path}")

    meta = {
        "exported_at": datetime.now(timezone.utc).isoformat(),
        "collections": collections,
    }
    (out / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print("Done export", out)


def cmd_init_schema(args: argparse.Namespace) -> None:
    import psycopg2

    url = os.environ.get("DATABASE_URL") or args.database_url
    if not url:
        raise SystemExit("Задайте DATABASE_URL или --database-url")
    sql = SCHEMA_SQL.read_text(encoding="utf-8")
    conn = psycopg2.connect(url)
    conn.autocommit = True
    with conn.cursor() as cur:
        cur.execute(sql)
    conn.close()
    print("OK schema applied", SCHEMA_SQL)


def _upsert_user(cur, row: dict) -> None:
    d = row["data"]
    uid = row["id"]
    lat, lng = _geo(d.get("driver_location") or d.get("cityLatlng"))
    city_lat, city_lng = _geo(d.get("cityLatlng"))
    cur.execute(
        """
        INSERT INTO app_users (
            id, email, fb_id, display_name, photo_url, uid, created_time,
            phone_number, login_complete, is_driver, admin, surname, dfb, city, region,
            city_lat, city_lng, verif_compl, is_blocked, block_comment, verif_ne_proidena,
            verif_id, on_verif_now, email_user, additional_phone_number, chat_with_support_id,
            balance, bonus_balance, average_rating, number_of_reviews, commission_percent,
            current_commision, on_shift, fine, contractor_id, last_online,
            shift_start_date_time, shift_completion_date_time, driver_lat, driver_lng,
            car_json, addresses_json, current_order_json, active_orders_queue, raw_json, updated_at
        ) VALUES (
            %(id)s, %(email)s, %(fb_id)s, %(display_name)s, %(photo_url)s, %(uid)s, %(created_time)s,
            %(phone_number)s, %(login_complete)s, %(is_driver)s, %(admin)s, %(surname)s, %(dfb)s, %(city)s, %(region)s,
            %(city_lat)s, %(city_lng)s, %(verif_compl)s, %(is_blocked)s, %(block_comment)s, %(verif_ne_proidena)s,
            %(verif_id)s, %(on_verif_now)s, %(email_user)s, %(additional_phone_number)s, %(chat_with_support_id)s,
            %(balance)s, %(bonus_balance)s, %(average_rating)s, %(number_of_reviews)s, %(commission_percent)s,
            %(current_commision)s, %(on_shift)s, %(fine)s, %(contractor_id)s, %(last_online)s,
            %(shift_start_date_time)s, %(shift_completion_date_time)s, %(driver_lat)s, %(driver_lng)s,
            %(car_json)s, %(addresses_json)s, %(current_order_json)s, %(active_orders_queue)s, %(raw_json)s, NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            display_name = EXCLUDED.display_name,
            phone_number = EXCLUDED.phone_number,
            balance = EXCLUDED.balance,
            bonus_balance = EXCLUDED.bonus_balance,
            is_driver = EXCLUDED.is_driver,
            login_complete = EXCLUDED.login_complete,
            admin = EXCLUDED.admin,
            surname = EXCLUDED.surname,
            city = EXCLUDED.city,
            region = EXCLUDED.region,
            verif_compl = EXCLUDED.verif_compl,
            on_verif_now = EXCLUDED.on_verif_now,
            verif_id = EXCLUDED.verif_id,
            verif_ne_proidena = EXCLUDED.verif_ne_proidena,
            is_blocked = EXCLUDED.is_blocked,
            block_comment = EXCLUDED.block_comment,
            photo_url = EXCLUDED.photo_url,
            email_user = EXCLUDED.email_user,
            additional_phone_number = EXCLUDED.additional_phone_number,
            chat_with_support_id = COALESCE(EXCLUDED.chat_with_support_id, app_users.chat_with_support_id),
            car_json = COALESCE(EXCLUDED.car_json, app_users.car_json),
            addresses_json = COALESCE(EXCLUDED.addresses_json, app_users.addresses_json),
            current_order_json = COALESCE(EXCLUDED.current_order_json, app_users.current_order_json),
            active_orders_queue = COALESCE(EXCLUDED.active_orders_queue, app_users.active_orders_queue),
            commission_percent = COALESCE(EXCLUDED.commission_percent, app_users.commission_percent),
            current_commision = COALESCE(EXCLUDED.current_commision, app_users.current_commision),
            average_rating = COALESCE(EXCLUDED.average_rating, app_users.average_rating),
            number_of_reviews = COALESCE(EXCLUDED.number_of_reviews, app_users.number_of_reviews),
            on_shift = EXCLUDED.on_shift,
            fine = EXCLUDED.fine,
            dfb = COALESCE(EXCLUDED.dfb, app_users.dfb),
            created_time = COALESCE(app_users.created_time, EXCLUDED.created_time),
            raw_json = EXCLUDED.raw_json,
            updated_at = NOW()
        """,
        {
            "id": uid,
            "email": d.get("email"),
            "fb_id": d.get("fb_id"),
            "display_name": d.get("display_name"),
            "photo_url": d.get("photo_url"),
            "uid": d.get("uid") or uid,
            "created_time": _parse_ts(d.get("created_time")),
            "phone_number": d.get("phone_number"),
            "login_complete": bool(d.get("login_complete")),
            "is_driver": bool(d.get("is_driver")),
            "admin": bool(d.get("admin")),
            "surname": d.get("surname"),
            "dfb": _parse_ts(d.get("dfb")),
            "city": d.get("city"),
            "region": d.get("region"),
            "city_lat": city_lat,
            "city_lng": city_lng,
            "verif_compl": bool(d.get("verif_compl")),
            "is_blocked": bool(d.get("is_blocked")),
            "block_comment": d.get("block_comment"),
            "verif_ne_proidena": d.get("verif_ne_proidena"),
            "verif_id": d.get("verif_id"),
            "on_verif_now": bool(d.get("on_verif_now")),
            "email_user": d.get("email_user"),
            "additional_phone_number": d.get("additional_phone_number"),
            "chat_with_support_id": _ref_id(d.get("chat_with_support")),
            "balance": d.get("balance") or 0,
            "bonus_balance": d.get("bonus_balance") or 0,
            "average_rating": d.get("average_rating") or 0,
            "number_of_reviews": d.get("number_of_reviews") or 0,
            "commission_percent": d.get("commission_percent"),
            "current_commision": d.get("current_commision"),
            "on_shift": bool(d.get("on_shift")),
            "fine": bool(d.get("fine")),
            "contractor_id": d.get("ContractorID"),
            "last_online": _parse_ts(d.get("last_online")),
            "shift_start_date_time": _parse_ts(d.get("shift_start_date_time")),
            "shift_completion_date_time": _parse_ts(d.get("shift_completion_date_time")),
            "driver_lat": lat,
            "driver_lng": lng,
            "car_json": json.dumps(d.get("car")) if d.get("car") is not None else None,
            "addresses_json": json.dumps(d.get("addresses")) if d.get("addresses") is not None else None,
            "current_order_json": json.dumps(d.get("current_order")) if d.get("current_order") is not None else None,
            "active_orders_queue": [
                _ref_id(x) for x in (d.get("active_orders_queue") or []) if _ref_id(x)
            ],
            "raw_json": json.dumps(d, ensure_ascii=False),
        },
    )
    for t in row.get("fcm_tokens") or []:
        tok = (t.get("data") or {}).get("token") or t.get("id")
        if not tok:
            continue
        cur.execute(
            """
            INSERT INTO app_user_fcm_tokens (user_id, token, raw_json)
            VALUES (%s, %s, %s::jsonb)
            ON CONFLICT (user_id, token) DO NOTHING
            """,
            (uid, str(tok), json.dumps(t.get("data") or {}, ensure_ascii=False)),
        )


def _as_int(val: Any) -> int | None:
    if val is None or val == "":
        return None
    if isinstance(val, bool):
        return int(val)
    if isinstance(val, int):
        return val
    if isinstance(val, float):
        return int(val)
    if isinstance(val, str):
        s = val.strip().replace(",", ".").replace(" ", "")
        # "2.4км" / "2400" → try leading number
        num = ""
        for ch in s:
            if ch.isdigit() or (ch == "." and "." not in num) or (ch == "-" and not num):
                num += ch
            elif num:
                break
        if not num or num in {".", "-", "-."}:
            return None
        try:
            return int(float(num))
        except Exception:
            return None
    try:
        return int(val)
    except Exception:
        return None


def _as_float(val: Any) -> float | None:
    if val is None or val == "":
        return None
    if isinstance(val, (int, float)):
        return float(val)
    if isinstance(val, str):
        s = val.strip().replace(",", ".").replace(" ", "")
        num = ""
        for ch in s:
            if ch.isdigit() or (ch == "." and "." not in num) or (ch == "-" and not num):
                num += ch
            elif num:
                break
        if not num or num in {".", "-", "-."}:
            return None
        try:
            return float(num)
        except Exception:
            return None
    try:
        return float(val)
    except Exception:
        return None


def _upsert_order(cur, row: dict) -> None:
    d = row["data"]
    oid = row["id"]
    dlat, dlng = _geo(d.get("driver_location"))
    cur.execute(
        """
        INSERT INTO app_orders (
            id, selected_driver_id, user_customer_id, supply, date_time, date_time_created, date_upd,
            point_a_json, point_b_json, point_c_json, images, image_compl, description, budget,
            status, status_do_hidden, driver_reviewed, customer_reviewed, count_resp,
            user_who_responced, distance, time_text, time_left, km_left, driver_lat, driver_lng,
            car, movers, current_price, payment_id, pay_method, commission_percent, is_paid,
            completion_date_by_the_driver, raw_json, updated_at
        ) VALUES (
            %(id)s, %(selected_driver_id)s, %(user_customer_id)s, %(supply)s, %(date_time)s, %(date_time_created)s, %(date_upd)s,
            %(point_a_json)s, %(point_b_json)s, %(point_c_json)s, %(images)s, %(image_compl)s, %(description)s, %(budget)s,
            %(status)s, %(status_do_hidden)s, %(driver_reviewed)s, %(customer_reviewed)s, %(count_resp)s,
            %(user_who_responced)s, %(distance)s, %(time_text)s, %(time_left)s, %(km_left)s, %(driver_lat)s, %(driver_lng)s,
            %(car)s, %(movers)s, %(current_price)s, %(payment_id)s, %(pay_method)s, %(commission_percent)s, %(is_paid)s,
            %(completion_date_by_the_driver)s, %(raw_json)s, NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            status = EXCLUDED.status,
            selected_driver_id = EXCLUDED.selected_driver_id,
            budget = EXCLUDED.budget,
            raw_json = EXCLUDED.raw_json,
            updated_at = NOW()
        """,
        {
            "id": oid,
            "selected_driver_id": _ref_id(d.get("selected_driver")),
            "user_customer_id": _ref_id(d.get("user_customer")),
            "supply": _as_int(d.get("supply")),
            "date_time": _parse_ts(d.get("dateTime")),
            "date_time_created": _parse_ts(d.get("dateTime_created")),
            "date_upd": _parse_ts(d.get("date_upd")),
            "point_a_json": json.dumps(d.get("pointA")) if d.get("pointA") is not None else None,
            "point_b_json": json.dumps(d.get("pointB")) if d.get("pointB") is not None else None,
            "point_c_json": json.dumps(d.get("pointC")) if d.get("pointC") is not None else None,
            "images": d.get("images") or [],
            "image_compl": d.get("image_compl") or [],
            "description": d.get("description"),
            "budget": _as_int(d.get("budget")),
            "status": d.get("status"),
            "status_do_hidden": d.get("status_do_hidden"),
            "driver_reviewed": bool(d.get("driver_reviewed")),
            "customer_reviewed": bool(d.get("customer_reviewed")),
            "count_resp": _as_int(d.get("count_resp")) or 0,
            "user_who_responced": [
                _ref_id(x) for x in (d.get("user_who_responced") or []) if _ref_id(x)
            ],
            "distance": _as_int(d.get("distance")),
            "time_text": d.get("time") if d.get("time") is None or isinstance(d.get("time"), str) else str(d.get("time")),
            "time_left": d.get("time_left") if not isinstance(d.get("time_left"), (dict, list)) else json.dumps(d.get("time_left")),
            "km_left": d.get("km_left") if not isinstance(d.get("km_left"), (dict, list)) else json.dumps(d.get("km_left")),
            "driver_lat": dlat,
            "driver_lng": dlng,
            "car": d.get("car") if isinstance(d.get("car"), str) else json.dumps(d.get("car")) if d.get("car") else None,
            "movers": _as_int(d.get("movers")),
            "current_price": _as_int(d.get("currentPrice")),
            "payment_id": str(d.get("paymentId") or "") or None,
            "pay_method": d.get("payMethod") if isinstance(d.get("payMethod"), str) else (str(d.get("payMethod")) if d.get("payMethod") is not None else None),
            "commission_percent": _as_int(d.get("commission_percent") or d.get("commissionPercent")),
            "is_paid": bool(d.get("is_paid")),
            "completion_date_by_the_driver": _parse_ts(d.get("completion_date_by_the_driver")),
            "raw_json": json.dumps(d, ensure_ascii=False),
        },
    )
    for r in row.get("responses") or []:
        cur.execute(
            """
            INSERT INTO app_order_responses (order_id, firestore_id, raw_json)
            VALUES (%s, %s, %s::jsonb)
            ON CONFLICT (order_id, firestore_id) DO UPDATE SET raw_json = EXCLUDED.raw_json
            """,
            (oid, r.get("id"), json.dumps(r.get("data") or {}, ensure_ascii=False)),
        )


def _upsert_pay_order(cur, row: dict) -> None:
    d = row["data"]
    cur.execute(
        """
        INSERT INTO app_pay_orders (
            id, order_id, amount_in_cop, user_id, driver_id, is_paid, payment_id,
            current_order_id, payment_type, list_users_upd_balance, summ_upd_balance,
            tinkoff_status, tinkoff_error_code, tinkoff_message, date_time_created, raw_json, updated_at
        ) VALUES (
            %(id)s, %(order_id)s, %(amount_in_cop)s, %(user_id)s, %(driver_id)s, %(is_paid)s, %(payment_id)s,
            %(current_order_id)s, %(payment_type)s, %(list_users_upd_balance)s, %(summ_upd_balance)s,
            %(tinkoff_status)s, %(tinkoff_error_code)s, %(tinkoff_message)s, %(date_time_created)s, %(raw_json)s, NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            is_paid = EXCLUDED.is_paid,
            payment_id = EXCLUDED.payment_id,
            raw_json = EXCLUDED.raw_json,
            updated_at = NOW()
        """,
        {
            "id": row["id"],
            "order_id": d.get("order_id"),
            "amount_in_cop": _as_int(d.get("amount_in_cop")),
            "user_id": _ref_id(d.get("user")),
            "driver_id": _ref_id(d.get("driver")),
            "is_paid": bool(d.get("is_paid")),
            "payment_id": str(d.get("paymentId") or "") or None,
            "current_order_id": _ref_id(d.get("current_order_doc_ref")),
            "payment_type": d.get("paymentType"),
            "list_users_upd_balance": [
                _ref_id(x) for x in (d.get("list_users_upd_ballance") or []) if _ref_id(x)
            ],
            "summ_upd_balance": d.get("summ_upd_ballance"),
            "tinkoff_status": d.get("tinkoff_status"),
            "tinkoff_error_code": d.get("tinkoff_error_code"),
            "tinkoff_message": d.get("tinkoff_message"),
            "date_time_created": _parse_ts(d.get("dateTime_created")),
            "raw_json": json.dumps(d, ensure_ascii=False),
        },
    )


def cmd_import(args: argparse.Namespace) -> None:
    import psycopg2
    from psycopg2.extras import Json  # noqa: F401 — reserved

    src = Path(args.input)
    if not src.exists():
        raise SystemExit(f"Нет каталога экспорта: {src}")
    url = os.environ.get("DATABASE_URL") or args.database_url
    if args.apply and not url:
        raise SystemExit("Для --apply нужен DATABASE_URL")

    files = {
        "users": src / "users.jsonl",
        "order": src / "order.jsonl",
        "pay_order": src / "pay_order.jsonl",
    }
    for name, path in files.items():
        if not path.exists():
            print("SKIP missing", path)
            continue
        n = sum(1 for _ in path.open(encoding="utf-8"))
        print(f"file {name}: {n} docs")

    if not args.apply:
        print("DRY-RUN: добавьте --apply чтобы записать в Postgres")
        return

    conn = psycopg2.connect(url)
    try:
        with conn.cursor() as cur:
            if files["users"].exists():
                n = 0
                with files["users"].open(encoding="utf-8") as f:
                    for line in f:
                        _upsert_user(cur, json.loads(line))
                        n += 1
                        if n % 200 == 0:
                            conn.commit()
                            print(f"  users {n}")
                conn.commit()
                print(f"OK users imported {n}")
            if files["order"].exists():
                n = 0
                with files["order"].open(encoding="utf-8") as f:
                    for line in f:
                        _upsert_order(cur, json.loads(line))
                        n += 1
                        if n % 200 == 0:
                            conn.commit()
                            print(f"  order {n}")
                conn.commit()
                print(f"OK order imported {n}")
            if files["pay_order"].exists():
                n = 0
                with files["pay_order"].open(encoding="utf-8") as f:
                    for line in f:
                        _upsert_pay_order(cur, json.loads(line))
                        n += 1
                        if n % 200 == 0:
                            conn.commit()
                conn.commit()
                print(f"OK pay_order imported {n}")
            cur.execute(
                """
                INSERT INTO app_migration_runs (finished_at, mode, collection, notes)
                VALUES (NOW(), 'import', 'users,order,pay_order', %s)
                """,
                (str(src),),
            )
            conn.commit()
    finally:
        conn.close()


def cmd_verify(args: argparse.Namespace) -> None:
    src = Path(args.input)
    users_path = src / "users.jsonl"
    if not users_path.exists():
        raise SystemExit("Нет users.jsonl — сначала export")

    bal = Decimal("0")
    bonus = Decimal("0")
    n = 0
    with users_path.open(encoding="utf-8") as f:
        for line in f:
            d = json.loads(line)["data"]
            bal += Decimal(str(d.get("balance") or 0))
            bonus += Decimal(str(d.get("bonus_balance") or 0))
            n += 1
    print(f"Firestore export users={n} sum(balance)={bal} sum(bonus)={bonus}")

    url = os.environ.get("DATABASE_URL") or args.database_url
    if not url:
        print("DATABASE_URL не задан — сверка только по экспорту")
        return
    import psycopg2

    conn = psycopg2.connect(url)
    with conn.cursor() as cur:
        cur.execute(
            "SELECT COUNT(*), COALESCE(SUM(balance),0), COALESCE(SUM(bonus_balance),0) FROM app_users"
        )
        cnt, sbal, sbonus = cur.fetchone()
        print(f"Postgres app_users={cnt} sum(balance)={sbal} sum(bonus)={sbonus}")
        if cnt != n or Decimal(str(sbal)) != bal or Decimal(str(sbonus)) != bonus:
            print("MISMATCH — cutover запрещён до устранения")
            sys.exit(2)
        print("OK verify balances match")
    conn.close()


def main():
    p = argparse.ArgumentParser(description="Firestore → Postgres data migration")
    p.add_argument("--creds", default=str(DEFAULT_CREDS))
    p.add_argument("--database-url", default="")
    sub = p.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("export", help="Выгрузка Firestore → JSONL")
    e.add_argument("--out", required=True)
    e.add_argument("--collections", nargs="*", default=None)
    e.set_defaults(func=cmd_export)

    i = sub.add_parser("init-schema", help="Применить 001_app_core.sql")
    i.set_defaults(func=cmd_init_schema)

    m = sub.add_parser("import", help="Импорт JSONL → Postgres")
    m.add_argument("--in", dest="input", required=True)
    m.add_argument("--apply", action="store_true")
    m.set_defaults(func=cmd_import)

    v = sub.add_parser("verify", help="Сверка counts/сумм балансов")
    v.add_argument("--in", dest="input", required=True)
    v.set_defaults(func=cmd_verify)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
