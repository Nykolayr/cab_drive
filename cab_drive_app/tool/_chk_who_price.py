import os
import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_SSH_PASSWORD")
PY = r'''
import app as _a
import app_pg
from app_order_ops import _load_order, _ref_uid

oid = "xZJgOmiHnWaTfijtCkoN"
lo = _load_order(oid)
who = lo.get("user_who_responced") or lo.get("userWhoResponced")
print("who", who)
print("uids", [_ref_uid(x) for x in (who or [])])
print("cp", lo.get("currentPrice"), lo.get("budget"), lo.get("status"))
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "SELECT user_id, length(token), updated_at FROM app_user_fcm_tokens WHERE user_id=%s",
            ("132ipwKCpbXrRTyC2p4RNIkkf6D2",),
        )
        print("fcm_diana", cur.fetchall())
        cur.execute(
            "SELECT id, budget, current_price, user_who_responced FROM app_orders WHERE id=%s",
            (oid,),
        )
        print("row", cur.fetchone())
'''

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
sftp = ssh.open_sftp()
with sftp.file("/tmp/_chk_who.py", "w") as f:
    f.write(PY)
sftp.close()
_, out, err = ssh.exec_command(
    "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
    "./venv/bin/python /tmp/_chk_who.py",
    timeout=60,
)
print(out.read().decode("utf-8", "replace"))
print(err.read().decode("utf-8", "replace")[-1200:])
ssh.close()
