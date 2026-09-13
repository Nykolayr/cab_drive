"""Вывод средств: Jump Finance + списание баланса в Postgres (без Firestore)."""
from __future__ import annotations

import logging
import uuid
from typing import Any, Optional

import requests

import app_pg
import config

logger = logging.getLogger(__name__)


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
    """Сумма на карту = balance - commission (как «Вы получите на карту» в UI)."""
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
    """status_id, title, is_final из ответа Jump."""
    st = item.get("status") or {}
    if not isinstance(st, dict):
        return 0, "", bool(item.get("is_final"))
    try:
        sid = int(st.get("id") or 0)
    except (TypeError, ValueError):
        sid = 0
    title = str(st.get("title") or "").strip()
    is_final = bool(item.get("is_final"))
    return sid, title, is_final


def _jump_payout_settled(item: dict[str, Any]) -> bool:
    """Списываем balance только когда выплата реально завершена (оплачена)."""
    if not item:
        return False
    sid, _, is_final = _jump_payment_status(item)
    if sid == 1:
        return True
    return is_final and sid not in (4,)


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

    me = app_pg.get_me(uid)
    if not me:
        raise ValueError("Пользователь не найден")
    balance = _num(me.get("balance"))
    if balance < 200:
        raise ValueError("Минимальная сумма вывода — 200 ₽")

    amount = amount_to_card(balance)
    if amount <= 0:
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
            "amount": amount,
        }
    else:
        url = "https://api.jump.finance/services/openapi/payments/smart"
        body = {
            "customer_payment_id": customer_payment_id,
            "phone": phone,
            "last_name": last_name or "Driver",
            "first_name": first_name or "Cab",
            "requisite": {"type_id": 8, "account_number": pan},
            "amount": amount,
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
        "[payout] jump status=%s uid=%s amount=%s contractor=%s body_keys=%s",
        resp.status_code,
        uid,
        amount,
        contractor_id_int,
        list(payload.keys()) if isinstance(payload, dict) else type(payload),
    )

    if resp.status_code >= 400 or (
        isinstance(payload, dict) and payload.get("error")
    ):
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

    sid, st_title, is_final = _jump_payment_status(item)
    jump_payment_id = item.get("id")

    # Сохраняем contractor_id из Jump даже если выплата ещё не финальна.
    if new_contractor > 0 and new_contractor != contractor_id_int:
        app_pg.mirror_user_fields(uid, {"contractor_id": new_contractor})

    if not _jump_payout_settled(item):
        logger.warning(
            "[payout] jump pending uid=%s payment_id=%s status_id=%s title=%s",
            uid,
            jump_payment_id,
            sid,
            st_title,
        )
        hint = st_title or "ожидает обработки"
        if sid == 4:
            raise ValueError(
                "Выплата создана в Jump, но требует подтверждения в личном кабинете Jump Finance. "
                f"Баланс в приложении не списан ({hint})."
            )
        raise ValueError(
            f"Выплата в Jump ещё не завершена ({hint}). Баланс не списан — попробуйте позже."
        )

    fields: dict[str, Any] = {"balance": 0}
    if new_contractor > 0:
        fields["contractor_id"] = new_contractor
    if not app_pg.mirror_user_fields(uid, fields):
        raise RuntimeError(
            "Вывод у Jump прошёл, но баланс в БД не обновился — обратитесь в поддержку"
        )

    return {
        "ok": True,
        "amount": amount,
        "commission": payout_commission(balance),
        "balance_before": balance,
        "balance_after": 0,
        "contractor_id": new_contractor,
        "jump_payment_id": jump_payment_id,
        "jump_status_id": sid,
        "jump": payload if isinstance(payload, dict) else {"raw": str(payload)[:300]},
    }
