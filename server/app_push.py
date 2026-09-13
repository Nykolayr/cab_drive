"""Единая точка push (FCM) для app-событий. Smoke / логи / валидные токены."""
from __future__ import annotations

import logging
import re
from typing import Any, Optional

import app_fcm_ops
import app_pg

logger = logging.getLogger(__name__)

# Firestore doc id ≈ 20 символов; настоящий FCM — длинный и с ':'.
_MIN_TOKEN_LEN = 80


def is_valid_fcm_token(token: str | None) -> bool:
    t = (token or "").strip()
    if len(t) < _MIN_TOKEN_LEN:
        return False
    if ":" not in t:
        return False
    return True


def normalize_phone_digits(phone: str) -> str:
    return re.sub(r"\D+", "", phone or "")


def find_user_ids_by_phone(phone: str) -> list[str]:
    digits = normalize_phone_digits(phone)
    if len(digits) < 10:
        return []
    last10 = digits[-10:]

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id FROM app_users
                WHERE RIGHT(
                    REGEXP_REPLACE(COALESCE(phone_number, ''), '[^0-9]', '', 'g'),
                    10
                ) = %s
                LIMIT 20
                """,
                (last10,),
            )
            return [str(r[0]) for r in cur.fetchall() if r and r[0]]

    try:
        with app_pg.connection() as conn:
            if conn is None:
                return []
            return _run(conn)
    except Exception:
        logger.exception("[app_push] find_user_ids_by_phone failed")
        return []


def notify(
    event: str,
    user_ids: list[str],
    *,
    title: str,
    body: str,
    data: Optional[dict[str, Any]] = None,
    initial_page_name: Optional[str] = None,
    parameter_data: Optional[Any] = None,
) -> dict[str, Any]:
    """Server-first FCM. Всегда логируем event + результат."""
    payload = dict(data or {})
    payload.setdefault("event", event)
    result = app_fcm_ops.notify_safe(
        user_ids,
        title=title,
        body=body,
        data=payload,
        initial_page_name=initial_page_name,
        parameter_data=parameter_data,
    )
    logger.info(
        "[app_push] event=%s users=%s success=%s ok=%s fail=%s err=%s cleaned=%s",
        event,
        len([u for u in (user_ids or []) if u]),
        result.get("success"),
        result.get("success_count"),
        result.get("failure_count"),
        result.get("error"),
        result.get("tokens_cleaned"),
    )
    return result


def smoke_to_phone(
    phone: str,
    *,
    title: str = "Cab Drive тест",
    body: str = "Проверка пуша с сервера",
) -> dict[str, Any]:
    uids = find_user_ids_by_phone(phone)
    if not uids:
        return {
            "success": False,
            "error": "user_not_found_by_phone",
            "phone": normalize_phone_digits(phone),
            "user_ids": [],
        }
    result = notify(
        "smoke_test",
        uids,
        title=title,
        body=body,
        data={"event": "smoke_test", "phone": normalize_phone_digits(phone)},
    )
    result["user_ids"] = uids
    result["phone"] = normalize_phone_digits(phone)
    return result


def purge_invalid_tokens() -> dict[str, Any]:
    """Удалить мусор (часто Firestore doc id из миграции)."""

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                DELETE FROM app_user_fcm_tokens
                WHERE length(token) < %s OR position(':' in token) = 0
                """,
                (_MIN_TOKEN_LEN,),
            )
            return int(cur.rowcount or 0)

    try:
        with app_pg.connection() as conn:
            if conn is None:
                return {"deleted": 0, "error": "no_db"}
            deleted = _run(conn)
        logger.info("[app_push] purged invalid fcm tokens deleted=%s", deleted)
        return {"deleted": deleted}
    except Exception as e:
        logger.exception("[app_push] purge_invalid_tokens failed")
        return {"deleted": 0, "error": str(e)}
