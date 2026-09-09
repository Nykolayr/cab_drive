"""Отправка FCM через Postgres app_user_fcm_tokens (без ff_user_push_notifications)."""
from __future__ import annotations

import json
import logging
from typing import Any, Optional

import app_pg

logger = logging.getLogger(__name__)


def _str_data(data: Optional[dict[str, Any]]) -> dict[str, str]:
    out: dict[str, str] = {}
    if not data:
        return out
    for k, v in data.items():
        if v is None:
            continue
        if isinstance(v, (dict, list)):
            out[str(k)] = json.dumps(v, ensure_ascii=False)
        else:
            out[str(k)] = str(v)
    return out


def send_to_users(
    user_ids: list[str],
    *,
    title: str,
    body: str,
    data: Optional[dict[str, Any]] = None,
    initial_page_name: Optional[str] = None,
    parameter_data: Optional[Any] = None,
) -> dict[str, Any]:
    """Шлёт notification+data (как FF CF). Токены из PG, invalid → delete PG."""
    uids = [str(u).strip() for u in (user_ids or []) if str(u).strip()]
    title = (title or "").strip()
    body = (body or "").strip()
    if not uids:
        return {
            "success": False,
            "error": "no user_ids",
            "success_count": 0,
            "failure_count": 0,
            "tokens_cleaned": 0,
        }
    if not title or not body:
        return {
            "success": False,
            "error": "empty title/body",
            "success_count": 0,
            "failure_count": 0,
            "tokens_cleaned": 0,
        }

    tokens = app_pg.list_fcm_tokens(uids)
    source = "postgres"
    if not tokens:
        # переходный fallback: старые токены ещё только в FS
        tokens = _tokens_from_firestore(uids)
        source = "firestore_fallback"

    if not tokens:
        logger.warning("[app_fcm] no tokens for %s users", len(uids))
        return {
            "success": False,
            "error": "No FCM tokens found",
            "success_count": 0,
            "failure_count": 0,
            "tokens_cleaned": 0,
            "source": source,
        }

    payload = _str_data(data)
    if initial_page_name:
        payload["initialPageName"] = str(initial_page_name)
    if parameter_data is not None:
        if isinstance(parameter_data, str):
            payload["parameterData"] = parameter_data
        else:
            payload["parameterData"] = json.dumps(parameter_data, ensure_ascii=False)

    # data-only клиент create_order иногда ждёт title/body в data
    payload.setdefault("title", title)
    payload.setdefault("body", body)

    try:
        import utils
        from firebase_admin import messaging

        utils.init_firebase_client()
    except Exception as e:
        logger.exception("[app_fcm] firebase init failed")
        return {
            "success": False,
            "error": f"firebase init: {e}",
            "success_count": 0,
            "failure_count": 0,
            "tokens_cleaned": 0,
            "source": source,
        }

    success_count = 0
    failure_count = 0
    failed_tokens: list[str] = []

    # FCM multicast limit 500
    for i in range(0, len(tokens), 500):
        batch = tokens[i : i + 500]
        msg = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data=payload,
            tokens=batch,
        )
        try:
            resp = messaging.send_each_for_multicast(msg)
        except Exception as e:
            logger.exception("[app_fcm] send_each_for_multicast failed")
            failure_count += len(batch)
            failed_tokens.extend(batch)
            continue
        success_count += int(resp.success_count or 0)
        failure_count += int(resp.failure_count or 0)
        for idx, r in enumerate(resp.responses or []):
            if not r.success:
                failed_tokens.append(batch[idx])

    cleaned = 0
    for tok in failed_tokens:
        if app_pg.delete_fcm_token(tok):
            cleaned += 1
        _delete_fs_token(tok)

    return {
        "success": success_count > 0,
        "success_count": success_count,
        "failure_count": failure_count,
        "tokens_cleaned": cleaned,
        "token_count": len(tokens),
        "source": source,
    }


def send_to_user(
    user_id: str,
    *,
    title: str,
    body: str,
    data: Optional[dict[str, Any]] = None,
    initial_page_name: Optional[str] = None,
    parameter_data: Optional[Any] = None,
) -> dict[str, Any]:
    return send_to_users(
        [user_id],
        title=title,
        body=body,
        data=data,
        initial_page_name=initial_page_name,
        parameter_data=parameter_data,
    )


def _tokens_from_firestore(user_ids: list[str]) -> list[str]:
    try:
        import utils

        client = utils.init_firebase_client()
        tokens: list[str] = []
        for uid in user_ids:
            docs = client.collection("users").document(uid).collection("fcm_tokens").get()
            for doc in docs:
                t = (doc.to_dict() or {}).get("fcm_token")
                if t:
                    tokens.append(str(t))
        return tokens
    except Exception:
        logger.exception("[app_fcm] FS token fallback failed")
        return []


def _delete_fs_token(token: str) -> None:
    try:
        import utils

        client = utils.init_firebase_client()
        qs = (
            client.collection_group("fcm_tokens")
            .where("fcm_token", "==", token)
            .limit(20)
            .get()
        )
        for doc in qs:
            try:
                doc.reference.delete()
            except Exception:
                pass
    except Exception:
        logger.debug("[app_fcm] FS token delete skipped", exc_info=True)
