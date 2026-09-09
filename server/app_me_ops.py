"""
Операции профиля МП: Postgres = SoT; Firestore — опциональное зеркало (APP_FS_MIRROR).
"""
from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Any

import app_fs_mirror
import app_pg

logger = logging.getLogger(__name__)


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _num(val: Any, default: float = 0.0) -> float:
    if val is None:
        return default
    try:
        return float(val)
    except (TypeError, ValueError):
        return default


def _load_user(uid: str) -> dict[str, Any]:
    data = app_pg.get_me(uid)
    if data:
        return data
    # без Firestore SoT: создаём минимальную строку
    app_pg.mirror_user_fields(uid, {"login_complete": False})
    data = app_pg.get_me(uid)
    if data:
        return data
    raise ValueError("user not found")


def _compute_shift_writeoff(commission: float, bonus: float, main: float) -> dict[str, float]:
    commission = max(0.0, commission)
    bonus = max(0.0, bonus)
    from_bonus = commission if commission <= bonus else bonus
    from_main = commission - from_bonus
    main_after = main - from_main
    bonus_after = bonus - from_bonus
    if main_after < 0 and bonus_after > 0:
        cover = abs(main_after)
        if cover > bonus_after:
            cover = bonus_after
        from_bonus += cover
        from_main -= cover
        main_after = main - from_main
        bonus_after = bonus - from_bonus
    return {
        "from_bonus": float(from_bonus),
        "from_main": float(from_main),
        "main_after": float(main_after),
        "bonus_after": float(bonus_after),
        "commission": float(commission),
    }


def _mirror_user_fs(uid: str, fields: dict[str, Any], *, delete_keys: list[str] | None = None):
    def _run():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        ref = firestore.client().collection("users").document(uid)
        patch = dict(fields)
        for k in delete_keys or []:
            patch[k] = firestore.DELETE_FIELD
        ref.update(patch)

    app_fs_mirror.soft_fs("user_update", _run)


def shift_start(uid: str) -> dict[str, Any]:
    data = _load_user(uid)
    balance = _num(data.get("balance"))
    bonus = _num(data.get("bonus_balance"))
    if balance + bonus < 0:
        raise ValueError("work debt: cannot start shift")

    now = _now()
    ok = app_pg.mirror_user_fields(
        uid,
        {"on_shift": True, "shift_start_date_time": now},
    )
    if not ok and not app_pg.enabled():
        raise RuntimeError("postgres unavailable")

    _mirror_user_fs(uid, {"on_shift": True, "shift_start_date_time": now})
    return {
        "on_shift": True,
        "shift_start_date_time": now.isoformat(),
        "balance": balance,
        "bonus_balance": bonus,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def shift_end(uid: str) -> dict[str, Any]:
    data = _load_user(uid)
    commission = _num(data.get("current_commision"))
    bonus = _num(data.get("bonus_balance"))
    main = _num(data.get("balance"))
    wo = _compute_shift_writeoff(commission, bonus, main)
    now = _now()
    pg_fields = {
        "on_shift": False,
        "shift_completion_date_time": now,
        "balance": wo["main_after"],
        "bonus_balance": wo["bonus_after"],
        "current_commision": None,
    }
    if not app_pg.mirror_user_fields(uid, pg_fields):
        if not app_pg.enabled():
            raise RuntimeError("postgres unavailable")

    _mirror_user_fs(
        uid,
        {
            "on_shift": False,
            "shift_completion_date_time": now,
            "balance": wo["main_after"],
            "bonus_balance": wo["bonus_after"],
        },
        delete_keys=["current_commision"],
    )
    return {
        **wo,
        "on_shift": False,
        "shift_completion_date_time": now.isoformat(),
        "balance": wo["main_after"],
        "bonus_balance": wo["bonus_after"],
        "current_commision": 0,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def apply_late_commission_fine(uid: str, amount: float = 3000.0) -> dict[str, Any]:
    data = _load_user(uid)
    if data.get("fine") is True:
        return {
            "already_fined": True,
            "balance": _num(data.get("balance")),
            "fine": True,
        }
    now = _now()
    new_balance = _num(data.get("balance")) - float(amount)
    app_pg.mirror_user_fields(
        uid,
        {"fine": True, "balance": new_balance, "last_online": now},
    )
    _mirror_user_fs(
        uid,
        {"fine": True, "balance": new_balance, "last_online": now},
    )
    return {
        "already_fined": False,
        "balance": new_balance,
        "fine": True,
        "amount": float(amount),
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def clear_fine_flag(uid: str) -> dict[str, Any]:
    now = _now()
    app_pg.mirror_user_fields(uid, {"fine": False, "last_online": now})
    _mirror_user_fs(uid, {"last_online": now}, delete_keys=["fine"])
    return {
        "fine": False,
        "last_online": now.isoformat(),
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def ping_me_location(uid: str, *, lat: float, lng: float) -> dict[str, Any]:
    """Live позиция водителя на users (смена)."""
    if not uid:
        raise ValueError("uid required")
    ok = app_pg.mirror_user_fields(
        uid, {"driver_lat": float(lat), "driver_lng": float(lng)}
    )
    if not ok and not app_pg.enabled():
        raise RuntimeError("postgres unavailable")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        firestore.client().collection("users").document(uid).update(
            {"driver_location": firestore.GeoPoint(float(lat), float(lng))}
        )

    app_fs_mirror.soft_fs("ping_me_location", _fs)
    return {
        "driver_lat": float(lat),
        "driver_lng": float(lng),
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


_PATCH_ME_KEYS = {
    "email",
    "display_name",
    "photo_url",
    "phone_number",
    "is_driver",
    "surname",
    "city",
    "region",
    "email_user",
    "login_complete",
    "dfb",
    "fb_id",
    "chat_with_support_id",
    "current_order_json",
    "car_json",
    "addresses_json",
}


def patch_me(uid: str, body: dict[str, Any]) -> dict[str, Any]:
    """Частичный апдейт профиля МП → Postgres SoT (без FS)."""
    if not uid:
        raise ValueError("uid required")
    if not isinstance(body, dict):
        raise ValueError("body must be object")

    fields: dict[str, Any] = {}
    for k, v in body.items():
        if k not in _PATCH_ME_KEYS:
            continue
        fields[k] = v

    # aliases from Flutter field names
    if "displayName" in body and "display_name" not in fields:
        fields["display_name"] = body.get("displayName")
    if "photoUrl" in body and "photo_url" not in fields:
        fields["photo_url"] = body.get("photoUrl")
    if "phoneNumber" in body and "phone_number" not in fields:
        fields["phone_number"] = body.get("phoneNumber")
    if "isDriver" in body and "is_driver" not in fields:
        fields["is_driver"] = body.get("isDriver")
    if "fbId" in body and "fb_id" not in fields:
        fields["fb_id"] = body.get("fbId")
    if "currentOrder" in body and "current_order_json" not in fields:
        fields["current_order_json"] = body.get("currentOrder")
    if "chatWithSupport" in body and "chat_with_support_id" not in fields:
        ref = body.get("chatWithSupport")
        if isinstance(ref, dict) and "_ref" in ref:
            fields["chat_with_support_id"] = str(ref["_ref"]).rsplit("/", 1)[-1]
        elif isinstance(ref, str) and ref:
            fields["chat_with_support_id"] = ref.rsplit("/", 1)[-1]

    if not fields:
        raise ValueError("no allowed fields")

    if not app_pg.mirror_user_fields(uid, fields):
        raise RuntimeError("postgres patch_me failed")

    me = app_pg.get_me(uid) or {"id": uid}
    return {"user": me, "fs_mirror": False}
