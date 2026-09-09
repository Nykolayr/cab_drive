"""Обработка Notification URL от T‑Банка → Postgres SoT (+ FS mirror)."""

from __future__ import annotations

import traceback
from typing import Any

from firebase_admin import firestore

import tinkoff.client as tinkoff_client
import tinkoff.events_log as events_log
import utils
from logger import logger


SUCCESS_STATUSES = {"CONFIRMED", "AUTHORIZED"}
FAIL_STATUSES = {"REJECTED", "CANCELED", "DEADLINE_EXPIRED", "AUTH_FAIL", "REVERSED"}


def _verify_notification_token(data: dict[str, Any]) -> bool:
    incoming = str(data.get("Token") or "")
    payload = {k: v for k, v in data.items() if k != "Token"}
    return tinkoff_client.token_matches(payload, incoming)


def _uid(val: Any) -> str | None:
    if val is None:
        return None
    if hasattr(val, "id"):
        return str(val.id)
    if isinstance(val, str):
        return val.rsplit("/", 1)[-1] if "/" in val else val
    if isinstance(val, dict) and "_ref" in val:
        return str(val["_ref"]).rsplit("/", 1)[-1]
    return str(val) if val else None


def _find_pay_orders_pg(payment_id: str) -> list[dict]:
    import app_pg

    rows = app_pg.find_pay_orders_by_payment_id(str(payment_id))
    if rows:
        return rows
    # fallback FS → upsert в PG
    try:
        client = utils.init_firebase_client()
        docs = list(
            client.collection("pay_order")
            .where("paymentId", "==", payment_id)
            .limit(5)
            .stream()
        )
        if not docs:
            try:
                docs = list(
                    client.collection("pay_order")
                    .where("paymentId", "==", int(payment_id))
                    .limit(5)
                    .stream()
                )
            except Exception:
                docs = []
        out = []
        for doc in docs:
            body = doc.to_dict() or {}
            body["id"] = doc.id
            app_pg.upsert_pay_order(doc.id, body)
            out.append(app_pg.get_pay_order(doc.id) or body)
        return out
    except Exception:
        logger.exception("[tinkoff.webhook] FS fallback find fail")
        return []


def _mirror_pay_fs(pay_id: str, patch: dict[str, Any]):
    import app_fs_mirror

    def _run():
        client = utils.init_firebase_client()
        client.collection("pay_order").document(pay_id).set(patch, merge=True)

    app_fs_mirror.soft_fs("pay_order_patch", _run)


def _mark_failed_pg(data: dict[str, Any], payment_id: str) -> list:
    import app_pg

    rows = _find_pay_orders_pg(payment_id)
    if not rows:
        logger.error(
            f"[tinkoff.webhook] fail: pay_order not found paymentId={payment_id}"
        )
        return []
    results = []
    patch = {
        "tinkoff_status": str(data.get("Status") or ""),
        "tinkoff_error_code": str(data.get("ErrorCode") or ""),
        "tinkoff_message": str(data.get("Message") or data.get("Details") or "")[:500],
        "is_paid": False,
        "paymentId": payment_id,
    }
    for row in rows:
        pid = row.get("id")
        if row.get("is_paid") is True:
            results.append({"id": pid, "skipped": "already_paid"})
            continue
        app_pg.upsert_pay_order(pid, {**row, **patch})
        _mirror_pay_fs(pid, patch)
        results.append({"id": pid, "failed": True, **patch})
    return results


def process_notification(data: dict[str, Any]) -> dict[str, Any]:
    if not _verify_notification_token(data):
        logger.error(
            "[tinkoff.webhook] bad Token "
            f"status={data.get('Status')} paymentId={data.get('PaymentId')} "
            f"terminal={data.get('TerminalKey')}"
        )
        return {"ok": False, "error": "bad token"}

    status = str(data.get("Status") or "")
    payment_id = data.get("PaymentId")
    if payment_id is not None:
        payment_id = str(payment_id)

    if not payment_id:
        return {"ok": False, "error": "no PaymentId"}

    if status not in SUCCESS_STATUSES:
        logger.warning(
            "[tinkoff.webhook] NON_SUCCESS Status=%s PaymentId=%s OrderId=%s "
            "Amount=%s ErrorCode=%s Message=%s Details=%s Success=%s Pan=%s",
            status,
            payment_id,
            data.get("OrderId"),
            data.get("Amount"),
            data.get("ErrorCode"),
            data.get("Message"),
            data.get("Details"),
            data.get("Success"),
            data.get("Pan"),
        )
        written = _mark_failed_pg(data, payment_id)
        events_log.append_event(
            "webhook_reject",
            level="warn",
            message="notification non-success",
            order_id=str(data.get("OrderId") or ""),
            payment_id=payment_id,
            amount=data.get("Amount"),
            error_code=str(data.get("ErrorCode") or ""),
            status=status,
            extra={"written": len(written)},
        )
        return {"ok": True, "ignored": True, "status": status, "written": written}

    rows = _find_pay_orders_pg(payment_id)
    if not rows:
        logger.error(f"[tinkoff.webhook] pay_order not found paymentId={payment_id}")
        return {"ok": False, "error": "pay_order not found"}

    results = []
    for row in rows:
        results.append(_apply_paid_pg(row, data))
    return {"ok": True, "results": results}


def _apply_paid_pg(body: dict[str, Any], data: dict[str, Any]) -> dict[str, Any]:
    import app_fs_mirror
    import app_pg

    pay_id = body.get("id")
    if not pay_id:
        return {"error": "no id"}

    if body.get("is_paid") is True:
        return {"id": pay_id, "skipped": "already_paid"}

    amount_cop = body.get("amount_in_cop") or 0
    try:
        amount_cop = int(amount_cop)
    except (TypeError, ValueError):
        amount_cop = 0
    amount_rub = amount_cop / 100.0

    summ = body.get("summ_upd_ballance") or body.get("summ_upd_balance")
    if summ is not None:
        try:
            amount_rub = float(summ)
        except (TypeError, ValueError):
            pass

    tinkoff_status = str(data.get("Status") or "")
    app_pg.mirror_pay_order_paid(
        pay_id,
        is_paid=True,
        tinkoff_status=tinkoff_status,
        payment_id=str(data.get("PaymentId") or body.get("paymentId") or "") or None,
    )
    app_pg.upsert_pay_order(
        pay_id,
        {
            **body,
            "is_paid": True,
            "tinkoff_status": tinkoff_status,
            "paymentId": str(data.get("PaymentId") or ""),
        },
    )
    _mirror_pay_fs(
        pay_id,
        {
            "is_paid": True,
            "tinkoff_status": tinkoff_status,
            "tinkoff_paid_at": firestore.SERVER_TIMESTAMP,
        },
    )

    credited = []
    list_users = body.get("list_users_upd_ballance") or body.get("list_users_upd_balance") or []
    user_uid = _uid(body.get("user") or body.get("user_id"))
    has_order = bool(body.get("current_order_doc_ref") or body.get("current_order_id"))

    try:
        if list_users and amount_rub > 0:
            for uref in list_users:
                uid = _uid(uref)
                if not uid:
                    continue
                app_pg.increment_user_balance(uid, float(amount_rub))
                credited.append(uid)

                def _fs_bal(u=uid, a=amount_rub):
                    client = utils.init_firebase_client()
                    client.collection("users").document(u).update(
                        {"balance": firestore.Increment(a)}
                    )

                app_fs_mirror.soft_fs("balance_incr", _fs_bal)
        elif user_uid and amount_rub > 0 and not has_order:
            app_pg.increment_user_balance(user_uid, float(amount_rub))
            credited.append(user_uid)

            def _fs_bal2(u=user_uid, a=amount_rub):
                client = utils.init_firebase_client()
                client.collection("users").document(u).update(
                    {"balance": firestore.Increment(a)}
                )

            app_fs_mirror.soft_fs("balance_incr", _fs_bal2)
    except Exception:
        logger.error(f"[tinkoff.webhook] balance credit fail\n{traceback.format_exc()}")

    oid = _uid(body.get("current_order_doc_ref") or body.get("current_order_id"))
    if oid:
        try:
            app_pg.mirror_order_paid(oid, True)

            def _fs_ord(o=oid):
                client = utils.init_firebase_client()
                client.collection("order").document(o).update({"is_paid": True})

            app_fs_mirror.soft_fs("order_paid", _fs_ord)
        except Exception:
            logger.error(f"[tinkoff.webhook] order is_paid fail\n{traceback.format_exc()}")

        # Card: после оплаты — accept-bid (spec_set + queue), если ещё newOrder
        driver_uid = _uid(body.get("driver") or body.get("driver_id"))
        customer_uid = user_uid or _uid(body.get("user") or body.get("user_id"))
        if driver_uid and customer_uid:
            try:
                import app_order_ops

                order = app_pg.get_order(oid) or {}
                st = (order.get("status") or "").strip()
                if st == "newOrder":
                    bid_price = body.get("bid_price") or body.get("bidPrice")
                    if bid_price is None and amount_cop:
                        bid_price = int(amount_cop / 100)
                    else:
                        try:
                            bid_price = int(bid_price) if bid_price is not None else None
                        except (TypeError, ValueError):
                            bid_price = int(amount_cop / 100) if amount_cop else None
                    commission = (
                        body.get("commission_percent")
                        or body.get("commissionPercent")
                    )
                    app_order_ops.accept_bid(
                        customer_uid,
                        oid,
                        driver_uid,
                        price=bid_price,
                        commission_percent=commission,
                    )
            except Exception:
                logger.error(
                    f"[tinkoff.webhook] accept_bid after pay fail\n{traceback.format_exc()}"
                )

    logger.info(
        f"[tinkoff.webhook] paid pay_order={pay_id} amount={amount_rub} credited={credited}"
    )
    events_log.append_event(
        "webhook_paid",
        level="info",
        message=f"paid pay_order={pay_id}",
        order_id=str(data.get("OrderId") or body.get("order_id") or ""),
        payment_id=str(data.get("PaymentId") or body.get("paymentId") or ""),
        amount=data.get("Amount") or body.get("amount_in_cop"),
        status=str(data.get("Status") or ""),
        extra={"credited": ",".join(credited) if credited else "", "sot": "postgres"},
    )
    return {
        "id": pay_id,
        "paid": True,
        "amount_rub": amount_rub,
        "credited": credited,
        "sot": "postgres",
    }
