"""Replace notify_busy_drivers_about_new_orders in orders/api.py."""
from __future__ import annotations

from pathlib import Path

API = Path(__file__).resolve().parents[2] / "server" / "orders" / "api.py"

NEW_FN = '''def notify_busy_drivers_about_new_orders():
    """
    Периодически ищет свежие newOrder и шлёт FCM data-push
    подходящим (по маршруту и тарифу) занятым водителям.

    Запускается в отдельном потоке из app.py. PG-first + soft FS meta.
    """
    import config
    import app_fs_mirror
    from orders.extra_orders import find_busy_drivers_for_order
    from users.api import send_push_to_firebase_users

    api_key = getattr(config.Production, 'GOOGLE_API_KEY', '') or ''
    poll_interval_sec = 30

    def _parse_notified_at(val):
        if val is None:
            return None
        if isinstance(val, datetime):
            if val.tzinfo is None:
                return val.replace(tzinfo=timezone.utc)
            return val
        if isinstance(val, str):
            try:
                dt = datetime.fromisoformat(val.replace("Z", "+00:00"))
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=timezone.utc)
                return dt
            except Exception:
                return None
        if hasattr(val, "to_datetime") and callable(val.to_datetime):
            try:
                return val.to_datetime()
            except Exception:
                return None
        return None

    def _persist_meta(order_id, tick_start, new_notified):
        fields = {"extra_notified_at": tick_start.isoformat()}
        if new_notified is not None:
            fields["extra_notified_drivers"] = new_notified
        try:
            import app_pg

            if app_pg.enabled():
                app_pg.mirror_order_fields(order_id, fields)
        except Exception:
            logger.exception("[extra_notify.persist] PG meta failed order=%s", order_id)

        def _fs():
            db = firestore.client()
            patch = {"extra_notified_at": tick_start}
            if new_notified is not None:
                patch["extra_notified_drivers"] = new_notified
            db.collection("order").document(order_id).update(patch)

        app_fs_mirror.soft_fs("extra_notify_meta", _fs)

    def _list_new_orders():
        try:
            import app_pg

            if app_pg.enabled():
                rows = app_pg.list_orders(status="newOrder", limit=50)
                if rows is not None:
                    return rows
        except Exception:
            logger.exception("[extra_notify.loop] PG list newOrder failed")

        db = firestore.client()
        snaps = list(
            db.collection("order").where("status", "==", "newOrder").limit(50).stream()
        )
        out = []
        for snap in snaps:
            raw = snap.to_dict() or {}
            order = firebase_order_to_json({**raw, "id": snap.id}, is_dict_already=True)
            if order:
                out.append(order)
        return out

    while True:
        try:
            model = settings.get_model()
            cooldown_sec = model.extra_order_notify_cooldown_sec
            tick_start = datetime.now(timezone.utc)
            new_orders = _list_new_orders()
            logger.info(
                f"[extra_notify.loop] tick new_orders_count={len(new_orders)}"
            )

            for order in new_orders:
                order_id = str(order.get("id") or "")
                if not order_id:
                    continue
                if (order.get("status") or "").lower() != "neworder":
                    continue

                last_notified = _parse_notified_at(order.get("extra_notified_at"))
                if last_notified is not None:
                    elapsed = (tick_start - last_notified).total_seconds()
                    if elapsed < cooldown_sec:
                        continue

                notified_uids_raw = order.get("extra_notified_drivers") or []
                notified_uids = [str(u) for u in notified_uids_raw if u]
                logger.info(
                    f"[extra_notify.dedup] order={order_id} already_notified={notified_uids}"
                )

                try:
                    candidates = find_busy_drivers_for_order(order, api_key)
                except Exception as e:
                    logger.error(
                        f"[extra_notify.dispatch] route check failed order={order_id}: {e}\\n"
                        f"{traceback.format_exc()}"
                    )
                    candidates = []

                fresh = [
                    c for c in candidates if str(c.get("driver_uid")) not in notified_uids
                ]
                logger.info(
                    f"[extra_notify.dispatch] order={order_id} "
                    f"candidates={[c.get('driver_uid') for c in candidates]} "
                    f"fresh={[c.get('driver_uid') for c in fresh]}"
                )

                if not fresh:
                    _persist_meta(order_id, tick_start, None)
                    continue

                target = fresh[0]
                target_uid = target["driver_uid"]
                data = {
                    "type": "additional_order",
                    "order_id": order_id,
                    "current_order_id": target.get("current_order_id") or "",
                    "delta_min": str(target.get("delta_min", "")),
                    "delta_km": str(target.get("delta_km", "")),
                }

                try:
                    send_push_to_firebase_users(
                        user_ids=[target_uid],
                        title="Дополнительный заказ",
                        text="Заказ по пути",
                        data=data,
                    )
                    logger.info(
                        f"[extra_notify.dispatch] FCM sent order={order_id} "
                        f"driver={target_uid} delta_min={target.get('delta_min')}"
                    )
                except Exception as e:
                    logger.error(
                        f"[extra_notify.dispatch] FCM failed order={order_id} "
                        f"driver={target_uid}: {e}\\n{traceback.format_exc()}"
                    )

                new_notified = list(dict.fromkeys(notified_uids + [str(target_uid)]))
                try:
                    _persist_meta(order_id, tick_start, new_notified)
                    logger.info(
                        f"[extra_notify.persist] order={order_id} "
                        f"extra_notified_drivers <- {new_notified}"
                    )
                except Exception as e:
                    logger.error(
                        f"[extra_notify.dispatch] failed to update order meta {order_id}: {e}\\n"
                        f"{traceback.format_exc()}"
                    )
        except Exception as e:
            logger.error(
                f"[extra_notify.loop] uncaught: {e}\\n{traceback.format_exc()}"
            )
        time.sleep(poll_interval_sec)
'''


def main() -> int:
    text = API.read_text(encoding="utf-8")
    start = text.index("def notify_busy_drivers_about_new_orders():")
    # Fix accidental double-escaped newlines from template
    body = NEW_FN.replace("\\\\n", "\\n")
    API.write_text(text[:start] + body, encoding="utf-8")
    print("patched", API, "from", start)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
