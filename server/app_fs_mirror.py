"""Режим зеркала Firestore на переходный период cutover.

APP_FS_MIRROR=1 (default): после записи в PG ещё пишем FS (старый МП).
APP_FS_MIRROR=0: только Postgres — цель cutover.
"""
from __future__ import annotations

import logging
import os
from typing import Any, Optional

logger = logging.getLogger(__name__)


def fs_mirror_enabled() -> bool:
    v = (os.environ.get("APP_FS_MIRROR") or "1").strip().lower()
    return v not in ("0", "false", "no", "off")


def soft_fs(fn_name: str, fn) -> bool:
    """Выполнить fn() только если зеркало включено; ошибки FS не валят PG."""
    if not fs_mirror_enabled():
        return False
    try:
        fn()
        return True
    except Exception:
        logger.exception("[app_fs_mirror] %s failed", fn_name)
        return False


def fs_user_get(uid: str) -> Optional[dict[str, Any]]:
    if not uid:
        return None
    try:
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        snap = firestore.client().collection("users").document(uid).get()
        if not snap.exists:
            return None
        data = snap.to_dict() or {}
        data["id"] = snap.id
        return data
    except Exception:
        logger.exception("[app_fs_mirror] fs_user_get %s", uid)
        return None


def fs_order_get(order_id: str) -> Optional[dict[str, Any]]:
    if not order_id:
        return None
    try:
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        snap = firestore.client().collection("order").document(order_id).get()
        if not snap.exists:
            return None
        data = snap.to_dict() or {}
        data["id"] = snap.id
        return data
    except Exception:
        logger.exception("[app_fs_mirror] fs_order_get %s", order_id)
        return None
