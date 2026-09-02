"""Структурированный лог событий T‑Bank (jsonl) для админки."""

from __future__ import annotations

import json
import os
import threading
from datetime import datetime, timezone
from typing import Any, Optional

import utils

_LOCK = threading.Lock()
_MAX_BYTES = 20 * 1024 * 1024  # ~20MB, потом ротация
_READ_MAX_LINES = 5000


def _log_path() -> str:
    return os.path.join(utils.get_script_dir(), 'tinkoff_events.jsonl')


def append_event(
    event_type: str,
    *,
    level: str = 'info',
    message: str = '',
    order_id: str = '',
    payment_id: str = '',
    amount: Any = None,
    error_code: str = '',
    status: str = '',
    customer_key: str = '',
    mode: str = '',
    extra: Optional[dict] = None,
) -> None:
    """Пишет одну JSON-строку. Секреты (Token/Password) не передавать."""
    payload: dict[str, Any] = {
        'ts': datetime.now(timezone.utc).isoformat(),
        'level': (level or 'info').lower(),
        'type': event_type,
        'message': (message or '')[:1000],
        'orderId': str(order_id or ''),
        'paymentId': str(payment_id or ''),
        'amount': amount,
        'errorCode': str(error_code or ''),
        'status': str(status or ''),
        'customerKey': str(customer_key or '')[:64],
        'mode': str(mode or ''),
    }
    if extra:
        # только плоские безопасные поля
        for key, value in extra.items():
            if key.lower() in ('token', 'password', 'authorization'):
                continue
            if isinstance(value, (dict, list)):
                continue
            payload[key] = value

    line = json.dumps(payload, ensure_ascii=False, default=str) + '\n'
    path = _log_path()
    try:
        with _LOCK:
            if os.path.exists(path) and os.path.getsize(path) > _MAX_BYTES:
                bak = path + '.1'
                try:
                    if os.path.exists(bak):
                        os.remove(bak)
                    os.rename(path, bak)
                except OSError:
                    pass
            with open(path, 'a', encoding='utf-8') as f:
                f.write(line)
    except Exception:
        # лог не должен валить платёж
        pass


def _parse_ts(value: str) -> Optional[datetime]:
    if not value:
        return None
    try:
        # date only
        if len(value) == 10:
            return datetime.strptime(value, '%Y-%m-%d').replace(tzinfo=timezone.utc)
        dt = datetime.fromisoformat(value.replace('Z', '+00:00'))
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt
    except Exception:
        return None


def query_events(
    *,
    date_from: str = '',
    date_to: str = '',
    event_type: str = '',
    level: str = '',
    q: str = '',
    fails_only: bool = False,
    limit: int = 100,
    offset: int = 0,
) -> dict[str, Any]:
    path = _log_path()
    events: list[dict] = []
    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8', errors='replace') as f:
                lines = f.readlines()
            # читаем с конца
            for line in reversed(lines[-_READ_MAX_LINES:]):
                line = line.strip()
                if not line:
                    continue
                try:
                    events.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
        except OSError:
            events = []

    df = _parse_ts(date_from)
    dt = _parse_ts(date_to)
    if dt and len(date_to) == 10:
        # конец дня
        dt = dt.replace(hour=23, minute=59, second=59)

    type_filter = (event_type or '').strip().lower()
    level_filter = (level or '').strip().lower()
    query = (q or '').strip().lower()

    filtered: list[dict] = []
    for ev in events:
        ts = _parse_ts(str(ev.get('ts') or ''))
        if df and ts and ts < df:
            continue
        if dt and ts and ts > dt:
            continue
        if type_filter and str(ev.get('type') or '').lower() != type_filter:
            continue
        if level_filter and str(ev.get('level') or '').lower() != level_filter:
            continue
        if fails_only:
            lvl = str(ev.get('level') or '').lower()
            st = str(ev.get('status') or '').upper()
            typ = str(ev.get('type') or '').lower()
            if not (
                lvl == 'error'
                or lvl == 'warn'
                or st in ('REJECTED', 'CANCELED', 'DEADLINE_EXPIRED', 'AUTH_FAIL')
                or 'fail' in typ
                or 'reject' in typ
            ):
                continue
        if query:
            blob = ' '.join(
                str(ev.get(k) or '')
                for k in (
                    'message',
                    'orderId',
                    'paymentId',
                    'errorCode',
                    'status',
                    'customerKey',
                    'type',
                )
            ).lower()
            if query not in blob:
                continue
        filtered.append(ev)

    total = len(filtered)
    limit = max(1, min(int(limit or 100), 500))
    offset = max(0, int(offset or 0))
    page = filtered[offset : offset + limit]

    types = sorted({str(e.get('type') or '') for e in events if e.get('type')})
    return {
        'events': page,
        'total': total,
        'limit': limit,
        'offset': offset,
        'types': types,
    }
