"""Вывод средств: Jump Finance + списание баланса в Postgres (без Firestore).

Схема:
- при create Jump списываем balance → balance_payout_pending («на одобрении»);
- при оплате Jump (status=1) снимаем pending;
- при reject/cancel Jump возвращаем на balance и снимаем pending.
Обратная связь: polling Jump (webhook в OpenAPI нет) + sync при выводе / фоне.
"""
from __future__ import annotations

import logging
import uuid
from typing import Any

import requests

import app_finance_log
import app_pg
import config

logger = logging.getLogger(__name__)

# Jump: 1=оплачена; 3=в обработке; 4=ожидает оплаты; 7=ожидает подтверждения; 8=акт.
_JUMP_PENDING_STATUS_IDS = frozenset({3, 4, 7, 8})
_JUMP_PAID_STATUS_ID = 1
_JUMP_CANCEL_STATUS_IDS = frozenset({2, 5, 6})  # отклонён / ошибка / удалено


def _num(val: Any, default: float = 0.0) -> float:
    try:
        return float(val)
    except (TypeError, ValueError):
        return default


def payout_commission(balance: float) -> float:
    """Как в МП: proc(balance)=max(3%, 50) плюс фиксированные +50 в UI."""
    bal = max(0.0, float(balance))
    percent = bal * 0.03
    proc = 50.0 if percent < 50.0 else percent
    return float(proc + 50.0)


def amount_to_card(balance: float) -> float:
    """Ожидаемо на карту/РС после комиссий Jump (= UI «Вы получите на карту»).

    В Jump create уходит полный balance; Jump режет свои комиссии с этой суммы.
    """
    bal = max(0.0, float(balance))
    amt = bal - payout_commission(bal)
    return max(0.0, round(amt, 2))


def _jump_client_key() -> str:
    return (
        getattr(config.Production, "JUMP_CLIENT_KEY", None)
        or "12b46b45-f258-4e3c-9509-9dc7280cdeed"
    )


def _jump_headers() -> dict[str, str]:
    return {
        "Content-Type": "application/json",
        "Client-Key": _jump_client_key(),
    }


def _jump_payment_item(payload: dict[str, Any]) -> dict[str, Any]:
    item = payload.get("item")
    return item if isinstance(item, dict) else {}


def _jump_payment_status(item: dict[str, Any]) -> tuple[int, str, bool]:
    st = item.get("status") or {}
    if not isinstance(st, dict):
        return 0, "", bool(item.get("is_final"))
    try:
        sid = int(st.get("id") or 0)
    except (TypeError, ValueError):
        sid = 0
    title = str(st.get("title") or "").strip()
    return sid, title, bool(item.get("is_final"))


def _jump_payout_settled(item: dict[str, Any]) -> bool:
    if not item:
        return False
    sid, _, _ = _jump_payment_status(item)
    return sid == _JUMP_PAID_STATUS_ID


def _jump_payout_cancelled(item: dict[str, Any]) -> bool:
    if not item:
        return False
    if item.get("canceled_at") or item.get("cancelled_at"):
        return True
    sid, title, is_final = _jump_payment_status(item)
    if sid in _JUMP_CANCEL_STATUS_IDS:
        return True
    if sid in _JUMP_PENDING_STATUS_IDS or sid == _JUMP_PAID_STATUS_ID:
        return False
    t = title.lower()
    if any(
        x in t
        for x in (
            "отмен",
            "cancel",
            "отклон",
            "reject",
            "ошиб",
            "error",
            "fail",
            "аннул",
            "удал",
        )
    ):
        return True
    return bool(is_final and sid != _JUMP_PAID_STATUS_ID)


def _jump_fetch_payment(payment_id: int) -> dict[str, Any]:
    url = (
        "https://api.jump.finance/services/openapi/payments/"
        f"{payment_id}?include=abilities"
    )
    try:
        resp = requests.get(url, headers=_jump_headers(), timeout=30)
        payload = resp.json() if resp.content else {}
    except Exception as e:
        logger.warning("[payout] jump get payment %s failed: %s", payment_id, e)
        return {}
    if resp.status_code >= 400 or not isinstance(payload, dict):
        return {}
    return _jump_payment_item(payload)


def _jump_try_confirm(payment_ids: list[int]) -> bool:
    ids = [int(x) for x in payment_ids if x]
    if not ids:
        return False
    url = "https://api.jump.finance/services/openapi/payments/confirm"
    body = {"payment_id": ",".join(str(i) for i in ids)}
    try:
        resp = requests.post(url, json=body, headers=_jump_headers(), timeout=45)
        payload = resp.json() if resp.content else {}
    except requests.RequestException as e:
        logger.warning("[payout] jump confirm request failed: %s", e)
        return False
    if resp.status_code == 404:
        logger.warning(
            "[payout] jump confirm route missing (OpenAPI manual confirm mode?)"
        )
        return False
    if resp.status_code >= 400:
        logger.warning(
            "[payout] jump confirm status=%s body=%s",
            resp.status_code,
            payload if isinstance(payload, dict) else resp.text[:200],
        )
        return False
    logger.info("[payout] jump confirm ok ids=%s resp=%s", ids, payload)
    return True


def _jump_error_message(payload: Any) -> str:
    if not isinstance(payload, dict):
        return "Ошибка вывода"
    err = payload.get("error") or {}
    if not isinstance(err, dict):
        return str(payload.get("message") or "Ошибка вывода")
    detail = (err.get("detail") or err.get("title") or "").strip()
    fields = err.get("fields") or []
    msgs: list[str] = []
    if isinstance(fields, list):
        for f in fields:
            if isinstance(f, dict):
                for m in f.get("messages") or []:
                    if m:
                        msgs.append(str(m))
    if msgs:
        return "; ".join(msgs)
    return detail or "Ошибка вывода"


def _pending_amount(me: dict[str, Any]) -> float:
    return max(0.0, _num(me.get("balance_payout_pending")))


def _apply_debit_to_pending(uid: str, *, balance: float, contractor_id: int = 0) -> float:
    me = app_pg.get_me(uid) or {}
    pending_after = round(_pending_amount(me) + balance, 2)
    fields: dict[str, Any] = {
        "balance": 0,
        "balance_payout_pending": pending_after,
    }
    if contractor_id > 0:
        fields["contractor_id"] = contractor_id
    if not app_pg.mirror_user_fields(uid, fields):
        raise RuntimeError(
            "Выплата в Jump создана, но баланс в БД не обновился — обратитесь в поддержку"
        )
    return pending_after


def _clear_pending_amount(uid: str, amount: float) -> float:
    me = app_pg.get_me(uid) or {}
    pending_before = _pending_amount(me)
    pending_after = max(0.0, round(pending_before - max(0.0, amount), 2))
    if abs(pending_after - pending_before) < 1e-9:
        return pending_before
    app_pg.mirror_user_fields(uid, {"balance_payout_pending": pending_after})
    return pending_after


def _pending_user_hint(status_title: str = "") -> str:
    hint = status_title or "ожидает подтверждения в Jump"
    return (
        f"Заявка создана ({hint}). С баланса списано — сумма на одобрении вывода. "
        "После оплаты пометка исчезнет; при отказе деньги вернутся на баланс."
    )


def _mark_payout_settled(row: dict[str, Any], *, sid: int, title: str, item: dict) -> None:
    uid = str(row.get("user_id") or "")
    payout_id = str(row.get("id") or "")
    debited = _num(row.get("balance_debited"))
    if not uid or not payout_id:
        return
    pending_after = _clear_pending_amount(uid, debited)
    app_pg.update_payout(
        payout_id,
        status="settled",
        jump_status_id=sid,
        jump_status_title=title,
        raw_json=item or None,
    )
    app_finance_log.log_payout(
        phase="synced_settled",
        uid=uid,
        payout_id=payout_id,
        jump_payment_id=row.get("jump_payment_id"),
        jump_status_id=sid,
        jump_status_title=title,
        balance_debited=debited,
        balance_payout_pending=pending_after,
    )


def _refund_payout(row: dict[str, Any], *, sid: int, title: str, item: dict) -> None:
    uid = str(row.get("user_id") or "")
    payout_id = str(row.get("id") or "")
    debited = _num(row.get("balance_debited"))
    if not uid or not payout_id:
        return
    me = app_pg.get_me(uid) or {}
    before = _num(me.get("balance"))
    pending_before = _pending_amount(me)
    after = before
    pending_after = pending_before
    if debited > 0:
        after = round(before + debited, 2)
        pending_after = max(0.0, round(pending_before - debited, 2))
        if not app_pg.mirror_user_fields(
            uid,
            {"balance": after, "balance_payout_pending": pending_after},
        ):
            app_finance_log.log_payout(
                phase="refund_failed",
                uid=uid,
                payout_id=payout_id,
                jump_payment_id=row.get("jump_payment_id"),
                balance_before=before,
                balance_debited=debited,
            )
            logger.error(
                "[payout] refund failed uid=%s payout=%s debited=%s",
                uid,
                payout_id,
                debited,
            )
            return
        app_finance_log.log_balance(
            reason="payout_jump_refund",
            uid=uid,
            balance_before=before,
            balance_after=after,
            delta=debited,
            payout_id=payout_id,
            jump_payment_id=row.get("jump_payment_id"),
            balance_payout_pending=pending_after,
        )
    app_pg.update_payout(
        payout_id,
        status="cancelled",
        jump_status_id=sid,
        jump_status_title=title,
        raw_json=item or None,
    )
    app_finance_log.log_payout(
        phase="cancelled_refunded",
        uid=uid,
        payout_id=payout_id,
        jump_payment_id=row.get("jump_payment_id"),
        jump_status_id=sid,
        jump_status_title=title,
        balance_before=before,
        balance_after=after,
        refunded=debited,
        balance_payout_pending=pending_after,
    )


def sync_user_payouts(uid: str) -> dict[str, Any]:
    """Сверяет pending-выводы с Jump: settled / cancel+refund."""
    out = {"checked": 0, "settled": 0, "cancelled": 0, "still_pending": 0}
    if not uid:
        return out
    rows = app_pg.list_payouts(user_id=uid, status="pending", limit=20)
    for row in rows:
        out["checked"] += 1
        jid = row.get("jump_payment_id")
        try:
            jid_int = int(jid) if jid else 0
        except (TypeError, ValueError):
            jid_int = 0
        if jid_int <= 0:
            out["still_pending"] += 1
            continue
        item = _jump_fetch_payment(jid_int)
        if not item:
            out["still_pending"] += 1
            continue
        sid, title, _ = _jump_payment_status(item)
        if _jump_payout_settled(item):
            _mark_payout_settled(row, sid=sid, title=title, item=item)
            out["settled"] += 1
            continue
        if _jump_payout_cancelled(item):
            _refund_payout(row, sid=sid, title=title, item=item)
            out["cancelled"] += 1
            continue
        abilities = item.get("abilities") if isinstance(item.get("abilities"), dict) else {}
        if abilities.get("can_confirm"):
            if _jump_try_confirm([jid_int]):
                refreshed = _jump_fetch_payment(jid_int)
                if refreshed and _jump_payout_settled(refreshed):
                    sid2, title2, _ = _jump_payment_status(refreshed)
                    _mark_payout_settled(row, sid=sid2, title=title2, item=refreshed)
                    out["settled"] += 1
                    continue
                if refreshed and _jump_payout_cancelled(refreshed):
                    sid2, title2, _ = _jump_payment_status(refreshed)
                    _refund_payout(row, sid=sid2, title=title2, item=refreshed)
                    out["cancelled"] += 1
                    continue
        app_pg.update_payout(
            str(row["id"]),
            jump_status_id=sid,
            jump_status_title=title,
            raw_json=item,
        )
        out["still_pending"] += 1
    return out


def sync_all_pending_payouts(*, limit: int = 40) -> dict[str, Any]:
    """Фоновый sync всех pending (Jump docs: polling ≤1/мин)."""
    out = {"users": 0, "settled": 0, "cancelled": 0, "still_pending": 0}
    uids = app_pg.list_pending_payout_user_ids(limit=limit)
    for uid in uids:
        out["users"] += 1
        try:
            part = sync_user_payouts(uid)
        except Exception:
            logger.exception("[payout] sync_all failed uid=%s", uid)
            continue
        out["settled"] += int(part.get("settled") or 0)
        out["cancelled"] += int(part.get("cancelled") or 0)
        out["still_pending"] += int(part.get("still_pending") or 0)
    if out["users"]:
        logger.info("[payout] sync_all %s", out)
    return out


def create_payout(
    uid: str,
    *,
    pan: str,
    phone: str = "",
    first_name: str = "",
    last_name: str = "",
) -> dict[str, Any]:
    if not uid:
        raise ValueError("uid required")
    pan = "".join(ch for ch in str(pan or "") if ch.isdigit())
    if len(pan) < 16:
        raise ValueError("Укажите карту для вывода")

    sync_info = sync_user_payouts(uid)

    open_row = app_pg.get_open_payout(uid)
    me0 = app_pg.get_me(uid) or {}
    if open_row or _pending_amount(me0) > 0:
        app_finance_log.log_payout(
            phase="reject_pending_open",
            uid=uid,
            payout_id=(open_row or {}).get("id"),
            jump_payment_id=(open_row or {}).get("jump_payment_id"),
            balance_payout_pending=_pending_amount(me0),
            sync=sync_info,
        )
        raise ValueError(
            "У вас уже есть сумма на одобрении вывода. "
            "Повторный вывод недоступен, пока заявка не будет оплачена или отклонена."
        )

    me = app_pg.get_me(uid)
    if not me:
        raise ValueError("Пользователь не найден")
    balance = _num(me.get("balance"))
    app_finance_log.log_payout(
        phase="start",
        uid=uid,
        balance=balance,
        pan_tail=pan[-4:] if len(pan) >= 4 else pan,
        phone=(phone or me.get("phone_number") or "")[-4:],
        sync=sync_info,
    )
    if balance < 200:
        app_finance_log.log_payout(phase="reject_min_amount", uid=uid, balance=balance)
        raise ValueError("Минимальная сумма вывода — 200 ₽")

    amount = amount_to_card(balance)
    commission = payout_commission(balance)
    # В Jump — полная сумма списания с баланса. Jump сам режет commission+bank.
    # Раньше слали amount_to_card → двойное обрезание (200→Jump100→РС50 вместо ~100).
    jump_amount = round(balance, 2)
    expected_on_card = amount
    if expected_on_card <= 0:
        app_finance_log.log_payout(
            phase="reject_zero_amount",
            uid=uid,
            balance=balance,
            commission=commission,
        )
        raise ValueError("После комиссии сумма к выводу равна нулю")

    contractor_id = me.get("contractor_id")
    try:
        contractor_id_int = int(contractor_id) if contractor_id else 0
    except (TypeError, ValueError):
        contractor_id_int = 0

    phone = (phone or me.get("phone_number") or "").strip()
    first_name = (first_name or me.get("display_name") or "").strip()
    last_name = (last_name or me.get("surname") or "").strip()
    customer_payment_id = f"{uid}-{uuid.uuid4().hex[:12]}"

    if contractor_id_int > 0:
        url = "https://api.jump.finance/services/openapi/payments"
        body = {
            "requisite": {"type_id": 8, "account_number": pan},
            "contractor_id": contractor_id_int,
            "amount": jump_amount,
        }
    else:
        url = "https://api.jump.finance/services/openapi/payments/smart"
        body = {
            "customer_payment_id": customer_payment_id,
            "phone": phone,
            "last_name": last_name or "Driver",
            "first_name": first_name or "Cab",
            "requisite": {"type_id": 8, "account_number": pan},
            "amount": jump_amount,
        }

    try:
        resp = requests.post(url, json=body, headers=_jump_headers(), timeout=45)
    except requests.RequestException as e:
        logger.exception("[payout] jump request failed uid=%s", uid)
        raise RuntimeError(f"Сервис вывода недоступен: {e}") from e

    try:
        payload = resp.json()
    except Exception:
        payload = {"raw": (resp.text or "")[:500]}

    logger.info(
        "[payout] jump status=%s uid=%s jump_amount=%s expected_on_card=%s contractor=%s body_keys=%s",
        resp.status_code,
        uid,
        jump_amount,
        expected_on_card,
        contractor_id_int,
        list(payload.keys()) if isinstance(payload, dict) else type(payload),
    )
    app_finance_log.log_payout(
        phase="jump_http",
        uid=uid,
        http_status=resp.status_code,
        amount_to_card=expected_on_card,
        jump_amount=jump_amount,
        commission=commission,
        balance_before=balance,
        contractor_id=contractor_id_int,
        smart=contractor_id_int <= 0,
    )

    if resp.status_code >= 400 or (
        isinstance(payload, dict) and payload.get("error")
    ):
        app_finance_log.log_payout(
            phase="jump_error",
            uid=uid,
            http_status=resp.status_code,
            error=_jump_error_message(payload),
        )
        raise ValueError(_jump_error_message(payload))

    item: dict[str, Any] = {}
    if isinstance(payload, dict):
        item = _jump_payment_item(payload)

    new_contractor = contractor_id_int
    if item:
        c = (item.get("contractor") or {}).get("id")
        if c:
            try:
                new_contractor = int(c)
            except (TypeError, ValueError):
                pass

    sid, st_title, _is_final = _jump_payment_status(item)
    jump_payment_id = item.get("id")
    try:
        jump_payment_id_int = int(jump_payment_id) if jump_payment_id else 0
    except (TypeError, ValueError):
        jump_payment_id_int = 0

    if new_contractor > 0 and new_contractor != contractor_id_int:
        app_pg.mirror_user_fields(uid, {"contractor_id": new_contractor})

    if jump_payment_id_int <= 0:
        app_finance_log.log_payout(
            phase="jump_no_payment_id",
            uid=uid,
            amount_to_card=expected_on_card,
            jump_amount=jump_amount,
            balance_before=balance,
        )
        raise RuntimeError(
            "Jump не вернул id выплаты — баланс не списан, попробуйте позже"
        )

    if not _jump_payout_settled(item):
        abilities = item.get("abilities") if isinstance(item.get("abilities"), dict) else {}
        if abilities.get("can_confirm"):
            _jump_try_confirm([jump_payment_id_int])
            refreshed = _jump_fetch_payment(jump_payment_id_int)
            if refreshed:
                item = refreshed
                sid, st_title, _is_final = _jump_payment_status(item)

    if _jump_payout_cancelled(item):
        app_finance_log.log_payout(
            phase="jump_cancelled_no_debit",
            uid=uid,
            jump_payment_id=jump_payment_id_int,
            jump_status_id=sid,
            jump_status_title=st_title,
        )
        raise ValueError(
            f"Выплата в Jump отклонена ({st_title or 'отмена'}). Баланс не списан."
        )

    settled = _jump_payout_settled(item)
    payout_status = "settled" if settled else "pending"
    payout_id = f"po_{uuid.uuid4().hex[:16]}"
    # В записи — ожидание UI; если Jump уже отдал amount_paid — фиксируем факт.
    on_card = expected_on_card
    if item.get("amount_paid") is not None:
        try:
            on_card = float(item.get("amount_paid"))
        except (TypeError, ValueError):
            on_card = expected_on_card

    try:
        pending_after = _apply_debit_to_pending(
            uid, balance=balance, contractor_id=new_contractor
        )
    except RuntimeError:
        app_finance_log.log_payout(
            phase="debit_failed",
            uid=uid,
            jump_payment_id=jump_payment_id_int,
            jump_status_id=sid,
            amount_to_card=on_card,
            jump_amount=jump_amount,
            balance_before=balance,
        )
        raise

    # Если Jump сразу оплатил — pending не оставляем.
    if settled:
        pending_after = _clear_pending_amount(uid, balance)

    saved = app_pg.create_payout(
        payout_id=payout_id,
        user_id=uid,
        jump_payment_id=jump_payment_id_int,
        amount_to_card=on_card,
        commission=commission,
        balance_before=balance,
        balance_debited=balance,
        status=payout_status,
        jump_status_id=sid,
        jump_status_title=st_title,
        pan_tail=pan[-4:] if len(pan) >= 4 else pan,
        raw_json=item if item else (payload if isinstance(payload, dict) else None),
    )
    if not saved:
        logger.error(
            "[payout] create_payout row failed after debit uid=%s jump=%s",
            uid,
            jump_payment_id_int,
        )

    phase = "settled_debited" if settled else "pending_debited"
    app_finance_log.log_payout(
        phase=phase,
        uid=uid,
        payout_id=payout_id,
        jump_payment_id=jump_payment_id_int,
        jump_status_id=sid,
        jump_status_title=st_title,
        amount_to_card=on_card,
        jump_amount=jump_amount,
        commission=commission,
        balance_before=balance,
        balance_after=0,
        balance_payout_pending=pending_after,
        settled=settled,
    )
    app_finance_log.log_balance(
        reason="payout_jump",
        uid=uid,
        balance_before=balance,
        balance_after=0,
        delta=-balance,
        payout_id=payout_id,
        jump_payment_id=jump_payment_id_int,
        amount_to_card=on_card,
        commission=commission,
        balance_payout_pending=pending_after,
        pending=not settled,
    )

    result: dict[str, Any] = {
        "ok": True,
        "amount": on_card,
        "jump_amount": jump_amount,
        "commission": commission,
        "balance_before": balance,
        "balance_after": 0,
        "balance_payout_pending": pending_after,
        "contractor_id": new_contractor,
        "jump_payment_id": jump_payment_id_int,
        "jump_status_id": sid,
        "jump_status_title": st_title,
        "payout_id": payout_id,
        "payout_status": payout_status,
        "pending": not settled,
        "jump": payload if isinstance(payload, dict) else {"raw": str(payload)[:300]},
    }
    if not settled:
        result["message"] = _pending_user_hint(st_title)
    return result


def heal_legacy_pending_for_user(
    uid: str,
    jump_payment_ids: list[int],
    *,
    debit_current_balance: bool = True,
) -> dict[str, Any]:
    """Разовый heal: Jump-выплаты без записи → pending + списание в balance_payout_pending."""
    sync_user_payouts(uid)
    me = app_pg.get_me(uid) or {}
    balance = _num(me.get("balance"))
    out: dict[str, Any] = {
        "uid": uid,
        "balance_before": balance,
        "registered": [],
        "skipped": [],
        "debited": 0,
    }
    debited_once = False
    for raw_id in jump_payment_ids:
        try:
            jid = int(raw_id)
        except (TypeError, ValueError):
            continue
        existing = app_pg.get_payout_by_jump_id(jid)
        if existing:
            out["skipped"].append({"jump_payment_id": jid, "reason": "exists"})
            continue
        item = _jump_fetch_payment(jid)
        if not item:
            out["skipped"].append({"jump_payment_id": jid, "reason": "jump_fetch_failed"})
            continue
        sid, title, _ = _jump_payment_status(item)
        if _jump_payout_cancelled(item):
            out["skipped"].append(
                {"jump_payment_id": jid, "reason": "cancelled", "title": title}
            )
            continue
        settled = _jump_payout_settled(item)
        status = "settled" if settled else "pending"
        amount = _num(item.get("amount"))
        do_debit = debit_current_balance and not debited_once and balance > 0
        balance_debited = 0.0
        bal_before_row = balance
        pending_after = _pending_amount(me)
        if do_debit:
            try:
                pending_after = _apply_debit_to_pending(uid, balance=balance)
            except RuntimeError:
                out["skipped"].append({"jump_payment_id": jid, "reason": "debit_failed"})
                continue
            balance_debited = balance
            debited_once = True
            out["debited"] = balance_debited
            app_finance_log.log_balance(
                reason="payout_jump_heal",
                uid=uid,
                balance_before=balance,
                balance_after=0,
                delta=-balance_debited,
                jump_payment_id=jid,
                balance_payout_pending=pending_after,
            )
            balance = 0.0
            if settled:
                pending_after = _clear_pending_amount(uid, balance_debited)
                status = "settled"
        payout_id = f"po_heal_{jid}"
        ok = app_pg.create_payout(
            payout_id=payout_id,
            user_id=uid,
            jump_payment_id=jid,
            amount_to_card=amount,
            commission=0,
            balance_before=bal_before_row,
            balance_debited=balance_debited,
            status=status,
            jump_status_id=sid,
            jump_status_title=title,
            pan_tail="",
            raw_json=item,
        )
        out["registered"].append(
            {
                "payout_id": payout_id,
                "jump_payment_id": jid,
                "status": status,
                "balance_debited": balance_debited,
                "saved": ok,
            }
        )
        app_finance_log.log_payout(
            phase="heal_registered",
            uid=uid,
            payout_id=payout_id,
            jump_payment_id=jid,
            jump_status_id=sid,
            jump_status_title=title,
            balance_debited=balance_debited,
            balance_payout_pending=pending_after,
            settled=settled,
        )
    me2 = app_pg.get_me(uid) or {}
    out["balance_after"] = _num(me2.get("balance"))
    out["balance_payout_pending"] = _pending_amount(me2)
    return out
