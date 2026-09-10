"""Postgres SoT для чатов (WSS / HTTP)."""
from __future__ import annotations

import json
import logging
import uuid
from datetime import datetime, timezone
from typing import Any, Optional

import app_pg

logger = logging.getLogger(__name__)

SUPPORT_UID = "MEkzqxquE2OqdVEZi4NrxZ9K8F03"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _jsonable(val: Any) -> Any:
    if isinstance(val, datetime):
        return val.isoformat()
    return val


def ensure_peer_chat(user_a: str, user_b: str) -> Optional[dict]:
    """Найти или создать peer-чат между двумя пользователями."""
    if not user_a or not user_b or user_a == user_b:
        return None
    a, b = sorted([user_a, user_b])
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return None
            with conn.cursor() as cur:
                for uid in (a, b):
                    cur.execute(
                        "INSERT INTO app_users (id, updated_at) VALUES (%s, NOW()) ON CONFLICT DO NOTHING",
                        (uid,),
                    )
                cur.execute(
                    """
                    SELECT c.id FROM app_chats c
                    JOIN app_chat_members m1 ON m1.chat_id = c.id AND m1.user_id = %s
                    JOIN app_chat_members m2 ON m2.chat_id = c.id AND m2.user_id = %s
                    WHERE COALESCE(c.support, false) = false
                    LIMIT 1
                    """,
                    (a, b),
                )
                row = cur.fetchone()
                if row:
                    chat_id = row[0]
                else:
                    chat_id = uuid.uuid4().hex
                    now = _now()
                    cur.execute(
                        """
                        INSERT INTO app_chats (id, support, last_message, date_created, updated_at, raw_json)
                        VALUES (%s, false, '', %s, %s, %s::jsonb)
                        """,
                        (
                            chat_id,
                            now,
                            now,
                            json.dumps({"id": chat_id, "support": False, "users": [a, b]}),
                        ),
                    )
                    cur.execute(
                        "INSERT INTO app_chat_members (chat_id, user_id) VALUES (%s, %s), (%s, %s)",
                        (chat_id, a, chat_id, b),
                    )
            conn.commit()
            return get_chat(chat_id)
    except Exception:
        logger.exception("[app_chat_pg] ensure_peer_chat failed")
        return None


def ensure_support_chat(user_id: str) -> Optional[dict]:
    if not user_id:
        return None
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return None
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO app_users (id, updated_at) VALUES (%s, NOW()) ON CONFLICT DO NOTHING",
                    (SUPPORT_UID,),
                )
                cur.execute(
                    "INSERT INTO app_users (id, updated_at) VALUES (%s, NOW()) ON CONFLICT DO NOTHING",
                    (user_id,),
                )
                cur.execute(
                    "SELECT chat_with_support_id FROM app_users WHERE id = %s",
                    (user_id,),
                )
                row = cur.fetchone()
                if row and row[0]:
                    existing = get_chat(str(row[0]))
                    if existing:
                        return existing
                cur.execute(
                    """
                    SELECT c.id FROM app_chats c
                    JOIN app_chat_members m ON m.chat_id = c.id AND m.user_id = %s
                    WHERE c.support = true
                    LIMIT 1
                    """,
                    (user_id,),
                )
                row = cur.fetchone()
                if row:
                    chat_id = row[0]
                else:
                    chat_id = uuid.uuid4().hex
                    now = _now()
                    cur.execute(
                        """
                        INSERT INTO app_chats (id, support, last_message, date_created, updated_at, raw_json)
                        VALUES (%s, true, '', %s, %s, %s::jsonb)
                        """,
                        (
                            chat_id,
                            now,
                            now,
                            json.dumps(
                                {
                                    "id": chat_id,
                                    "support": True,
                                    "users": [user_id, SUPPORT_UID],
                                }
                            ),
                        ),
                    )
                    cur.execute(
                        """
                        INSERT INTO app_chat_members (chat_id, user_id) VALUES (%s, %s), (%s, %s)
                        ON CONFLICT DO NOTHING
                        """,
                        (chat_id, user_id, chat_id, SUPPORT_UID),
                    )
                cur.execute(
                    "UPDATE app_users SET chat_with_support_id = %s, updated_at = NOW() WHERE id = %s",
                    (chat_id, user_id),
                )
            conn.commit()
            return get_chat(chat_id)
    except Exception:
        logger.exception("[app_chat_pg] ensure_support_chat failed")
        return None


def touch_chat_for_user(
    chat_id: str, user_id: str, *, support: bool = False
) -> bool:
    """Импорт FS-чата в PG: создать комнату с тем же id и добавить участника."""
    if not chat_id or not user_id:
        return False
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return False
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO app_users (id, updated_at) VALUES (%s, NOW()) ON CONFLICT DO NOTHING",
                    (user_id,),
                )
                cur.execute(
                    """
                    INSERT INTO app_chats (id, support, last_message, date_created, updated_at)
                    VALUES (%s, %s, '', NOW(), NOW())
                    ON CONFLICT (id) DO NOTHING
                    """,
                    (chat_id, support),
                )
                cur.execute(
                    """
                    INSERT INTO app_chat_members (chat_id, user_id)
                    VALUES (%s, %s)
                    ON CONFLICT DO NOTHING
                    """,
                    (chat_id, user_id),
                )
            conn.commit()
            return True
    except Exception:
        logger.exception("[app_chat_pg] touch_chat_for_user failed")
        return False


def get_chat(chat_id: str) -> Optional[dict]:
    if not chat_id or not app_pg.enabled():
        return None
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return None
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT id, support, last_message, date_created, updated_at, raw_json
                    FROM app_chats WHERE id = %s
                    """,
                    (chat_id,),
                )
                row = cur.fetchone()
                if not row:
                    return None
                cur.execute(
                    "SELECT user_id FROM app_chat_members WHERE chat_id = %s",
                    (chat_id,),
                )
                members = [r[0] for r in cur.fetchall()]
            return {
                "id": row[0],
                "support": bool(row[1]),
                "last_message": row[2] or "",
                "date_created": row[3].isoformat() if row[3] else None,
                "updated_at": row[4].isoformat() if row[4] else None,
                "users": members,
                "_source": "postgres",
            }
    except Exception:
        logger.exception("[app_chat_pg] get_chat failed")
        return None


def user_in_chat(chat_id: str, user_id: str) -> bool:
    if not chat_id or not user_id:
        return False
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return False
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT 1 FROM app_chat_members WHERE chat_id = %s AND user_id = %s",
                    (chat_id, user_id),
                )
                return cur.fetchone() is not None
    except Exception:
        return False


def list_chats_for_user(user_id: str, *, support: Optional[bool] = None, limit: int = 50) -> list[dict]:
    if not user_id or not app_pg.enabled():
        return []
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return []
            with conn.cursor() as cur:
                sql = """
                    SELECT c.id FROM app_chats c
                    JOIN app_chat_members m ON m.chat_id = c.id AND m.user_id = %s
                    WHERE 1=1
                """
                params: list[Any] = [user_id]
                if support is not None:
                    sql += " AND c.support = %s"
                    params.append(support)
                sql += " ORDER BY c.updated_at DESC NULLS LAST LIMIT %s"
                params.append(min(limit, 200))
                cur.execute(sql, params)
                ids = [r[0] for r in cur.fetchall()]
            return [c for cid in ids if (c := get_chat(cid))]
    except Exception:
        logger.exception("[app_chat_pg] list_chats failed")
        return []


def list_messages(chat_id: str, *, limit: int = 50, before: Optional[str] = None) -> list[dict]:
    if not chat_id or not app_pg.enabled():
        return []
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return []
            with conn.cursor() as cur:
                if before:
                    cur.execute(
                        """
                        SELECT id, chat_id, sender_id, text, list_images, read, date_created
                        FROM app_messages
                        WHERE chat_id = %s AND date_created < (
                            SELECT date_created FROM app_messages WHERE id = %s
                        )
                        ORDER BY date_created DESC
                        LIMIT %s
                        """,
                        (chat_id, before, min(limit, 100)),
                    )
                else:
                    cur.execute(
                        """
                        SELECT id, chat_id, sender_id, text, list_images, read, date_created
                        FROM app_messages
                        WHERE chat_id = %s
                        ORDER BY date_created DESC
                        LIMIT %s
                        """,
                        (chat_id, min(limit, 100)),
                    )
                rows = cur.fetchall()
            out = []
            for r in rows:
                imgs = r[4]
                if isinstance(imgs, str):
                    try:
                        imgs = json.loads(imgs)
                    except Exception:
                        imgs = []
                out.append(
                    {
                        "id": r[0],
                        "chat_id": r[1],
                        "sender_id": r[2],
                        "text": r[3] or "",
                        "list_images": imgs or [],
                        "read": bool(r[5]),
                        "date_created": r[6].isoformat() if r[6] else None,
                    }
                )
            return out
    except Exception:
        logger.exception("[app_chat_pg] list_messages failed")
        return []


def insert_message(
    chat_id: str,
    sender_id: str,
    text: str = "",
    list_images: Optional[list] = None,
) -> Optional[dict]:
    if not chat_id or not sender_id:
        return None
    text = text or ""
    imgs = list_images or []
    msg_id = uuid.uuid4().hex
    now = _now()
    try:
        with app_pg.connection() as conn:
            if conn is None:
                return None
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO app_messages (
                        id, chat_id, sender_id, text, list_images, read, date_created, raw_json
                    ) VALUES (%s, %s, %s, %s, %s::jsonb, false, %s, %s::jsonb)
                    """,
                    (
                        msg_id,
                        chat_id,
                        sender_id,
                        text,
                        json.dumps(imgs, ensure_ascii=False),
                        now,
                        json.dumps(
                            {
                                "id": msg_id,
                                "chat_id": chat_id,
                                "sender_id": sender_id,
                                "text": text,
                                "list_images": imgs,
                            },
                            ensure_ascii=False,
                        ),
                    ),
                )
                preview = text if text else ("🖼" if imgs else "")
                cur.execute(
                    """
                    UPDATE app_chats SET last_message = %s, updated_at = %s
                    WHERE id = %s
                    """,
                    (preview[:500], now, chat_id),
                )
            conn.commit()
        out = {
            "id": msg_id,
            "chat_id": chat_id,
            "sender_id": sender_id,
            "text": text,
            "list_images": imgs,
            "read": False,
            "date_created": now.isoformat(),
        }
        _notify_chat_peers(chat_id, sender_id, text=text, list_images=imgs)
        return out
    except Exception:
        logger.exception("[app_chat_pg] insert_message failed")
        return None


def _notify_chat_peers(
    chat_id: str,
    sender_id: str,
    *,
    text: str = "",
    list_images: Optional[list] = None,
) -> None:
    """FCM остальным участникам чата (HTTP + WSS общий путь)."""
    try:
        import app_fcm_ops

        chat = get_chat(chat_id) or {}
        members = chat.get("users") or []
        recipients = [
            str(u).strip()
            for u in members
            if str(u).strip() and str(u).strip() != sender_id
        ]
        if not recipients:
            return
        me = app_pg.get_me(sender_id) or {}
        name = (me.get("display_name") or "").strip() or "Сообщение"
        surname = (me.get("surname") or "").strip()
        title = f"{name} {surname}".strip() if surname else name
        imgs = list_images or []
        if (text or "").strip():
            body = (text or "").strip()[:200]
        elif len(imgs) > 1:
            body = f"{len(imgs)} фото"
        elif imgs:
            body = "Фотография"
        else:
            body = "Новое сообщение"
        app_fcm_ops.notify_safe(
            recipients,
            title=title,
            body=body,
            initial_page_name="Chat",
            parameter_data={"chat": chat_id, "name": title},
            data={"chat_id": chat_id, "event": "chat_message"},
        )
    except Exception:
        logger.exception("[app_chat_pg] chat fcm notify failed")
