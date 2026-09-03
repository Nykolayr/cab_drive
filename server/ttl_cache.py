"""Простой process-local TTL-кэш (на каждый gunicorn worker свой)."""
from __future__ import annotations

import threading
import time
from typing import Any, Callable, TypeVar

T = TypeVar("T")

_lock = threading.Lock()
_store: dict[str, tuple[float, Any]] = {}


def get_or_set(key: str, ttl_sec: float, factory: Callable[[], T]) -> T:
    now = time.time()
    with _lock:
        hit = _store.get(key)
        if hit is not None and hit[0] > now:
            return hit[1]
    value = factory()
    with _lock:
        _store[key] = (now + ttl_sec, value)
    return value


def invalidate(prefix: str | None = None) -> None:
    with _lock:
        if prefix is None:
            _store.clear()
            return
        for k in [k for k in _store if k.startswith(prefix)]:
            _store.pop(k, None)
