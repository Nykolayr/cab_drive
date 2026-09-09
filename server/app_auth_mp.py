"""Auth МП: Firebase ID token в Authorization: Bearer <token>."""
from __future__ import annotations

import logging
from typing import Optional, Tuple

from flask import abort, request

import utils

logger = logging.getLogger(__name__)


def _bearer_token() -> Optional[str]:
    h = request.headers.get("Authorization") or request.headers.get("authorization") or ""
    if not h:
        return None
    parts = h.split(None, 1)
    if len(parts) != 2:
        return None
    if parts[0].lower() != "bearer":
        return None
    tok = parts[1].strip()
    return tok or None


def verify_firebase_uid() -> Tuple[str, dict]:
    """
    Проверяет Firebase ID token.
    Returns: (uid, decoded_claims)
    abort 401 при ошибке.
    """
    utils.init_firebase_client()
    token = _bearer_token()
    if not token:
        abort(401, description="missing bearer token")
    try:
        from firebase_admin import auth

        decoded = auth.verify_id_token(token)
    except Exception as e:
        logger.info("[app_auth_mp] verify_id_token failed: %s", e)
        abort(401, description="invalid firebase token")
    uid = decoded.get("uid") or decoded.get("user_id") or decoded.get("sub")
    if not uid:
        abort(401, description="token without uid")
    return str(uid), decoded


def optional_firebase_uid() -> Optional[str]:
    try:
        uid, _ = verify_firebase_uid()
        return uid
    except Exception:
        return None
