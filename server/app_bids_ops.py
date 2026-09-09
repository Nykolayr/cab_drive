"""Отклики на заказ: Postgres SoT + опциональное FS-зеркало."""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from typing import Any, Optional

import app_fs_mirror
import app_pg

logger = logging.getLogger(__name__)


def _now() -> datetime:
    return datetime.now(timezone.utc)


def create_bid(driver_uid: str, order_id: str, body: dict[str, Any]) -> dict[str, Any]:
    if not driver_uid or not order_id:
        raise ValueError("driver and order required")
    order = app_pg.get_order(order_id) or app_fs_mirror.fs_order_get(order_id)
    if not order:
        raise ValueError("order not found")
    status = (order.get("status") or "").strip()
    if status != "newOrder":
        raise ValueError(f"order not open for bids, status={status}")

    bid_id = str(body.get("id") or uuid.uuid4().hex)
    now = _now()
    raw = {
        "id": bid_id,
        "user_driver": {"_ref": f"users/{driver_uid}"},
        "driver_id": driver_uid,
        "viewed": False,
        "text": body.get("text") or "",
        "price": body.get("price"),
        "time": body.get("time") or "",
        "distance": body.get("distance") or "",
        "date_created": now.isoformat(),
    }

    if not app_pg.create_order_response(order_id, bid_id, raw, driver_uid=driver_uid):
        raise RuntimeError("postgres bid insert failed")

    # bump count_resp + user_who_responced in PG
    app_pg.add_order_respondent(order_id, driver_uid)

    def _fs():
        import utils
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayUnion

        utils.init_firebase_client()
        db = firestore.client()
        order_ref = db.collection("order").document(order_id)
        driver_ref = db.collection("users").document(driver_uid)
        resp_ref = order_ref.collection("responses").document(bid_id)
        resp_ref.set(
            {
                "userDriver": driver_ref,
                "viewed": False,
                "text": raw["text"],
                "price": raw["price"],
                "dateCreated": now,
                "time": raw["time"],
                "distance": raw["distance"],
            }
        )
        order_ref.update(
            {
                "user_who_responced": ArrayUnion([driver_ref]),
                "count_resp": firestore.Increment(1),
            }
        )

    app_fs_mirror.soft_fs("create_bid", _fs)
    return {
        "bid_id": bid_id,
        "order_id": order_id,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def list_bids(order_id: str) -> list[dict[str, Any]]:
    return app_pg.list_order_responses(order_id)


def _bid_driver_uid(bid: dict[str, Any]) -> Optional[str]:
    if bid.get("driver_id"):
        return str(bid["driver_id"])
    ref = bid.get("user_driver")
    if isinstance(ref, dict) and ref.get("_ref"):
        return str(ref["_ref"]).rsplit("/", 1)[-1]
    if isinstance(ref, str) and ref:
        return ref.rsplit("/", 1)[-1] if "/" in ref else ref
    return None


def delete_bid(actor_uid: str, order_id: str, bid_id: str) -> dict[str, Any]:
    """Удалить отклик: водитель-владелец отклика или заказчик заказа."""
    if not actor_uid or not order_id or not bid_id:
        raise ValueError("actor, order and bid required")

    bids = list_bids(order_id)
    bid = next((b for b in bids if str(b.get("id")) == str(bid_id)), None)
    if not bid:
        raise ValueError("bid not found")

    driver_uid = _bid_driver_uid(bid)
    order = app_pg.get_order(order_id) or app_fs_mirror.fs_order_get(order_id)
    if not order:
        raise ValueError("order not found")

    owner = None
    for key in ("user_customer", "user_customer_id"):
        val = order.get(key)
        if isinstance(val, dict) and val.get("_ref"):
            owner = str(val["_ref"]).rsplit("/", 1)[-1]
            break
        if isinstance(val, str) and val:
            owner = val.rsplit("/", 1)[-1] if "/" in val else val
            break

    is_driver = bool(driver_uid) and actor_uid == driver_uid
    is_owner = bool(owner) and actor_uid == owner
    if not is_driver and not is_owner:
        raise ValueError("forbidden")

    # заказчик удаляет любой отклик; водитель — только свой
    filter_uid = None if is_owner else actor_uid
    if not app_pg.delete_order_response(order_id, bid_id, driver_uid=filter_uid):
        raise ValueError("bid not found or not owned")
    if driver_uid:
        app_pg.remove_order_respondent(order_id, driver_uid)

    def _fs():
        import utils
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayRemove

        utils.init_firebase_client()
        db = firestore.client()
        order_ref = db.collection("order").document(order_id)
        order_ref.collection("responses").document(bid_id).delete()
        if driver_uid:
            driver_ref = db.collection("users").document(driver_uid)
            order_ref.update(
                {
                    "user_who_responced": ArrayRemove([driver_ref]),
                    "count_resp": firestore.Increment(-1),
                }
            )

    app_fs_mirror.soft_fs("delete_bid", _fs)
    return {
        "deleted": True,
        "bid_id": bid_id,
        "by_owner": is_owner,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def upsert_fcm_token(user_id: str, token: str) -> dict[str, Any]:
    if not user_id or not token:
        raise ValueError("user and token required")
    if not app_pg.upsert_fcm_token(user_id, token):
        raise RuntimeError("postgres fcm upsert failed")
    return {"ok": True, "user_id": user_id}
