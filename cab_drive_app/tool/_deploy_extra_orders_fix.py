"""Deploy extra_orders.py + smoke price_changed FCM to Diana."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
LOCAL = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "server", "orders", "extra_orders.py")
)
REMOTE = "/root/projects/cab_drive/orders/extra_orders.py"


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    print("put", LOCAL, "->", REMOTE)
    sftp.put(LOCAL, REMOTE)
    sftp.close()
    _, o, e = ssh.exec_command(
        "systemctl restart cab.service && sleep 3 && systemctl is-active cab.service",
        timeout=60,
    )
    print((o.read() + e.read()).decode())

    py = r'''
import app as _a
import app_push
import app_pg

uid = "132ipwKCpbXrRTyC2p4RNIkkf6D2"
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT user_id, length(token) FROM app_user_fcm_tokens WHERE user_id=%s", (uid,))
        print("tokens", cur.fetchall())

r = app_push.notify(
    "price_changed_smoke",
    [uid],
    title="Цена заказа изменилась",
    body="Заказчик изменил цену до 999 ₽ (smoke)",
    initial_page_name="order_Page_Driver",
    parameter_data={"order": "Knz2zRrI126hEFrtDXrh"},
    data={"order_id": "Knz2zRrI126hEFrtDXrh", "event": "price_changed"},
)
print("notify_result", r)

from orders.extra_orders import ACTIVE_ORDER_STATUSES
print("ACTIVE_ORDER_STATUSES", ACTIVE_ORDER_STATUSES)
'''
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_smoke_price_fcm.py", "w") as f:
        f.write(py)
    sftp.close()
    _, o2, e2 = ssh.exec_command(
        "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
        "./venv/bin/python /tmp/_smoke_price_fcm.py",
        timeout=60,
    )
    print(o2.read().decode("utf-8", "replace"))
    print(e2.read().decode("utf-8", "replace")[-800:])
    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
