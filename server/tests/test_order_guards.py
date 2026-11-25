"""Гарды статусной машины заказа (app_order_ops).

Юнит-тесты без БД: _load_order и PG/FS-записи замоканы через
monkeypatch. Поймал бы баг: клиент мог отменить заказ в
on_confirmation (водитель завершил → без выплаты).
"""
import pytest

app_order_ops = pytest.importorskip("app_order_ops")


@pytest.fixture
def order_state(monkeypatch):
    """Фабрика: order_state(status=..., user_customer='cust', selected_driver='drv')."""
    holder = {"user_customer": "cust", "selected_driver": "drv"}

    def make(**fields):
        holder.update(fields)
        return dict(holder)

    monkeypatch.setattr(app_order_ops, "_load_order", lambda oid: dict(holder))
    monkeypatch.setattr(
        app_order_ops.app_pg, "mirror_order_fields", lambda *a, **k: True
    )
    monkeypatch.setattr(
        app_order_ops.app_pg, "mirror_user_queue_add", lambda *a, **k: True
    )
    monkeypatch.setattr(
        app_order_ops.app_pg, "mirror_user_queue_remove", lambda *a, **k: True
    )
    monkeypatch.setattr(
        app_order_ops.app_fs_mirror, "soft_fs", lambda *a, **k: None
    )
    return make


CANCELLABLE = ["newOrder", "spec_set", "place_pickup", "at_work", "place_delivery"]


class TestCancelByCustomer:
    @pytest.mark.parametrize("status", CANCELLABLE)
    def test_cancel_allowed(self, order_state, status):
        order_state(status=status)
        res = app_order_ops.cancel_order_by_customer("cust", "oid")
        assert res["status"] == "cancelled"

    def test_cancel_blocked_on_confirmation(self, order_state):
        # Регресс: водитель завершил → клиент отменял → без выплаты.
        order_state(status="on_confirmation")
        with pytest.raises(ValueError, match="отменить"):
            app_order_ops.cancel_order_by_customer("cust", "oid")

    @pytest.mark.parametrize("status", ["completed", "cancelled", "hidden"])
    def test_cancel_already_terminal(self, order_state, status):
        order_state(status=status)
        res = app_order_ops.cancel_order_by_customer("cust", "oid")
        assert res.get("already") is True

    def test_cancel_only_owner(self, order_state):
        order_state(status="newOrder")
        with pytest.raises(ValueError, match="customer"):
            app_order_ops.cancel_order_by_customer("stranger", "oid")


class TestSetOrderStatusByDriver:
    @pytest.mark.parametrize(
        "status",
        ["spec_set", "place_pickup", "at_work", "place_delivery",
         "on_confirmation", "cancelled"],
    )
    def test_allowed_statuses(self, order_state, status):
        order_state(status="at_work")
        res = app_order_ops.set_order_status("drv", "oid", status)
        assert res["status"] == status

    @pytest.mark.parametrize("status", ["newOrder", "completed", "hidden", "bogus"])
    def test_forbidden_statuses(self, order_state, status):
        order_state(status="at_work")
        with pytest.raises(ValueError, match="not allowed"):
            app_order_ops.set_order_status("drv", "oid", status)

    def test_only_selected_driver(self, order_state):
        order_state(status="at_work")
        with pytest.raises(ValueError, match="selected driver"):
            app_order_ops.set_order_status("other_driver", "oid", "at_work")


class TestAcceptBid:
    def test_only_order_customer(self, order_state):
        order_state(status="newOrder", user_customer="cust")
        with pytest.raises(ValueError, match="customer"):
            app_order_ops.accept_bid("stranger", "oid", "drv")

    def test_idempotent_same_driver(self, order_state):
        order_state(status="spec_set", user_customer="cust",
                    selected_driver="drv")
        res = app_order_ops.accept_bid("cust", "oid", "drv")
        assert res.get("already") is True
