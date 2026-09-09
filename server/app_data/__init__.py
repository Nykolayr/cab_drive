"""Read API поверх Postgres-зеркала (Firestore пока source of truth для записи МП)."""
from flask import blueprints, request, abort
import os

import utils
import app_pg
import app_auth_mp

app = blueprints.Blueprint("app_data", __name__, url_prefix="/api/app")


def _require_admin():
    user = utils.get_user()
    if user is None:
        abort(401)
    return user


@app.route("/health", methods=["GET"])
def health():
    import app_fs_mirror

    return {
        "status": "ok",
        "postgres": app_pg.enabled(),
        "fs_mirror": app_fs_mirror.fs_mirror_enabled(),
        "sot": "postgres",
    }


@app.route("/me", methods=["GET"])
def me():
    """Профиль текущего пользователя МП (Firebase Bearer → Postgres)."""
    uid, _ = app_auth_mp.verify_firebase_uid()
    data = app_pg.get_me(uid)
    if not data:
        # минимальный PG upsert (без Firestore SoT)
        app_pg.mirror_user_fields(uid, {"login_complete": False})
        data = app_pg.get_me(uid)
    if not data:
        return utils.get_error("user not found", status=404)
    return utils.get_answer("ok", info={"user": data, "uid": uid})


@app.route("/me", methods=["PATCH"])
def me_patch():
    """Частичный апдейт профиля МП → Postgres."""
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_me_ops

        body = request.get_json(silent=True) or {}
        result = app_me_ops.patch_me(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


def _me_op_error(exc: Exception):
    msg = str(exc) or "operation failed"
    if isinstance(exc, PermissionError):
        return utils.get_error(msg, status=403)
    status = 400 if isinstance(exc, ValueError) else 500
    return utils.get_error(msg, status=status)


@app.route("/me/shift/start", methods=["POST"])
def me_shift_start():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_me_ops

        result = app_me_ops.shift_start(uid)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/shift/end", methods=["POST"])
def me_shift_end():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_me_ops

        result = app_me_ops.shift_end(uid)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/fine/late-commission", methods=["POST"])
def me_late_fine():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_me_ops

        result = app_me_ops.apply_late_commission_fine(uid)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/fine/clear", methods=["POST"])
def me_clear_fine():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_me_ops

        result = app_me_ops.clear_fine_flag(uid)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/addresses/add", methods=["POST"])
def me_addresses_add():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_profile_ops

        body = request.get_json(silent=True) or {}
        result = app_profile_ops.add_address(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/addresses/remove", methods=["POST"])
def me_addresses_remove():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_profile_ops

        body = request.get_json(silent=True) or {}
        result = app_profile_ops.remove_address(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/cards", methods=["GET"])
def list_cards():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_profile_ops

        rows = app_profile_ops.list_cards(uid)
        return utils.get_answer(
            "ok",
            info={"cards": rows, "count": len(rows), "source": "postgres", "uid": uid},
        )
    except Exception as e:
        return _me_op_error(e)


@app.route("/cards", methods=["POST"])
def create_card():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_profile_ops

        body = request.get_json(silent=True) or {}
        result = app_profile_ops.create_card(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/cards/<card_id>", methods=["DELETE"])
def delete_card(card_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_profile_ops

        result = app_profile_ops.delete_card(uid, card_id)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/complete", methods=["POST"])
def complete_order(order_id: str):
    """Клиент завершает заказ: status=completed + комиссия водителю (FS+PG)."""
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        result = app_order_ops.complete_order_by_customer(uid, order_id)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/status", methods=["POST"])
def set_order_status(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        status = body.get("status")
        result = app_order_ops.set_order_status(
            uid, order_id, str(status or ""), extra=body
        )
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/accept-bid", methods=["POST"])
def accept_bid(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        driver_uid = body.get("driver_uid") or body.get("driverId")
        result = app_order_ops.accept_bid(
            uid,
            order_id,
            str(driver_uid or ""),
            price=body.get("price"),
            commission_percent=body.get("commission_percent")
            or body.get("commissionPercent"),
        )
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/dequeue", methods=["POST"])
def dequeue_order(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        advance = body.get("advance", True)
        result = app_order_ops.dequeue_order(
            uid, order_id, advance=bool(advance)
        )
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/cancel", methods=["POST"])
def cancel_order(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        result = app_order_ops.cancel_order_by_customer(uid, order_id)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/hide", methods=["POST"])
def hide_order(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        unhide = bool(body.get("unhide") or body.get("publish"))
        result = app_order_ops.hide_order(uid, order_id, unhide=unhide)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/geo", methods=["POST"])
def order_geo(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        lat = body.get("lat") if body.get("lat") is not None else body.get("driver_lat")
        lng = body.get("lng") if body.get("lng") is not None else body.get("driver_lng")
        if lat is None or lng is None:
            raise ValueError("lat/lng required")
        result = app_order_ops.ping_order_geo(
            uid,
            order_id,
            lat=float(lat),
            lng=float(lng),
            time_left=body.get("time_left"),
            km_left=body.get("km_left"),
        )
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/location", methods=["POST"])
def me_location():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_me_ops

        body = request.get_json(silent=True) or {}
        lat = body.get("lat") if body.get("lat") is not None else body.get("driver_lat")
        lng = body.get("lng") if body.get("lng") is not None else body.get("driver_lng")
        if lat is None or lng is None:
            raise ValueError("lat/lng required")
        result = app_me_ops.ping_me_location(uid, lat=float(lat), lng=float(lng))
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/create", methods=["POST"])
def create_order():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        result = app_order_ops.create_order_for_customer(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/mine", methods=["GET"])
def my_orders():
    uid, _ = app_auth_mp.verify_firebase_uid()
    role = (request.args.get("role") or "customer").lower()
    status = request.args.get("status")
    limit = int(request.args.get("limit") or 50)
    if role == "driver":
        rows = app_pg.list_orders_for_user(driver_id=uid, status=status, limit=min(limit, 200))
    else:
        rows = app_pg.list_orders_for_user(customer_id=uid, status=status, limit=min(limit, 200))
    return utils.get_answer(
        "ok", info={"orders": rows, "count": len(rows), "source": "postgres", "uid": uid}
    )


@app.route("/orders/feed", methods=["GET"])
def orders_feed():
    """Лента newOrder для водителя на смене (poll вместо FS stream)."""
    uid, _ = app_auth_mp.verify_firebase_uid()
    status = request.args.get("status") or "newOrder"
    limit = int(request.args.get("limit") or 50)
    rows = app_pg.list_orders(status=status, limit=min(limit, 100))
    return utils.get_answer(
        "ok", info={"orders": rows, "count": len(rows), "source": "postgres", "uid": uid}
    )


@app.route("/orders/<order_id>/bids", methods=["GET"])
def list_bids(order_id: str):
    app_auth_mp.verify_firebase_uid()
    rows = []
    try:
        import app_bids_ops

        rows = app_bids_ops.list_bids(order_id)
    except Exception as e:
        return _me_op_error(e)
    return utils.get_answer("ok", info={"bids": rows, "count": len(rows), "source": "postgres"})


@app.route("/orders/<order_id>/bids", methods=["POST"])
def create_bid(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_bids_ops

        body = request.get_json(silent=True) or {}
        result = app_bids_ops.create_bid(uid, order_id, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/orders/<order_id>/bids/<bid_id>", methods=["DELETE"])
def delete_bid(order_id: str, bid_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_bids_ops

        result = app_bids_ops.delete_bid(uid, order_id, bid_id)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/me/fcm", methods=["POST"])
def me_fcm():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_bids_ops

        body = request.get_json(silent=True) or {}
        token = (body.get("token") or "").strip()
        result = app_bids_ops.upsert_fcm_token(uid, token)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/push", methods=["POST"])
def send_push():
    """Прямая FCM-отправка (Bearer). Токены из Postgres."""
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_fcm_ops

        body = request.get_json(silent=True) or {}
        user_ids = body.get("user_ids") or body.get("uids") or []
        if isinstance(user_ids, str):
            user_ids = [user_ids]
        if not isinstance(user_ids, list):
            return utils.get_error("user_ids required", status=400)
        title = body.get("title") or body.get("notification_title") or ""
        text = body.get("text") or body.get("notification_text") or body.get("body") or ""
        data = body.get("data") if isinstance(body.get("data"), dict) else None
        result = app_fcm_ops.send_to_users(
            [str(x) for x in user_ids],
            title=str(title),
            body=str(text),
            data=data,
            initial_page_name=body.get("initial_page_name") or body.get("initialPageName"),
            parameter_data=body.get("parameter_data") or body.get("parameterData"),
        )
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/payments", methods=["POST"])
def create_payment():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import uuid
        import app_pg
        import app_fs_mirror

        body = request.get_json(silent=True) or {}
        pay_id = str(body.get("id") or "").strip() or uuid.uuid4().hex
        body = dict(body)
        body["id"] = pay_id
        if not body.get("user") and not body.get("user_id"):
            body["user_id"] = uid
            body["user"] = {"_ref": f"users/{uid}"}
        if not app_pg.upsert_pay_order(pay_id, body):
            raise RuntimeError("postgres upsert pay_order failed")

        def _fs():
            utils.init_firebase_client()
            from firebase_admin import firestore

            db = firestore.client()
            fs_doc = dict(body)
            if body.get("user_id"):
                fs_doc["user"] = db.collection("users").document(body["user_id"])
            db.collection("pay_order").document(pay_id).set(fs_doc, merge=True)

        app_fs_mirror.soft_fs("create_pay_order", _fs)
        return utils.get_answer("ok", info={"result": {"id": pay_id}, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/payments/<pay_id>", methods=["GET"])
def get_payment(pay_id: str):
    app_auth_mp.verify_firebase_uid()
    import app_pg

    data = app_pg.get_pay_order(pay_id)
    if not data:
        return utils.get_error("pay_order not found", status=404)
    return utils.get_answer("ok", info={"payment": data})


@app.route("/payments/<pay_id>", methods=["PATCH"])
def patch_payment(pay_id: str):
    app_auth_mp.verify_firebase_uid()
    try:
        import app_pg
        import app_fs_mirror

        body = request.get_json(silent=True) or {}
        existing = app_pg.get_pay_order(pay_id) or {"id": pay_id}
        merged = {**existing, **body, "id": pay_id}
        if not app_pg.upsert_pay_order(pay_id, merged):
            raise RuntimeError("postgres patch pay_order failed")

        def _fs():
            utils.init_firebase_client()
            from firebase_admin import firestore

            firestore.client().collection("pay_order").document(pay_id).set(body, merge=True)

        app_fs_mirror.soft_fs("patch_pay_order", _fs)
        return utils.get_answer("ok", info={"payment": app_pg.get_pay_order(pay_id)})
    except Exception as e:
        return _me_op_error(e)


@app.route("/users/<user_id>/public", methods=["GET"])
def get_user_public(user_id: str):
    """Peer-профиль для карточек МП (Bearer Firebase)."""
    app_auth_mp.verify_firebase_uid()
    data = app_pg.get_public_user(user_id)
    if not data:
        return utils.get_error("user not found", status=404)
    return utils.get_answer("ok", info={"user": data, "source": "postgres"})


@app.route("/reviews", methods=["POST"])
def create_review():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_reviews_ops

        body = request.get_json(silent=True) or {}
        result = app_reviews_ops.create_review(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/reviews", methods=["GET"])
def list_reviews():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_reviews_ops

        about = (request.args.get("user_id") or request.args.get("about") or "").strip()
        mine = str(request.args.get("mine") or "").lower() in ("1", "true", "yes")
        limit = int(request.args.get("limit") or 100)
        if mine:
            rows = app_reviews_ops.list_reviews_by_author(uid, limit=min(limit, 200))
        elif about:
            rows = app_reviews_ops.list_reviews_about(about, limit=min(limit, 200))
        else:
            return utils.get_error("user_id or mine=1 required", status=400)
        return utils.get_answer(
            "ok",
            info={"reviews": rows, "count": len(rows), "source": "postgres", "uid": uid},
        )
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications", methods=["POST"])
def create_verification():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        body = request.get_json(silent=True) or {}
        result = app_verifications_ops.create_verification(uid, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications/mine", methods=["GET"])
def list_my_verifications():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        limit = int(request.args.get("limit") or 20)
        rows = app_verifications_ops.list_mine(uid, limit=min(limit, 100))
        return utils.get_answer(
            "ok",
            info={
                "verifications": rows,
                "count": len(rows),
                "exists": len(rows) > 0,
                "source": "postgres",
                "uid": uid,
            },
        )
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications/exists", methods=["GET"])
def verification_exists():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        n = app_verifications_ops.count_mine(uid)
        return utils.get_answer(
            "ok",
            info={"exists": n > 0, "count": n, "source": "postgres", "uid": uid},
        )
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications", methods=["GET"])
def list_verifications_admin():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        app_verifications_ops._require_admin(uid)
        status = (request.args.get("status") or "").strip() or None
        limit = int(request.args.get("limit") or 100)
        rows = app_verifications_ops.list_for_admin(
            status=status, limit=min(limit, 200)
        )
        return utils.get_answer(
            "ok",
            info={"verifications": rows, "count": len(rows), "source": "postgres"},
        )
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications/<ver_id>", methods=["GET"])
def get_verification(ver_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        row = app_verifications_ops.get_verification(ver_id)
        if not row:
            return utils.get_error("not found", status=404)
        if row.get("user_id") != uid:
            app_verifications_ops._require_admin(uid)
        return utils.get_answer(
            "ok", info={"verification": row, "source": "postgres"}
        )
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications/<ver_id>/approve", methods=["POST"])
def approve_verification(ver_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        result = app_verifications_ops.approve(uid, ver_id)
        return utils.get_answer("ok", info={"result": result})
    except Exception as e:
        return _me_op_error(e)


@app.route("/verifications/<ver_id>/reject", methods=["POST"])
def reject_verification(ver_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_verifications_ops

        result = app_verifications_ops.reject(uid, ver_id)
        return utils.get_answer("ok", info={"result": result})
    except Exception as e:
        return _me_op_error(e)


@app.route("/users/<user_id>", methods=["GET"])
def get_user(user_id: str):
    _require_admin()
    data = app_pg.get_user(user_id)
    if not data:
        return utils.get_error("user not found in postgres", status=404)
    return utils.get_answer("ok", info={"user": data})


@app.route("/users", methods=["GET"])
def list_users():
    _require_admin()
    is_driver = request.args.get("is_driver")
    driver_flag = None
    if is_driver is not None:
        driver_flag = str(is_driver).lower() in ("1", "true", "yes")
    q = request.args.get("q") or request.args.get("query")
    limit = int(request.args.get("limit") or 200)
    rows = app_pg.list_users(is_driver=driver_flag, query=q, limit=min(limit, 1000))
    return utils.get_answer("ok", info={"users": rows, "count": len(rows), "source": "postgres"})


@app.route("/orders", methods=["GET"])
def list_orders():
    _require_admin()
    status = request.args.get("status")
    limit = int(request.args.get("limit") or 100)
    rows = app_pg.list_orders(status=status, limit=min(limit, 500))
    return utils.get_answer("ok", info={"orders": rows, "count": len(rows), "source": "postgres"})


@app.route("/orders/<order_id>", methods=["GET"])
def get_order(order_id: str):
    auth_header = (request.headers.get("Authorization") or "").strip()
    if auth_header.lower().startswith("bearer "):
        uid, _ = app_auth_mp.verify_firebase_uid()
        try:
            import app_order_ops

            data = app_pg.get_order(order_id)
            if not data:
                return utils.get_error("order not found", status=404)
            if not app_order_ops.order_visible_to(uid, data):
                return utils.get_error("forbidden", status=403)
            return utils.get_answer(
                "ok", info={"order": data, "uid": uid, "source": "postgres"}
            )
        except Exception as e:
            return _me_op_error(e)

    _require_admin()
    data = app_pg.get_order(order_id)
    if not data:
        return utils.get_error("order not found in postgres", status=404)
    return utils.get_answer("ok", info={"order": data})


@app.route("/orders/<order_id>", methods=["PATCH"])
def patch_order(order_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_order_ops

        body = request.get_json(silent=True) or {}
        result = app_order_ops.patch_order_by_customer(uid, order_id, body)
        return utils.get_answer("ok", info={"result": result, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/chats/ensure", methods=["POST"])
def chats_ensure():
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_chat_pg
        import app_fs_mirror

        body = request.get_json(silent=True) or {}
        if body.get("support") is True or body.get("type") == "support":
            chat = app_chat_pg.ensure_support_chat(uid)
        else:
            peer = body.get("peer_uid") or body.get("user_id") or body.get("peer")
            chat = app_chat_pg.ensure_peer_chat(uid, str(peer or ""))
        if not chat:
            raise ValueError("cannot ensure chat")

        chat_id = chat["id"]
        members = chat.get("users") or []
        support = bool(chat.get("support"))

        def _fs():
            utils.init_firebase_client()
            from firebase_admin import firestore

            db = firestore.client()
            refs = [db.collection("users").document(m) for m in members if m]
            db.collection("chats").document(chat_id).set(
                {
                    "support": support,
                    "users": refs,
                    "last_message": chat.get("last_message") or "",
                    "date_created": firestore.SERVER_TIMESTAMP,
                },
                merge=True,
            )
            if support:
                db.collection("users").document(uid).set(
                    {"chat_with_support": db.collection("chats").document(chat_id)},
                    merge=True,
                )

        app_fs_mirror.soft_fs("ensure_chat", _fs)
        return utils.get_answer("ok", info={"chat": chat, "uid": uid})
    except Exception as e:
        return _me_op_error(e)


@app.route("/chats", methods=["GET"])
def chats_list():
    uid, _ = app_auth_mp.verify_firebase_uid()
    import app_chat_pg

    support = request.args.get("support")
    flag = None
    if support is not None:
        flag = str(support).lower() in ("1", "true", "yes")
    rows = app_chat_pg.list_chats_for_user(uid, support=flag)
    return utils.get_answer("ok", info={"chats": rows, "count": len(rows), "uid": uid})


@app.route("/chats/<chat_id>/messages", methods=["GET"])
def chat_messages(chat_id: str):
    uid, _ = app_auth_mp.verify_firebase_uid()
    import app_chat_pg

    if not app_chat_pg.user_in_chat(chat_id, uid):
        return utils.get_error("forbidden", status=403)
    rows = app_chat_pg.list_messages(chat_id, limit=int(request.args.get("limit") or 50))
    return utils.get_answer("ok", info={"messages": rows, "chat_id": chat_id})


@app.route("/chats/<chat_id>/messages", methods=["POST"])
def chat_send_http(chat_id: str):
    """HTTP fallback send (также публикует в Redis → WSS)."""
    uid, _ = app_auth_mp.verify_firebase_uid()
    try:
        import app_chat_pg
        import json as _json

        if not app_chat_pg.user_in_chat(chat_id, uid):
            return utils.get_error("forbidden", status=403)
        body = request.get_json(silent=True) or {}
        text = str(body.get("text") or "")
        images = body.get("list_images") or []
        msg = app_chat_pg.insert_message(chat_id, uid, text=text, list_images=images)
        if not msg:
            raise RuntimeError("insert failed")
        try:
            import redis

            r = redis.from_url(os.environ.get("REDIS_URL", "redis://127.0.0.1:6379/0"))
            r.publish(
                "cab:chat",
                _json.dumps({"chat_id": chat_id, "message": msg}, ensure_ascii=False),
            )
        except Exception:
            pass
        return utils.get_answer("ok", info={"message": msg, "uid": uid})
    except Exception as e:
        return _me_op_error(e)
