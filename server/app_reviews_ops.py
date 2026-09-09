"""Отзывы: Postgres SoT + опциональное FS-зеркало."""
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


def create_review(author_uid: str, body: dict[str, Any]) -> dict[str, Any]:
    if not author_uid:
        raise ValueError("author required")
    reviewed = (
        body.get("reviewed_user_id")
        or body.get("user_who_was_reviewed")
        or ""
    )
    if isinstance(reviewed, dict) and reviewed.get("_ref"):
        reviewed = str(reviewed["_ref"]).rsplit("/", 1)[-1]
    reviewed = str(reviewed).strip()
    if not reviewed:
        raise ValueError("reviewed_user_id required")

    rating = body.get("rating")
    try:
        rating_i = int(rating)
    except (TypeError, ValueError):
        raise ValueError("rating required")
    if rating_i < 1 or rating_i > 5:
        raise ValueError("rating must be 1..5")

    text = (body.get("text") or "").strip()
    if not text:
        raise ValueError("text required")

    order_id = body.get("order_id") or body.get("order") or ""
    if isinstance(order_id, dict) and order_id.get("_ref"):
        order_id = str(order_id["_ref"]).rsplit("/", 1)[-1]
    order_id = str(order_id).strip() or None

    as_driver = bool(body.get("as_driver") or body.get("author_is_driver"))
    name_author = (body.get("name_author") or body.get("name_user_who_wrote") or "").strip()

    review_id = str(body.get("id") or uuid.uuid4().hex)
    now = _now()
    raw = {
        "id": review_id,
        "user_who_was_reviewed": {"_ref": f"users/{reviewed}"},
        "user_who_wrote_the_review": {"_ref": f"users/{author_uid}"},
        "reviewed_user_id": reviewed,
        "author_user_id": author_uid,
        "text": text,
        "rating": rating_i,
        "name_user_who_wrote": name_author,
        "date": now.isoformat(),
        "order_id": order_id,
    }

    if not app_pg.create_review(review_id, raw, reviewed_uid=reviewed, author_uid=author_uid):
        raise RuntimeError("postgres review insert failed")

    app_pg.apply_review_side_effects(
        reviewed_uid=reviewed,
        rating=rating_i,
        order_id=order_id,
        author_is_driver=as_driver,
    )

    def _fs():
        import utils
        from firebase_admin import firestore

        utils.init_firebase_client()
        db = firestore.client()
        reviewed_ref = db.collection("users").document(reviewed)
        author_ref = db.collection("users").document(author_uid)
        db.collection("reviews").document(review_id).set(
            {
                "user_who_was_reviewed": reviewed_ref,
                "user_who_wrote_the_review": author_ref,
                "text": text,
                "rating": rating_i,
                "date": now,
                "name_user_who_wrote": name_author,
            }
        )
        # синхронизируем агрегат с PG (не Increment — иначе двойной счёт)
        pub = app_pg.get_public_user(reviewed) or {}
        reviewed_ref.set(
            {
                "average_rating": pub.get("average_rating") or 0,
                "number_of_reviews": pub.get("number_of_reviews") or 0,
            },
            merge=True,
        )
        if order_id:
            patch = (
                {"customer_reviewed": True}
                if as_driver
                else {"driver_reviewed": True}
            )
            db.collection("order").document(order_id).update(patch)

    app_fs_mirror.soft_fs("create_review", _fs)
    return {
        "review_id": review_id,
        "reviewed_user_id": reviewed,
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
    }


def list_reviews_about(user_id: str, *, limit: int = 100) -> list[dict[str, Any]]:
    return app_pg.list_reviews(reviewed_user_id=user_id, limit=limit)


def list_reviews_by_author(user_id: str, *, limit: int = 100) -> list[dict[str, Any]]:
    return app_pg.list_reviews(author_user_id=user_id, limit=limit)
