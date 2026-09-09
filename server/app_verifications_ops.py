"""Заявки на верификацию водителя: Postgres SoT + soft FS mirror."""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from typing import Any, Optional

import app_fs_mirror
import app_pg

logger = logging.getLogger(__name__)

STATUS_ON = "onVerif"
STATUS_OK = "Completed"
STATUS_REJECT = "otklonena"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _parse_dt(v: Any) -> Optional[datetime]:
    if v is None or v == "":
        return None
    if isinstance(v, datetime):
        return v
    s = str(v).strip()
    if not s:
        return None
    try:
        return datetime.fromisoformat(s.replace("Z", "+00:00"))
    except ValueError:
        return None


def _as_str_list(v: Any) -> list[str]:
    if v is None:
        return []
    if isinstance(v, str):
        return [v] if v else []
    if isinstance(v, (list, tuple)):
        return [str(x) for x in v if x is not None and str(x).strip()]
    return []


def create_verification(uid: str, body: dict[str, Any]) -> dict[str, Any]:
    if not uid:
        raise ValueError("uid required")

    ver_id = str(body.get("id") or uuid.uuid4().hex)
    now = _now()
    marka = body.get("marka")
    if marka is not None:
        marka = str(marka)

    photo_doc = _as_str_list(body.get("photo_doc"))
    photo_avto = _as_str_list(body.get("photo_avto"))
    dfb = _parse_dt(body.get("dfb") or body.get("dtb"))

    commission = body.get("commission_percent")
    try:
        commission_f = float(commission) if commission is not None else None
    except (TypeError, ValueError):
        commission_f = None

    number_id = app_pg.next_verification_number_id()
    if not number_id:
        raise RuntimeError("failed to allocate number_id")

    raw = {
        "id": ver_id,
        "user_id": uid,
        "user": {"_ref": f"users/{uid}"},
        "email": (body.get("email") or body.get("mail") or "").strip() or None,
        "phone_number": (body.get("phone_number") or "").strip() or None,
        "city": (body.get("city") or "").strip() or None,
        "name": (body.get("name") or "").strip() or None,
        "surname": (body.get("surname") or body.get("surnme") or "").strip() or None,
        "dfb": dfb.isoformat() if dfb else None,
        "dateCreated": now.isoformat(),
        "number_id": number_id,
        "number_avto": (body.get("number_avto") or body.get("nomer") or "").strip() or None,
        "marka": marka,
        "marka_avto": (body.get("marka_avto") or "").strip() or None,
        "avatar": (body.get("avatar") or "").strip() or None,
        "photo_doc": photo_doc,
        "photo_avto": photo_avto,
        "status": STATUS_ON,
        "commission_percent": commission_f,
    }

    if not app_pg.create_verification(ver_id, raw, user_id=uid, number_id=number_id):
        raise RuntimeError("postgres verification insert failed")

    car = {
        "nomer": raw.get("number_avto") or "",
        "images": photo_avto,
        "mark": marka,
    }
    app_pg.mirror_user_fields(
        uid,
        {
            "display_name": raw.get("name"),
            "surname": raw.get("surname"),
            "city": raw.get("city"),
            "email_user": raw.get("email"),
            "is_driver": True,
            "login_complete": True,
            "admin": False,
            "verif_compl": False,
            "on_verif_now": True,
            "verif_ne_proidena": False,
            "verif_id": number_id,
            "commission_percent": commission_f,
            "dfb": dfb,
            "car_json": car,
        },
    )

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        user_ref = db.collection("users").document(uid)
        db.collection("request_verefication").document(ver_id).set(
            {
                "email": raw.get("email") or "",
                "phone_number": raw.get("phone_number") or "",
                "city": raw.get("city") or "",
                "name": raw.get("name") or "",
                "surname": raw.get("surname") or "",
                "dfb": dfb,
                "dateCreated": now,
                "number_id": number_id,
                "number_avto": raw.get("number_avto") or "",
                "marka": marka,
                "avatar": raw.get("avatar") or "",
                "photo_doc": photo_doc,
                "photo_avto": photo_avto,
                "user": user_ref,
                "status": STATUS_ON,
                "commission_percent": commission_f or 0,
            }
        )
        user_ref.set(
            {
                "display_name": raw.get("name"),
                "surname": raw.get("surname"),
                "city": raw.get("city"),
                "email_user": raw.get("email"),
                "is_driver": True,
                "login_complete": True,
                "admin": False,
                "verif_compl": False,
                "on_verif_now": True,
                "verif_ne_proidena": False,
                "verif_id": number_id,
                "commission_percent": commission_f,
                "dfb": dfb,
                "car": car,
            },
            merge=True,
        )

    app_fs_mirror.soft_fs("create_verification", _fs)
    return {
        "id": ver_id,
        "number_id": number_id,
        "status": STATUS_ON,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def list_mine(uid: str, *, limit: int = 20) -> list[dict[str, Any]]:
    return app_pg.list_verifications(user_id=uid, limit=limit)


def count_mine(uid: str) -> int:
    return app_pg.count_verifications(user_id=uid)


def get_verification(ver_id: str) -> Optional[dict[str, Any]]:
    return app_pg.get_verification(ver_id)


def list_for_admin(*, status: Optional[str] = None, limit: int = 100) -> list[dict[str, Any]]:
    return app_pg.list_verifications(status=status, limit=limit)


def _require_admin(actor_uid: str) -> dict[str, Any]:
    me = app_pg.get_me(actor_uid) or app_pg.get_user(actor_uid)
    if not me or not me.get("admin"):
        raise PermissionError("admin only")
    return me


def _apply_approve(ver_id: str, user_id: str) -> dict[str, Any]:
    if not app_pg.set_verification_status(ver_id, STATUS_OK):
        raise RuntimeError("status update failed")
    app_pg.mirror_user_fields(
        user_id,
        {
            "on_verif_now": False,
            "verif_compl": True,
            "verif_ne_proidena": False,
            "is_driver": True,
        },
    )

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        db.collection("request_verefication").document(ver_id).set(
            {"status": STATUS_OK}, merge=True
        )
        db.collection("users").document(user_id).set(
            {
                "on_verif_now": False,
                "verif_compl": True,
                "verif_ne_proidena": False,
                "is_driver": True,
            },
            merge=True,
        )

    app_fs_mirror.soft_fs("approve_verification", _fs)
    return {"id": ver_id, "status": STATUS_OK, "user_id": user_id}


def _apply_reject(ver_id: str, user_id: str) -> dict[str, Any]:
    if not app_pg.set_verification_status(ver_id, STATUS_REJECT):
        raise RuntimeError("status update failed")
    app_pg.mirror_user_fields(
        user_id,
        {
            "on_verif_now": False,
            "verif_compl": False,
            "verif_ne_proidena": True,
        },
    )

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        db.collection("request_verefication").document(ver_id).set(
            {"status": STATUS_REJECT}, merge=True
        )
        db.collection("users").document(user_id).set(
            {
                "on_verif_now": False,
                "verif_compl": False,
                "verif_ne_proidena": True,
            },
            merge=True,
        )

    app_fs_mirror.soft_fs("reject_verification", _fs)
    return {"id": ver_id, "status": STATUS_REJECT, "user_id": user_id}


def approve(actor_uid: str, ver_id: str) -> dict[str, Any]:
    _require_admin(actor_uid)
    row = app_pg.get_verification(ver_id)
    if not row:
        raise ValueError("verification not found")
    user_id = row.get("user_id")
    if not user_id:
        raise ValueError("user_id missing")
    return _apply_approve(ver_id, user_id)


def reject(actor_uid: str, ver_id: str) -> dict[str, Any]:
    _require_admin(actor_uid)
    row = app_pg.get_verification(ver_id)
    if not row:
        raise ValueError("verification not found")
    user_id = row.get("user_id")
    if not user_id:
        raise ValueError("user_id missing")
    return _apply_reject(ver_id, user_id)


def get_for_driver(uid: str) -> Optional[dict[str, Any]]:
    """Dashboard: latest verification for driver (prefer onVerif)."""
    if not uid:
        return None
    row = app_pg.get_latest_verification_for_user(uid, prefer_status=STATUS_ON)
    if not row:
        return None
    # shape как старый FS JSON для шаблона
    out = dict(row)
    out["user"] = uid
    if out.get("dateCreated") and "T" in str(out["dateCreated"]):
        out["dateCreated"] = str(out["dateCreated"]).split("T", 1)[0]
    if out.get("dfb") and "T" in str(out["dfb"]):
        out["dfb"] = str(out["dfb"]).split("T", 1)[0]
    return out


def _parse_admin_dt(v: Any) -> Optional[datetime]:
    if v is None or v == "":
        return None
    if isinstance(v, datetime):
        return v
    if isinstance(v, (int, float)):
        # JS иногда шлёт unix seconds
        try:
            n = float(v)
            if n > 1e12:
                n = n / 1000.0
            return datetime.fromtimestamp(n, tz=timezone.utc)
        except (OverflowError, OSError, ValueError):
            return None
    return _parse_dt(v)


def upsert_from_admin(uid: str, fields: dict[str, Any]) -> dict[str, Any]:
    """Dashboard Save: PG upsert + soft FS by document id (без дублей)."""
    if not uid:
        raise ValueError("user_id required")
    existing = app_pg.get_latest_verification_for_user(uid, prefer_status=None)
    ver_id = str(fields.get("id") or (existing or {}).get("id") or uuid.uuid4().hex)

    photo_doc = _as_str_list(fields.get("photo_doc"))
    photo_avto = _as_str_list(fields.get("photo_avto"))
    dfb = _parse_admin_dt(fields.get("dfb"))
    date_created = _parse_admin_dt(fields.get("dateCreated") or fields.get("date_created"))
    status = str(fields.get("status") or (existing or {}).get("status") or STATUS_ON)
    number_id = fields.get("number_id")
    if number_id is not None and number_id != "":
        try:
            number_id = int(number_id)
        except (TypeError, ValueError):
            number_id = (existing or {}).get("number_id")
    else:
        number_id = (existing or {}).get("number_id")
    if not number_id:
        number_id = app_pg.next_verification_number_id()

    patch = {
        "status": status,
        "email": fields.get("email"),
        "phone_number": fields.get("phone_number"),
        "city": fields.get("city"),
        "name": fields.get("name"),
        "surname": fields.get("surname"),
        "dfb": dfb,
        "number_avto": fields.get("number_avto"),
        "marka": fields.get("marka"),
        "marka_avto": fields.get("marka_avto"),
        "avatar": fields.get("avatar"),
        "photo_doc": photo_doc,
        "photo_avto": photo_avto,
        "number_id": number_id,
        "user_id": uid,
        "id": ver_id,
        "dateCreated": date_created.isoformat() if date_created else None,
    }
    if date_created is not None:
        patch["date_created"] = date_created

    if existing and existing.get("id") == ver_id:
        if not app_pg.update_verification(ver_id, patch):
            raise RuntimeError("postgres verification update failed")
    elif existing:
        # обновляем найденную latest запись
        ver_id = str(existing["id"])
        patch["id"] = ver_id
        if not app_pg.update_verification(ver_id, patch):
            raise RuntimeError("postgres verification update failed")
    else:
        raw = dict(patch)
        raw["user"] = {"_ref": f"users/{uid}"}
        if not app_pg.create_verification(
            ver_id, raw, user_id=uid, number_id=int(number_id)
        ):
            raise RuntimeError("postgres verification insert failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        user_ref = db.collection("users").document(uid)
        fs_data = {
            "email": patch.get("email") or "",
            "phone_number": patch.get("phone_number") or "",
            "city": patch.get("city") or "",
            "name": patch.get("name") or "",
            "surname": patch.get("surname") or "",
            "dfb": dfb,
            "dateCreated": date_created or _now(),
            "number_id": number_id,
            "number_avto": patch.get("number_avto") or "",
            "marka": patch.get("marka"),
            "marka_avto": patch.get("marka_avto") or "",
            "avatar": patch.get("avatar") or "",
            "photo_doc": photo_doc,
            "photo_avto": photo_avto,
            "user": user_ref,
            "status": status,
        }
        db.collection("request_verefication").document(ver_id).set(fs_data, merge=True)

    app_fs_mirror.soft_fs("upsert_verification_admin", _fs)
    return {"id": ver_id, "user_id": uid, "status": status, "number_id": number_id}


def approve_by_user_id(uid: str) -> dict[str, Any]:
    """Dashboard session approve (без Firebase admin check)."""
    row = app_pg.get_latest_verification_for_user(uid, prefer_status=STATUS_ON)
    if not row:
        row = app_pg.get_latest_verification_for_user(uid, prefer_status=None)
    if not row:
        raise ValueError("verification not found")
    return _apply_approve(str(row["id"]), uid)


def reject_by_user_id(uid: str) -> dict[str, Any]:
    """Dashboard session reject (без Firebase admin check)."""
    row = app_pg.get_latest_verification_for_user(uid, prefer_status=STATUS_ON)
    if not row:
        row = app_pg.get_latest_verification_for_user(uid, prefer_status=None)
    if not row:
        raise ValueError("verification not found")
    return _apply_reject(str(row["id"]), uid)
