import json
import os
import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
REMOTE = r'''
import json, sys
sys.path.insert(0, "/root/projects/cab_drive")
import app_pg
print("on_confirmation", len(app_pg.list_orders(status="on_confirmation", limit=20)))
oid = "S2kkH7sh5v7xGUdLs830"
o = app_pg.get_order(oid) or {}
print("order", o.get("id"), o.get("status"), o.get("date_upd"))
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "select balance, current_commision from app_users where id=%s",
            ("132ipwKCpbXrRTyC2p4RNIkkf6D2",),
        )
        print("diana_wallet", cur.fetchone())
print("APP_FS_MIRROR check via health done separately")
'''

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
sftp = ssh.open_sftp()
with sftp.file("/tmp/_smoke2.py", "w") as f:
    f.write(REMOTE)
sftp.close()
_, out, err = ssh.exec_command(
    "cd /root/projects/cab_drive && ./venv/bin/python /tmp/_smoke2.py; "
    "journalctl -u cab.service --since '10 min ago' --no-pager | "
    "grep -E 'AUTO-COMPLETE|AUTO-HIDE|on_confirmation' | tail -20",
    timeout=60,
)
print(out.read().decode("utf-8", "replace")[:4000])
e = err.read().decode("utf-8", "replace")
if e.strip():
    print("ERR", e[:1500])
ssh.close()
