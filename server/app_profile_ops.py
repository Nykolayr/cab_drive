"""Адреса профиля и saved_cards: Postgres SoT + soft FS mirror."""
from __future__ import annotations

import logging
import uuid
from typing import Any, Optional

import app_fs_mirror
import app_pg

logger = logging.getLogger(__name__)


def _norm_point(p: Any) -> Optional[dict[str, Any]]:
    if not isinstance(p, dict):
        return None
    out = dict(p)
    ll = out.get("latlng")
    if isinstance(ll, dict):
        lat = ll.get("lat") if ll.get("lat") is not None else ll.get("latitude")
        lng = ll.get("lng") if ll.get("lng") is not None else ll.get("longitude")
        try:
            if lat is not None and lng is not None:
                out["latlng"] = {"lat": float(lat), "lng": float(lng)}
        except (TypeError, ValueError):
            pass
    elif hasattr(ll, "latitude") and hasattr(ll, "longitude"):
        out["latlng"] = {"lat": float(ll.latitude), "lng": float(ll.longitude)}
    return out


def _point_key(p: dict[str, Any]) -> tuple:
    return (
        str(p.get("place_ID") or p.get("placeID") or "").strip(),
        str(p.get("address") or "").strip(),
        str(p.get("fullAddress") or "").strip(),
    )


def _same_point(a: dict[str, Any], b: dict[str, Any]) -> bool:
    ka, kb = _point_key(a), _point_key(b)
    if ka[0] and ka[0] == kb[0]:
        return True
    if ka[1] and ka[1] == kb[1]:
        return True
    if ka[2] and ka[2] == kb[2]:
        return True
    return False


def _load_addresses(uid: str) -> list[dict[str, Any]]:
    me = app_pg.get_me(uid) or {}
    raw = me.get("addresses")
    if not isinstance(raw, list):
        return []
    out = []
    for item in raw:
        n = _norm_point(item)
        if n:
            out.append(n)
    return out


def _save_addresses(uid: str, addresses: list[dict[str, Any]]) -> None:
    if not app_pg.mirror_user_fields(uid, {"addresses_json": addresses}):
        raise RuntimeError("postgres addresses update failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        # FS ожидает GeoPoint для latlng где возможно
        fs_list = []
        for p in addresses:
            item = dict(p)
            ll = item.get("latlng")
            if isinstance(ll, dict) and ll.get("lat") is not None and ll.get("lng") is not None:
                try:
                    item["latlng"] = firestore.GeoPoint(float(ll["lat"]), float(ll["lng"]))
                except Exception:
                    pass
            fs_list.append(item)
        db.collection("users").document(uid).set({"addresses": fs_list}, merge=True)

    app_fs_mirror.soft_fs("save_addresses", _fs)


def add_address(uid: str, body: dict[str, Any]) -> dict[str, Any]:
    point = _norm_point(body.get("address") or body.get("point") or body)
    if not point:
        raise ValueError("address required")
    cur = _load_addresses(uid)
    if any(_same_point(x, point) for x in cur):
        return {"addresses": cur, "added": False, "count": len(cur)}
    cur.append(point)
    _save_addresses(uid, cur)
    return {"addresses": cur, "added": True, "count": len(cur)}


def remove_address(uid: str, body: dict[str, Any]) -> dict[str, Any]:
    point = _norm_point(body.get("address") or body.get("point") or body)
    if not point:
        raise ValueError("address required")
    cur = _load_addresses(uid)
    nxt = [x for x in cur if not _same_point(x, point)]
    if len(nxt) == len(cur):
        return {"addresses": cur, "removed": False, "count": len(cur)}
    _save_addresses(uid, nxt)
    return {"addresses": nxt, "removed": True, "count": len(nxt)}


def list_cards(uid: str) -> list[dict[str, Any]]:
    return app_pg.list_saved_cards(user_id=uid)


def create_card(uid: str, body: dict[str, Any]) -> dict[str, Any]:
    pan = str(body.get("pan") or "").strip()
    if not pan:
        raise ValueError("pan required")
    kind = str(body.get("kind") or "payout").strip() or "payout"
    rebill_id = (body.get("rebill_id") or body.get("RebillId") or "") or None
    if rebill_id is not None:
        rebill_id = str(rebill_id).strip() or None
    card_id = (body.get("card_id") or body.get("CardId") or "") or None
    if card_id is not None:
        card_id = str(card_id).strip() or None
    cid = str(body.get("id") or uuid.uuid4().hex)
    raw = {
        "id": cid,
        "user_id": uid,
        "pan": pan,
        "RebillId": rebill_id,
        "rebill_id": rebill_id,
        "card_id": card_id,
        "kind": kind,
    }
    if not app_pg.create_saved_card(cid, uid, raw):
        raise RuntimeError("postgres card insert failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        db.collection("users").document(uid).collection("saved_cards").document(cid).set(
            {
                "pan": pan,
                "RebillId": rebill_id,
            }
        )

    app_fs_mirror.soft_fs("create_saved_card", _fs)
    return {"id": cid, "pan": pan, "rebill_id": rebill_id, "kind": kind}


def delete_card(uid: str, card_id: str) -> dict[str, Any]:
    if not card_id:
        raise ValueError("card id required")
    row = app_pg.get_saved_card(card_id)
    if not row:
        raise ValueError("card not found")
    if row.get("user_id") != uid:
        raise PermissionError("forbidden")
    if not app_pg.delete_saved_card(card_id):
        raise RuntimeError("postgres card delete failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        db.collection("users").document(uid).collection("saved_cards").document(card_id).delete()

    app_fs_mirror.soft_fs("delete_saved_card", _fs)
    return {"id": card_id, "deleted": True}
