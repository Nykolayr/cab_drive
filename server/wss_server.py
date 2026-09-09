"""
WSS hub для чатов (и задел под order.updated).
Запуск: python wss_server.py  (порт 5001)
Протокол JSON: { "t": "<type>", "id": "...", "p": { ... } }
"""
from __future__ import annotations

import asyncio
import json
import logging
import os
import sys
from typing import Any, Optional

# allow import from project root
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("wss")

try:
    import websockets
except ImportError:
    websockets = None  # type: ignore

import app_chat_pg
# firebase verify without importing app_auth_mp (circular utils)

HOST = os.environ.get("CAB_WSS_HOST", "0.0.0.0")
PORT = int(os.environ.get("CAB_WSS_PORT", "5001"))
REDIS_URL = os.environ.get("REDIS_URL", "redis://127.0.0.1:6379/0")

# uid -> set of websockets
_user_sockets: dict[str, set] = {}
# chat_id -> set of uids subscribed
_chat_subs: dict[str, set[str]] = {}
# ws -> uid
_ws_uid: dict = {}


def _envelope(t: str, p: Any = None, id_: Optional[str] = None) -> str:
    msg: dict[str, Any] = {"t": t, "p": p if p is not None else {}}
    if id_:
        msg["id"] = id_
    return json.dumps(msg, ensure_ascii=False)


async def _send(ws, t: str, p: Any = None, id_: Optional[str] = None):
    await ws.send(_envelope(t, p, id_))


async def _broadcast_chat(chat_id: str, message: dict):
    uids = list(_chat_subs.get(chat_id, set()))
    # also notify all members even if not subscribed in this process? members from PG
    chat = app_chat_pg.get_chat(chat_id)
    if chat:
        for uid in chat.get("users") or []:
            if uid not in uids:
                uids.append(uid)
    payload = _envelope("chat.new", message)
    for uid in uids:
        for sock in list(_user_sockets.get(uid, set())):
            try:
                await sock.send(payload)
            except Exception:
                pass


async def _handle_auth(ws, p: dict, req_id: Optional[str]):
    token = (p.get("token") or "").strip()
    if not token:
        await _send(ws, "error", {"code": "auth", "message": "token required"}, req_id)
        return None
    try:
        import firebase_admin
        from firebase_admin import credentials, auth as fb_auth

        if not firebase_admin._apps:
            cred_path = os.environ.get(
                "GOOGLE_APPLICATION_CREDENTIALS",
                os.path.join(os.path.dirname(__file__), "s.json"),
            )
            firebase_admin.initialize_app(credentials.Certificate(cred_path))
        decoded = fb_auth.verify_id_token(token)
        uid = decoded.get("uid") or decoded.get("user_id")
        if not uid:
            raise ValueError("no uid")
    except Exception as e:
        await _send(ws, "error", {"code": "auth", "message": str(e)}, req_id)
        return None

    old = _ws_uid.get(ws)
    if old and old in _user_sockets:
        _user_sockets[old].discard(ws)
    _ws_uid[ws] = uid
    _user_sockets.setdefault(uid, set()).add(ws)
    await _send(ws, "auth.ok", {"user_id": uid}, req_id)
    return uid


async def _handle(ws, uid: Optional[str], data: dict):
    t = data.get("t") or ""
    p = data.get("p") or {}
    req_id = data.get("id")

    if t == "auth":
        return await _handle_auth(ws, p, req_id)

    if not uid:
        await _send(ws, "error", {"code": "auth", "message": "auth required"}, req_id)
        return uid

    if t == "chat.subscribe":
        chat_id = str(p.get("chat_id") or "")
        if not chat_id:
            await _send(ws, "error", {"code": "forbidden", "message": "chat"}, req_id)
            return uid
        if not app_chat_pg.user_in_chat(chat_id, uid):
            # transitional: import FS chat id into PG
            app_chat_pg.touch_chat_for_user(
                chat_id, uid, support=bool(p.get("support"))
            )
        if not app_chat_pg.user_in_chat(chat_id, uid):
            await _send(ws, "error", {"code": "forbidden", "message": "chat"}, req_id)
            return uid
        _chat_subs.setdefault(chat_id, set()).add(uid)
        await _send(ws, "chat.subscribed", {"chat_id": chat_id}, req_id)
        return uid

    if t == "chat.history":
        chat_id = str(p.get("chat_id") or "")
        if not chat_id:
            await _send(ws, "error", {"code": "forbidden", "message": "chat"}, req_id)
            return uid
        if not app_chat_pg.user_in_chat(chat_id, uid):
            app_chat_pg.touch_chat_for_user(chat_id, uid)
        if not app_chat_pg.user_in_chat(chat_id, uid):
            await _send(ws, "error", {"code": "forbidden", "message": "chat"}, req_id)
            return uid
        limit = int(p.get("limit") or 50)
        before = p.get("before")
        msgs = app_chat_pg.list_messages(chat_id, limit=limit, before=before)
        await _send(
            ws, "chat.history.ok", {"chat_id": chat_id, "messages": msgs}, req_id
        )
        return uid

    if t == "chat.send":
        chat_id = str(p.get("chat_id") or "")
        if not chat_id:
            await _send(ws, "error", {"code": "forbidden", "message": "chat"}, req_id)
            return uid
        if not app_chat_pg.user_in_chat(chat_id, uid):
            app_chat_pg.touch_chat_for_user(chat_id, uid)
        if not app_chat_pg.user_in_chat(chat_id, uid):
            await _send(ws, "error", {"code": "forbidden", "message": "chat"}, req_id)
            return uid
        text = str(p.get("text") or "")
        images = p.get("list_images") or []
        if not isinstance(images, list):
            images = []
        if not text and not images:
            await _send(ws, "error", {"code": "empty", "message": "empty message"}, req_id)
            return uid
        msg = app_chat_pg.insert_message(chat_id, uid, text=text, list_images=images)
        if not msg:
            await _send(ws, "error", {"code": "db", "message": "insert failed"}, req_id)
            return uid
        # soft FS mirror (lazy import to avoid utils circular at startup)
        try:
            def _fs():
                import utils
                from firebase_admin import firestore

                utils.init_firebase_client()
                db = firestore.client()
                chat_ref = db.collection("chats").document(chat_id)
                db.collection("messages").document(msg["id"]).set(
                    {
                        "text": text,
                        "list_images": images,
                        "sender": db.collection("users").document(uid),
                        "date_created": firestore.SERVER_TIMESTAMP,
                        "read": False,
                        "chatRef": chat_ref,
                    }
                )
                chat_ref.set(
                    {
                        "last_message": (text or "🖼")[:500],
                        "date_created": firestore.SERVER_TIMESTAMP,
                    },
                    merge=True,
                )

            import app_fs_mirror

            app_fs_mirror.soft_fs("wss_chat_send", _fs)
        except Exception:
            logger.exception("fs mirror chat send")
        await _broadcast_chat(chat_id, msg)
        # publish redis for multi-instance / HTTP path
        try:
            await _redis_publish(chat_id, msg)
        except Exception:
            pass
        return uid

    if t == "ping":
        await _send(ws, "pong", {}, req_id)
        return uid

    await _send(ws, "error", {"code": "unknown", "message": t}, req_id)
    return uid


_redis = None


async def _redis_publish(chat_id: str, msg: dict):
    global _redis
    if _redis is None:
        return
    await _redis.publish(
        "cab:chat", json.dumps({"chat_id": chat_id, "message": msg}, ensure_ascii=False)
    )


async def _redis_listener():
    global _redis
    try:
        import redis.asyncio as aioredis
    except Exception:
        logger.warning("redis.asyncio unavailable — in-process fanout only")
        return
    try:
        # optional password from env
        url = REDIS_URL
        _redis = aioredis.from_url(url, decode_responses=True)
        await _redis.ping()
        pubsub = _redis.pubsub()
        await pubsub.subscribe("cab:chat")
        logger.info("redis subscribed cab:chat")
        async for item in pubsub.listen():
            if item is None or item.get("type") != "message":
                continue
            try:
                data = json.loads(item["data"])
                await _broadcast_chat(data["chat_id"], data["message"])
            except Exception:
                logger.exception("redis message handle")
    except Exception as e:
        logger.warning("redis listener disabled: %s", e)
        _redis = None


async def handler(ws):
    uid = None
    try:
        async for raw in ws:
            try:
                data = json.loads(raw)
            except Exception:
                await _send(ws, "error", {"code": "bad_json", "message": "invalid json"})
                continue
            if not isinstance(data, dict):
                continue
            uid = await _handle(ws, uid, data)
    finally:
        u = _ws_uid.pop(ws, None)
        if u and u in _user_sockets:
            _user_sockets[u].discard(ws)
            if not _user_sockets[u]:
                del _user_sockets[u]
        for chat_id, members in list(_chat_subs.items()):
            if u in members:
                members.discard(u)


async def main():
    if websockets is None:
        raise SystemExit("pip install websockets")
    asyncio.create_task(_redis_listener())
    logger.info("WSS listening on %s:%s", HOST, PORT)
    async with websockets.serve(handler, HOST, PORT, ping_interval=20, ping_timeout=20):
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())
