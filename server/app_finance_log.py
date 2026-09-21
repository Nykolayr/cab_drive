"""Единый финансовый лог: payout / balance / commission — grep: [finance]."""
from __future__ import annotations

import json
import logging
from typing import Any, Optional

logger = logging.getLogger("cab.finance")


def _safe(v: Any) -> Any:
    if v is None or isinstance(v, (bool, int, float, str)):
        return v
    try:
        json.dumps(v, ensure_ascii=False, default=str)
        return v
    except Exception:
        return str(v)


def log_event(event: str, **fields: Any) -> None:
    """Пишет одну строку JSON: [finance] {event, ...}.

    Искать: journalctl -u cab.service | grep '\\[finance\\]'
    """
    payload = {"event": event}
    for k, v in fields.items():
        if v is None:
            continue
        payload[k] = _safe(v)
    try:
        line = json.dumps(payload, ensure_ascii=False, default=str, separators=(",", ":"))
    except Exception:
        line = str(payload)
    logger.info("[finance] %s", line)


def log_payout(
    *,
    phase: str,
    uid: str,
    **fields: Any,
) -> None:
    log_event("payout", phase=phase, uid=uid, **fields)


def log_balance(
    *,
    reason: str,
    uid: str,
    balance_before: Optional[float] = None,
    balance_after: Optional[float] = None,
    delta: Optional[float] = None,
    **fields: Any,
) -> None:
    log_event(
        "balance",
        reason=reason,
        uid=uid,
        balance_before=balance_before,
        balance_after=balance_after,
        delta=delta,
        **fields,
    )
