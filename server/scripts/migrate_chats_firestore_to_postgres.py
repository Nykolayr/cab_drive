#!/usr/bin/env python3
"""Миграция Firestore chats/messages → Postgres."""
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


def _dt(val: Any):
    if val is None:
        return None
    if isinstance(val, datetime):
        if val.tzinfo is None:
            return val.replace(tzinfo=timezone.utc)
        return val
    return None


def main():
    apply = "--apply" in sys.argv
    db = _init_firebase()
    url = os.environ.get("DATABASE_URL") or open(
        "/root/cab_drive_database_url.txt"
    ).read().strip()
    import psycopg2

    conn = psycopg2.connect(url)
    conn.autocommit = False
    cur = conn.cursor()

    chats_n = msgs_n = 0
    print("scanning chats...")
    for snap in db.collection("chats").stream():
        d = snap.to_dict() or {}
        chat_id = snap.id
        support = bool(d.get("support"))
        last = d.get("last_message") or ""
        created = _dt(d.get("date_created"))
        users = d.get("users") or []
        member_ids = []
        for u in users:
            uid = _ref_id(u)
            if uid:
                member_ids.append(uid)
        chats_n += 1
        if not apply:
            continue
        for uid in member_ids:
            cur.execute(
                "INSERT INTO app_users (id, updated_at) VALUES (%s, NOW()) ON CONFLICT DO NOTHING",
                (uid,),
            )
        cur.execute(
            """
            INSERT INTO app_chats (id, support, last_message, date_created, updated_at, raw_json)
            VALUES (%s, %s, %s, COALESCE(%s, NOW()), NOW(), %s::jsonb)
            ON CONFLICT (id) DO UPDATE SET
                support = EXCLUDED.support,
                last_message = COALESCE(EXCLUDED.last_message, app_chats.last_message),
                updated_at = NOW()
            """,
            (
                chat_id,
                support,
                str(last)[:500],
                created,
                json.dumps({"id": chat_id, "support": support, "users": member_ids}),
            ),
        )
        for uid in member_ids:
            cur.execute(
                """
                INSERT INTO app_chat_members (chat_id, user_id)
                VALUES (%s, %s) ON CONFLICT DO NOTHING
                """,
                (chat_id, uid),
            )
        if support and member_ids:
            # non-support member gets chat_with_support_id
            support_uid = "MEkzqxquE2OqdVEZi4NrxZ9K8F03"
            for uid in member_ids:
                if uid != support_uid:
                    cur.execute(
                        """
                        UPDATE app_users SET chat_with_support_id = %s, updated_at = NOW()
                        WHERE id = %s AND (chat_with_support_id IS NULL OR chat_with_support_id = '')
                        """,
                        (chat_id, uid),
                    )

    print("scanning messages...")
    for snap in db.collection("messages").stream():
        d = snap.to_dict() or {}
        msg_id = snap.id
        chat_id = _ref_id(d.get("chatRef") or d.get("chat_id") or d.get("chatId"))
        sender_id = _ref_id(d.get("sender") or d.get("sender_id"))
        if not chat_id or not sender_id:
            continue
        text = d.get("text") or ""
        imgs = d.get("list_images") or d.get("listImages") or []
        if not isinstance(imgs, list):
            imgs = []
        created = _dt(d.get("date_created") or d.get("dateCreated"))
        read = bool(d.get("read"))
        msgs_n += 1
        if not apply:
            continue
        cur.execute(
            "INSERT INTO app_users (id, updated_at) VALUES (%s, NOW()) ON CONFLICT DO NOTHING",
            (sender_id,),
        )
        # ensure chat shell exists
        cur.execute(
            """
            INSERT INTO app_chats (id, support, last_message, date_created, updated_at)
            VALUES (%s, false, '', COALESCE(%s, NOW()), NOW())
            ON CONFLICT DO NOTHING
            """,
            (chat_id, created),
        )
        cur.execute(
            """
            INSERT INTO app_chat_members (chat_id, user_id)
            VALUES (%s, %s) ON CONFLICT DO NOTHING
            """,
            (chat_id, sender_id),
        )
        cur.execute(
            """
            INSERT INTO app_messages (
                id, chat_id, sender_id, text, list_images, read, date_created, raw_json
            ) VALUES (%s, %s, %s, %s, %s::jsonb, %s, COALESCE(%s, NOW()), %s::jsonb)
            ON CONFLICT (id) DO NOTHING
            """,
            (
                msg_id,
                chat_id,
                sender_id,
                str(text),
                json.dumps(imgs, ensure_ascii=False),
                read,
                created,
                json.dumps({"id": msg_id, "chat_id": chat_id}, ensure_ascii=False),
            ),
        )

    if apply:
        conn.commit()
        print(f"APPLIED chats≈{chats_n} messages≈{msgs_n}")
    else:
        conn.rollback()
        print(f"DRY-RUN chats≈{chats_n} messages≈{msgs_n} (add --apply to write)")
    conn.close()


if __name__ == "__main__":
    main()
