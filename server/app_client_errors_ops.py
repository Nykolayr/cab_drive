"""Клиентские ошибки МП → Postgres (контракт шаблона ClientErrorReporter)."""
from __future__ import annotations

import hashlib
import logging
from typing import Any, Optional

import app_pg

logger = logging.getLogger(__name__)

MESSAGE_MAX = 1024
STACK_MAX = 16_000
TAG_MAX = 64
DEVICE_MAX = 256
LIST_DEFAULT = 50
LIST_MAX = 200


def _norm(value: Any, max_len: int) -> Optional[str]:
    s = str(value or "").strip()
    if not s:
        return None
    return s if len(s) <= max_len else s[:max_len]


def _fingerprint(message: str, stack: Optional[str], tag: Optional[str]) -> str:
    raw = f"{tag or ''}|{message}|{(stack or '')[:500]}"
    return hashlib.sha1(raw.encode("utf-8", "replace")).hexdigest()


def insert_client_error(
    *,
    message: str,
    stack: Optional[str] = None,
    tag: Optional[str] = None,
    platform: Optional[str] = None,
    app_version: Optional[str] = None,
    build_number: Optional[str] = None,
    fatal: bool = False,
    device_info: Optional[str] = None,
    user_id: Optional[str] = None,
    login: Optional[str] = None,
    role: Optional[str] = None,
) -> bool:
    msg = _norm(message, MESSAGE_MAX)
    if not msg:
        raise ValueError("message required")
    st = _norm(stack, STACK_MAX)
    tg = _norm(tag, TAG_MAX)
    plat = _norm(platform, 32)
    ver = _norm(app_version, 64)
    build = _norm(build_number, 32)
    device = _norm(device_info, DEVICE_MAX)
    uid = _norm(user_id, 128)
    log = _norm(login, 128)
    rol = _norm(role, 32)
    fp = _fingerprint(msg, st, tg)

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO app_client_errors
                  (user_id, login, role, platform, app_version, build_number,
                   tag, message, stack_text, fatal, device_info, fingerprint)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                """,
                (
                    uid,
                    log,
                    rol,
                    plat,
                    ver,
                    build,
                    tg,
                    msg,
                    st,
                    bool(fatal),
                    device,
                    fp,
                ),
            )
        return True

    ok = app_pg.soft_execute("insert_client_error", _run)
    if not ok:
        logger.warning("[app_client_errors] insert soft-failed")
    return bool(ok)


def list_client_errors(limit: int = LIST_DEFAULT) -> list[dict]:
    lim = int(limit or LIST_DEFAULT)
    if lim < 1:
        lim = LIST_DEFAULT
    if lim > LIST_MAX:
        lim = LIST_MAX

    def _run(conn):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, created_at, user_id, login, role, platform,
                       app_version, build_number, tag, message, stack_text,
                       fatal, device_info, fingerprint
                FROM app_client_errors
                ORDER BY id DESC
                LIMIT %s
                """,
                (lim,),
            )
            cols = [c[0] for c in cur.description]
            rows = cur.fetchall() or []
            out = []
            for row in rows:
                m = dict(zip(cols, row))
                out.append(
                    {
                        "id": m["id"],
                        "createdAt": m["created_at"].isoformat()
                        if m.get("created_at")
                        else None,
                        "userId": m.get("user_id"),
                        "login": m.get("login"),
                        "role": m.get("role"),
                        "platform": m.get("platform"),
                        "appVersion": m.get("app_version"),
                        "buildNumber": m.get("build_number"),
                        "tag": m.get("tag"),
                        "message": m.get("message"),
                        "stack": m.get("stack_text"),
                        "fatal": bool(m.get("fatal")),
                        "deviceInfo": m.get("device_info"),
                        "fingerprint": m.get("fingerprint"),
                    }
                )
            return out

    with app_pg.connection() as conn:
        if conn is None:
            return []
        return _run(conn) or []
