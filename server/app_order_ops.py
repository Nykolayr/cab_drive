"""
Завершение заказа: Postgres = SoT; Firestore — зеркало (APP_FS_MIRROR).
"""
from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Any, Optional

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


def _ref_uid(val: Any) -> Optional[str]:
    if val is None:
        return None
    if hasattr(val, "id"):
        return str(val.id)
    if isinstance(val, str):
        return val.rsplit("/", 1)[-1] if "/" in val else val
    if isinstance(val, dict) and "_ref" in val:
        return str(val["_ref"]).rsplit("/", 1)[-1]
    return None


def _pay_is_card(pay_method: Any) -> bool:
    s = (str(pay_method or "")).lower().strip()
    return s in ("card", "paymethod.card")


def _load_order(order_id: str) -> dict[str, Any]:
    data = app_pg.get_order(order_id)
    if data:
        return data
    fs = app_fs_mirror.fs_order_get(order_id)
    if fs:
        return fs
    raise ValueError("order not found")


def _load_driver(uid: str) -> dict[str, Any]:
    data = app_pg.get_me(uid) or app_pg.get_user(uid)
    if data:
        return data
    fs = app_fs_mirror.fs_user_get(uid)
    if fs:
        return fs
    raise ValueError("driver not found")


def complete_order_by_customer(actor_uid: str, order_id: str) -> dict[str, Any]:
    if not actor_uid or not order_id:
        raise ValueError("uid and order_id required")

    order = _load_order(order_id)
    status = (order.get("status") or "").strip()
    if status.lower() == "completed":
        return {"already_completed": True, "order_id": order_id, "status": "completed"}
    if status != "on_confirmation":
        raise ValueError(f"order status must be on_confirmation, got {status}")

    customer_uid = _ref_uid(order.get("user_customer"))
    if not customer_uid:
        raise ValueError("order has no user_customer")
    if customer_uid != actor_uid:
        raise ValueError("only order customer can complete")

    driver_uid = _ref_uid(order.get("selected_driver"))
    if not driver_uid:
        raise ValueError("order has no selected_driver")

    driver = _load_driver(driver_uid)
    price = _num(order.get("currentPrice"), _num(order.get("budget")))
    pct = _num(driver.get("commission_percent") or driver.get("commission"), 15.0)
    if pct <= 0:
        pct = 15.0
    commission = (price / 100.0) * pct
    pay_method = order.get("payMethod") or order.get("pay_method")
    card = _pay_is_card(pay_method)
    now = _now()

    if not app_pg.mirror_order_fields(
        order_id, {"status": "completed", "date_upd": now.isoformat()}
    ):
        if not app_pg.enabled():
            raise RuntimeError("postgres unavailable")

    out: dict[str, Any] = {
        "already_completed": False,
        "order_id": order_id,
        "status": "completed",
        "driver_uid": driver_uid,
        "pay_method": str(pay_method),
        "price": price,
        "commission_percent": pct,
        "commission": commission,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }

    if card:
        new_balance = _num(driver.get("balance")) + commission
        app_pg.mirror_user_fields(driver_uid, {"balance": new_balance})
        out["credit_field"] = "balance"
        out["driver_balance"] = new_balance
        driver_fs = {"balance": new_balance}
    else:
        new_comm = _num(driver.get("current_commision")) + commission
        app_pg.mirror_user_fields(driver_uid, {"current_commision": new_comm})
        out["credit_field"] = "current_commision"
        out["driver_current_commision"] = new_comm
        driver_fs = {"current_commision": new_comm}

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        db.collection("order").document(order_id).update(
            {"status": "completed", "date_upd": now}
        )
        db.collection("users").document(driver_uid).update(driver_fs)

    app_fs_mirror.soft_fs("complete_order", _fs)
    return out


def create_order_for_customer(actor_uid: str, body: dict[str, Any]) -> dict[str, Any]:
    """Создать заказ: PG SoT + опционально FS."""
    import uuid

    if not actor_uid:
        raise ValueError("uid required")
    if not isinstance(body, dict):
        raise ValueError("body must be object")

    order_id = str(body.get("id") or "").strip() or uuid.uuid4().hex
    now = _now()
    payload = dict(body)
    payload["id"] = order_id
    payload["status"] = payload.get("status") or "newOrder"
    payload["user_customer"] = {"_ref": f"users/{actor_uid}"}
    payload["user_customer_id"] = actor_uid
    if not payload.get("dateTime_created"):
        payload["dateTime_created"] = now.isoformat()

    if not app_pg.create_order(order_id, payload):
        raise RuntimeError("postgres create_order failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        fs_doc = dict(payload)
        fs_doc["user_customer"] = db.collection("users").document(actor_uid)
        # убрать служебные
        fs_doc.pop("user_customer_id", None)
        db.collection("order").document(order_id).set(fs_doc, merge=True)

    app_fs_mirror.soft_fs("create_order", _fs)
    return {
        "order_id": order_id,
        "status": payload["status"],
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


_ALLOWED_DRIVER_STATUSES = {
    "spec_set",
    "place_pickup",
    "at_work",
    "place_delivery",
    "on_confirmation",
    "cancelled",
}


def set_order_status(
    actor_uid: str,
    order_id: str,
    status: str,
    *,
    extra: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Водитель (selected_driver) меняет статус заказа."""
    if not actor_uid or not order_id or not status:
        raise ValueError("uid, order_id, status required")
    status = str(status).strip()
    if status not in _ALLOWED_DRIVER_STATUSES:
        raise ValueError(f"status not allowed: {status}")

    order = _load_order(order_id)
    driver_uid = _ref_uid(order.get("selected_driver")) or _ref_uid(
        order.get("selected_driver_id")
    )
    if driver_uid != actor_uid:
        raise ValueError("only selected driver can change status")

    now = _now()
    fields: dict[str, Any] = {"status": status, "date_upd": now.isoformat()}
    if extra:
        # lat/lng / driver_location
        if "driver_lat" in extra:
            fields["driver_lat"] = extra["driver_lat"]
        if "driver_lng" in extra:
            fields["driver_lng"] = extra["driver_lng"]
        if "driverLocation" in extra:
            fields["driverLocation"] = extra["driverLocation"]
        if "image_compl" in extra:
            fields["image_compl"] = extra["image_compl"]

    if not app_pg.mirror_order_fields(order_id, fields):
        if not app_pg.enabled():
            raise RuntimeError("postgres unavailable")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        patch = {"status": status, "date_upd": now}
        if extra and "driverLocation" in extra:
            loc = extra["driverLocation"]
            if isinstance(loc, dict) and "lat" in loc and "lng" in loc:
                patch["driver_location"] = firestore.GeoPoint(
                    float(loc["lat"]), float(loc["lng"])
                )
            elif isinstance(loc, (list, tuple)) and len(loc) >= 2:
                patch["driver_location"] = firestore.GeoPoint(
                    float(loc[0]), float(loc[1])
                )
        if extra and "image_compl" in extra:
            patch["image_compl"] = extra["image_compl"]
        db.collection("order").document(order_id).update(patch)

    app_fs_mirror.soft_fs("set_order_status", _fs)
    return {
        "order_id": order_id,
        "status": status,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def accept_bid(
    customer_uid: str,
    order_id: str,
    driver_uid: str,
    *,
    price: Any = None,
    commission_percent: Any = None,
) -> dict[str, Any]:
    """Клиент выбирает отклик: status=spec_set + selected_driver + queue."""
    if not customer_uid or not order_id or not driver_uid:
        raise ValueError("customer, order, driver required")

    order = _load_order(order_id)
    status = (order.get("status") or "").strip()
    owner = _ref_uid(order.get("user_customer")) or _ref_uid(
        order.get("user_customer_id")
    )
    if owner != customer_uid:
        raise ValueError("only order customer can accept bid")

    existing_driver = _ref_uid(order.get("selected_driver")) or _ref_uid(
        order.get("selected_driver_id")
    )
    if status == "spec_set" and existing_driver == driver_uid:
        app_pg.mirror_user_queue_add(driver_uid, order_id)
        return {
            "order_id": order_id,
            "driver_uid": driver_uid,
            "status": "spec_set",
            "already": True,
            "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
        }
    if status != "newOrder":
        raise ValueError(f"order not open, status={status}")

    now = _now()
    fields: dict[str, Any] = {
        "status": "spec_set",
        "selected_driver": {"_ref": f"users/{driver_uid}"},
        "selected_driver_id": driver_uid,
        "date_upd": now.isoformat(),
    }
    if price is not None:
        try:
            fields["currentPrice"] = int(price)
        except (TypeError, ValueError):
            fields["currentPrice"] = price
    if commission_percent is not None:
        try:
            fields["commissionPercent"] = int(float(commission_percent))
        except (TypeError, ValueError):
            fields["commissionPercent"] = commission_percent

    if not app_pg.mirror_order_fields(order_id, fields):
        raise RuntimeError("postgres update failed")
    app_pg.mirror_user_queue_add(driver_uid, order_id)

    def _fs():
        import utils
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayUnion

        utils.init_firebase_client()
        db = firestore.client()
        order_ref = db.collection("order").document(order_id)
        driver_ref = db.collection("users").document(driver_uid)
        patch = {
            "status": "spec_set",
            "selected_driver": driver_ref,
            "date_upd": now,
        }
        if "currentPrice" in fields:
            patch["currentPrice"] = fields["currentPrice"]
        if "commissionPercent" in fields:
            patch["commissionPercent"] = fields["commissionPercent"]
        order_ref.update(patch)
        driver_ref.update({"active_orders_queue": ArrayUnion([order_ref])})

    app_fs_mirror.soft_fs("accept_bid", _fs)
    return {
        "order_id": order_id,
        "driver_uid": driver_uid,
        "status": "spec_set",
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def extra_accept(driver_uid: str, order_id: str) -> dict[str, Any]:
    """
    Водитель принимает доп.заказ «по пути»: newOrder → spec_set + queue.
    PG-first; soft FS mirror. Raises ValueError on race/queue_full/missing.
    """
    if not driver_uid or not order_id:
        raise ValueError("driver and order required")

    import settings

    max_queue = int(getattr(settings.get_model(), "driver_max_queue_size", 2) or 2)
    order = _load_order(order_id)
    status = (order.get("status") or "").strip()
    existing_driver = _ref_uid(order.get("selected_driver")) or _ref_uid(
        order.get("selected_driver_id")
    )
    if status == "spec_set" and existing_driver == driver_uid:
        queue = app_pg.get_user_queue(driver_uid)
        if order_id not in queue:
            app_pg.mirror_user_queue_add(driver_uid, order_id)
            queue = app_pg.get_user_queue(driver_uid)
        return {
            "order_id": order_id,
            "queue_size": len(queue),
            "already": True,
            "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
        }
    if status.lower() != "neworder":
        raise ValueError("Заказ уже принят другим водителем")

    queue = app_pg.get_user_queue(driver_uid)
    if len(queue) >= max_queue:
        raise ValueError("Очередь заказов переполнена")

    now = _now()
    fields: dict[str, Any] = {
        "status": "spec_set",
        "selected_driver": {"_ref": f"users/{driver_uid}"},
        "selected_driver_id": driver_uid,
        "date_upd": now.isoformat(),
    }
    if not app_pg.mirror_order_fields(order_id, fields):
        raise RuntimeError("postgres update failed")
    app_pg.mirror_user_queue_add(driver_uid, order_id)
    queue_size = len(app_pg.get_user_queue(driver_uid)) or (len(queue) + 1)

    def _fs():
        import utils
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayUnion

        utils.init_firebase_client()
        db = firestore.client()
        order_ref = db.collection("order").document(order_id)
        driver_ref = db.collection("users").document(driver_uid)
        order_ref.update(
            {
                "status": "spec_set",
                "selected_driver": driver_ref,
                "date_upd": now,
            }
        )
        driver_ref.update({"active_orders_queue": ArrayUnion([order_ref])})

    app_fs_mirror.soft_fs("extra_accept", _fs)
    return {
        "order_id": order_id,
        "queue_size": queue_size,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def dequeue_order(driver_uid: str, order_id: str, *, advance: bool = True) -> dict[str, Any]:
    """Водитель убирает заказ из очереди; опционально назначает следующий newOrder."""
    if not driver_uid or not order_id:
        raise ValueError("driver and order required")

    if not app_pg.mirror_user_queue_remove(driver_uid, order_id):
        raise RuntimeError("queue remove failed")

    def _fs_rm():
        import utils
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayRemove

        utils.init_firebase_client()
        db = firestore.client()
        order_ref = db.collection("order").document(order_id)
        db.collection("users").document(driver_uid).update(
            {"active_orders_queue": ArrayRemove([order_ref])}
        )

    app_fs_mirror.soft_fs("queue_remove", _fs_rm)

    remaining = app_pg.get_user_queue(driver_uid)
    next_id = None
    if advance and remaining:
        next_id = remaining[0]
        try:
            nxt = _load_order(next_id)
            st = (nxt.get("status") or "").strip()
            if st == "newOrder":
                now = _now()
                fields = {
                    "status": "spec_set",
                    "selected_driver": {"_ref": f"users/{driver_uid}"},
                    "selected_driver_id": driver_uid,
                    "date_upd": now.isoformat(),
                }
                app_pg.mirror_order_fields(next_id, fields)

                def _fs_next():
                    import utils
                    from firebase_admin import firestore

                    utils.init_firebase_client()
                    db = firestore.client()
                    db.collection("order").document(next_id).update(
                        {
                            "status": "spec_set",
                            "selected_driver": db.collection("users").document(
                                driver_uid
                            ),
                            "date_upd": now,
                        }
                    )

                app_fs_mirror.soft_fs("queue_advance_assign", _fs_next)
        except Exception:
            logger.exception("[dequeue] advance next=%s failed", next_id)

    return {
        "order_id": order_id,
        "remaining": remaining,
        "next_order_id": next_id,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def cancel_order_by_customer(customer_uid: str, order_id: str) -> dict[str, Any]:
    if not customer_uid or not order_id:
        raise ValueError("customer and order required")
    order = _load_order(order_id)
    owner = _ref_uid(order.get("user_customer")) or _ref_uid(
        order.get("user_customer_id")
    )
    if owner != customer_uid:
        raise ValueError("only order customer can cancel")
    status = (order.get("status") or "").strip()
    if status in ("completed", "cancelled"):
        return {"order_id": order_id, "status": status, "already": True}

    now = _now()
    if not app_pg.mirror_order_fields(
        order_id, {"status": "cancelled", "date_upd": now.isoformat()}
    ):
        raise RuntimeError("postgres update failed")

    driver_uid = _ref_uid(order.get("selected_driver")) or _ref_uid(
        order.get("selected_driver_id")
    )
    if driver_uid:
        app_pg.mirror_user_queue_remove(driver_uid, order_id)

    def _fs():
        import utils
        from firebase_admin import firestore
        from google.cloud.firestore_v1.transforms import ArrayRemove

        utils.init_firebase_client()
        db = firestore.client()
        db.collection("order").document(order_id).update(
            {"status": "cancelled", "date_upd": now}
        )
        if driver_uid:
            db.collection("users").document(driver_uid).update(
                {
                    "active_orders_queue": ArrayRemove(
                        [db.collection("order").document(order_id)]
                    )
                }
            )

    app_fs_mirror.soft_fs("cancel_order", _fs)
    return {
        "order_id": order_id,
        "status": "cancelled",
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def hide_order(customer_uid: str, order_id: str, *, unhide: bool = False) -> dict[str, Any]:
    if not customer_uid or not order_id:
        raise ValueError("customer and order required")
    order = _load_order(order_id)
    owner = _ref_uid(order.get("user_customer")) or _ref_uid(
        order.get("user_customer_id")
    )
    if owner != customer_uid:
        raise ValueError("only order customer can hide/unhide")

    now = _now()
    if unhide:
        restore = (
            order.get("status_do_hidden")
            or order.get("statusDoHidden")
            or "newOrder"
        )
        fields = {"status": restore, "date_upd": now.isoformat()}
    else:
        prev = (order.get("status") or "newOrder").strip()
        fields = {
            "status_do_hidden": prev,
            "status": "hidden",
            "date_upd": now.isoformat(),
        }

    if not app_pg.mirror_order_fields(order_id, fields):
        raise RuntimeError("postgres update failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        patch = {"date_upd": now, "status": fields["status"]}
        if "status_do_hidden" in fields:
            patch["status_do_hidden"] = fields["status_do_hidden"]
        db.collection("order").document(order_id).update(patch)

    app_fs_mirror.soft_fs("hide_order", _fs)
    return {
        "order_id": order_id,
        "status": fields["status"],
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def ping_order_geo(
    actor_uid: str,
    order_id: str,
    *,
    lat: float,
    lng: float,
    time_left: Any = None,
    km_left: Any = None,
) -> dict[str, Any]:
    """Водитель (selected) пишет live geo на заказ."""
    if not actor_uid or not order_id:
        raise ValueError("uid and order_id required")
    order = _load_order(order_id)
    driver_uid = _ref_uid(order.get("selected_driver")) or _ref_uid(
        order.get("selected_driver_id")
    )
    if driver_uid != actor_uid:
        raise ValueError("only selected driver can update geo")

    fields: dict[str, Any] = {
        "driver_lat": float(lat),
        "driver_lng": float(lng),
        "driverLocation": {"lat": float(lat), "lng": float(lng)},
    }
    if time_left is not None:
        fields["time_left"] = time_left
    if km_left is not None:
        fields["km_left"] = km_left

    if not app_pg.mirror_order_fields(order_id, fields):
        raise RuntimeError("postgres update failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        patch: dict[str, Any] = {
            "driver_location": firestore.GeoPoint(float(lat), float(lng)),
        }
        if time_left is not None:
            patch["time_left"] = time_left
        if km_left is not None:
            patch["km_left"] = km_left
        db.collection("order").document(order_id).update(patch)

    app_fs_mirror.soft_fs("ping_order_geo", _fs)
    return {
        "order_id": order_id,
        "driver_lat": float(lat),
        "driver_lng": float(lng),
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


_PATCH_ALLOWED = {
    "description",
    "budget",
    "dateTime",
    "date_time",
    "supply",
    "movers",
    "pointA",
    "pointB",
    "pointC",
    "time",
    "distance",
    "currentPrice",
    "current_price",
    "time_text",
}


def patch_order_by_customer(
    customer_uid: str, order_id: str, body: dict[str, Any]
) -> dict[str, Any]:
    """Клиент правит свой заказ (edit / цена)."""
    if not customer_uid or not order_id:
        raise ValueError("customer and order required")
    order = _load_order(order_id)
    owner = _ref_uid(order.get("user_customer")) or _ref_uid(
        order.get("user_customer_id")
    )
    if owner != customer_uid:
        raise ValueError("only order customer can patch")

    fields: dict[str, Any] = {}
    for k, v in (body or {}).items():
        if k in _PATCH_ALLOWED:
            fields[k] = v
    if not fields:
        raise ValueError("no allowed fields")

    now = _now()
    fields["date_upd"] = now.isoformat()
    if not app_pg.mirror_order_fields(order_id, fields):
        raise RuntimeError("postgres update failed")

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        patch = dict(fields)
        patch["date_upd"] = now
        # dateTime iso → datetime if string
        if "dateTime" in patch and isinstance(patch["dateTime"], str):
            try:
                patch["dateTime"] = datetime.fromisoformat(
                    patch["dateTime"].replace("Z", "+00:00")
                )
            except Exception:
                pass
        db.collection("order").document(order_id).update(patch)

    app_fs_mirror.soft_fs("patch_order", _fs)
    return {
        "order_id": order_id,
        "fields": list(fields.keys()),
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def order_visible_to(uid: str, order: dict[str, Any]) -> bool:
    cust = _ref_uid(order.get("user_customer")) or _ref_uid(
        order.get("user_customer_id")
    )
    drv = _ref_uid(order.get("selected_driver")) or _ref_uid(
        order.get("selected_driver_id")
    )
    if cust == uid or drv == uid:
        return True
    # лента newOrder — любой водитель может смотреть
    if (order.get("status") or "").strip() == "newOrder":
        return True
    respondents = order.get("user_who_responced") or order.get("userWhoResponced") or []
    if isinstance(respondents, list):
        for r in respondents:
            if _ref_uid(r) == uid:
                return True
    return False
