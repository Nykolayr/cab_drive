#!/usr/bin/env python3
"""Доп. remigrate: reviews, request_verefication, users/*/saved_cards → PG."""
from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


def _init_firebase():
    import firebase_admin
    from firebase_admin import credentials, firestore

    cred = ROOT / "s.json"
    if not firebase_admin._apps:
        firebase_admin.initialize_app(credentials.Certificate(str(cred)))
    return firestore.client()


def _ref_id(val: Any) -> str | None:
    if val is None:
        return None
    if hasattr(val, "id"):
        return str(val.id)
    if isinstance(val, str):
        return val.rsplit("/", 1)[-1] if "/" in val else val
    if isinstance(val, dict) and "_ref" in val:
        return str(val["_ref"]).rsplit("/", 1)[-1]
    return None


def _jsonable(obj: Any):
    if isinstance(obj, datetime):
        return obj.astimezone(timezone.utc).isoformat()
    try:
        from google.cloud.firestore_v1 import DocumentReference, GeoPoint

        if isinstance(obj, DocumentReference):
            return {"_ref": obj.path}
        if isinstance(obj, GeoPoint):
            return {"_geo": {"lat": obj.latitude, "lng": obj.longitude}}
    except Exception:
        pass
    return str(obj)


def _dump(d: dict) -> str:
    return json.dumps(d, ensure_ascii=False, default=_jsonable)


def main() -> int:
    apply = "--apply" in sys.argv
    db = _init_firebase()
    url = os.environ.get("DATABASE_URL")
    if not url and Path("/root/cab_drive_database_url.txt").is_file():
        url = Path("/root/cab_drive_database_url.txt").read_text().strip()
    if not url:
        raise SystemExit("DATABASE_URL required")
    import psycopg2

    conn = psycopg2.connect(url)
    cur = conn.cursor()

    # --- reviews ---
    rev_n = rev_ok = 0
    for snap in db.collection("reviews").stream():
        rev_n += 1
        d = snap.to_dict() or {}
        reviewed = _ref_id(d.get("user_who_was_reviewed") or d.get("reviewed_user"))
        author = _ref_id(
            d.get("user_who_wrote_the_review")
            or d.get("user_who_wrote")
            or d.get("author")
        )
        if not reviewed or not author:
            print("skip review", snap.id, "reviewed", reviewed, "author", author)
            continue
        if not apply:
            continue
        cur.execute(
            "INSERT INTO app_users (id, created_time, updated_at) VALUES (%s, NOW(), NOW()) ON CONFLICT DO NOTHING",
            (reviewed,),
        )
        cur.execute(
            "INSERT INTO app_users (id, created_time, updated_at) VALUES (%s, NOW(), NOW()) ON CONFLICT DO NOTHING",
            (author,),
        )
        order_id = _ref_id(d.get("order") or d.get("order_id"))
        date_created = d.get("date")
        if hasattr(date_created, "isoformat"):
            date_iso = date_created.isoformat()
        else:
            date_iso = None
        cur.execute(
            """
            INSERT INTO app_reviews (
                id, reviewed_user_id, author_user_id, text, rating,
                name_author, order_id, date_created, raw_json
            ) VALUES (%s,%s,%s,%s,%s,%s,%s,COALESCE(%s::timestamptz, NOW()),%s::jsonb)
            ON CONFLICT (id) DO UPDATE SET
                text = EXCLUDED.text,
                rating = EXCLUDED.rating,
                name_author = EXCLUDED.name_author,
                order_id = COALESCE(EXCLUDED.order_id, app_reviews.order_id),
                raw_json = EXCLUDED.raw_json
            """,
            (
                snap.id,
                reviewed,
                author,
                d.get("text") or "",
                int(d.get("rating") or 0),
                d.get("name_user_who_wrote") or d.get("name_author"),
                order_id,
                date_iso,
                _dump(d),
            ),
        )
        rev_ok += 1
        if rev_ok % 100 == 0:
            conn.commit()
            print("reviews", rev_ok)
    conn.commit()
    print(f"reviews scanned={rev_n} upserted={rev_ok}")

    # --- verifications ---
    ver_n = ver_ok = 0
    for snap in db.collection("request_verefication").stream():
        ver_n += 1
        d = snap.to_dict() or {}
        uid = _ref_id(d.get("user"))
        if not uid:
            continue
        number_id = d.get("number_id") or d.get("numberId")
        try:
            number_id = int(number_id) if number_id is not None else None
        except Exception:
            number_id = None
        if not apply:
            continue
        cur.execute(
            "INSERT INTO app_users (id, created_time, updated_at) VALUES (%s, NOW(), NOW()) ON CONFLICT DO NOTHING",
            (uid,),
        )
        # освободить unique number_id, если занят другим id
        if number_id is not None:
            cur.execute(
                "UPDATE app_verifications SET number_id = NULL WHERE number_id = %s AND id <> %s",
                (number_id, snap.id),
            )
        photo_doc = d.get("photo_doc") or []
        photo_avto = d.get("photo_avto") or []
        if not isinstance(photo_doc, list):
            photo_doc = []
        if not isinstance(photo_avto, list):
            photo_avto = []
        marka = d.get("marka")
        if hasattr(marka, "name"):
            marka = str(marka)
        elif marka is not None and not isinstance(marka, str):
            marka = str(marka)
        try:
            cur.execute(
                """
                INSERT INTO app_verifications (
                    id, user_id, number_id, status, email, phone_number, city,
                    name, surname, date_created, number_avto, marka, marka_avto,
                    avatar, photo_doc, photo_avto, commission_percent, raw_json, updated_at
                ) VALUES (
                    %s,%s,%s,%s,%s,%s,%s,
                    %s,%s,NOW(),%s,%s,%s,
                    %s,%s,%s,%s,%s::jsonb,NOW()
                )
                ON CONFLICT (id) DO UPDATE SET
                    user_id = EXCLUDED.user_id,
                    number_id = COALESCE(EXCLUDED.number_id, app_verifications.number_id),
                    status = EXCLUDED.status,
                    email = EXCLUDED.email,
                    phone_number = EXCLUDED.phone_number,
                    city = EXCLUDED.city,
                    name = EXCLUDED.name,
                    surname = EXCLUDED.surname,
                    number_avto = EXCLUDED.number_avto,
                    marka = EXCLUDED.marka,
                    photo_doc = EXCLUDED.photo_doc,
                    photo_avto = EXCLUDED.photo_avto,
                    commission_percent = EXCLUDED.commission_percent,
                    raw_json = EXCLUDED.raw_json,
                    updated_at = NOW()
                """,
                (
                    snap.id,
                    uid,
                    number_id,
                    str(d.get("status") or "onVerif"),
                    d.get("email"),
                    d.get("phone_number"),
                    d.get("city"),
                    d.get("name"),
                    d.get("surname"),
                    d.get("number_avto"),
                    marka,
                    d.get("marka_avto"),
                    d.get("avatar"),
                    photo_doc,
                    photo_avto,
                    d.get("commission_percent"),
                    _dump(d),
                ),
            )
            ver_ok += 1
        except Exception as e:
            conn.rollback()
            print("verif fail", snap.id, e)
            continue
        if ver_ok % 50 == 0:
            conn.commit()
            print("verifs", ver_ok)
    conn.commit()
    print(f"verifications scanned={ver_n} upserted={ver_ok}")

    # --- saved cards under users/*/saved_cards ---
    cards_n = cards_ok = 0
    for usnap in db.collection("users").stream():
        for cs in usnap.reference.collection("saved_cards").stream():
            cards_n += 1
            d = cs.to_dict() or {}
            if not apply:
                continue
            cur.execute(
                "INSERT INTO app_users (id, created_time, updated_at) VALUES (%s, NOW(), NOW()) ON CONFLICT DO NOTHING",
                (usnap.id,),
            )
            cur.execute(
                """
                INSERT INTO app_saved_cards (id, user_id, pan, rebill_id, card_id, kind, raw_json)
                VALUES (%s,%s,%s,%s,%s,%s,%s::jsonb)
                ON CONFLICT (id) DO UPDATE SET
                    pan = EXCLUDED.pan,
                    rebill_id = COALESCE(EXCLUDED.rebill_id, app_saved_cards.rebill_id),
                    card_id = COALESCE(EXCLUDED.card_id, app_saved_cards.card_id),
                    kind = EXCLUDED.kind,
                    raw_json = EXCLUDED.raw_json
                """,
                (
                    cs.id,
                    usnap.id,
                    d.get("pan") or "",
                    d.get("rebill_id") or d.get("RebillId"),
                    d.get("card_id"),
                    d.get("kind") or "payout",
                    _dump(d),
                ),
            )
            cards_ok += 1
            if cards_ok % 50 == 0:
                conn.commit()
                print("cards", cards_ok)
    conn.commit()
    print(f"saved_cards scanned={cards_n} upserted={cards_ok}")

    if not apply:
        print("DRY-RUN: add --apply to write")
    else:
        print("EXTRA_MIGRATE_OK")
    cur.close()
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
