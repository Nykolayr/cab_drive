"""Dump FCM users as JSON utf-8."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)

REMOTE = """
import json, os, sys
sys.path.insert(0, "/root/projects/cab_drive")
os.chdir("/root/projects/cab_drive")
import app as _app
import app_pg

rows = []
sql = (
    "SELECT id, display_name, surname, phone_number, is_driver, updated_at "
    "FROM app_users u "
    "WHERE RIGHT(REGEXP_REPLACE(COALESCE(phone_number,''), '[^0-9]', '', 'g'), 10) <> %s "
    "AND EXISTS (SELECT 1 FROM app_user_fcm_tokens t "
    "WHERE t.user_id = u.id AND length(t.token) >= 80 AND position(':' in t.token) > 0) "
    "ORDER BY updated_at DESC NULLS LAST LIMIT 20"
)
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(sql, ("9526818276",))
        for r in cur.fetchall():
            rows.append({
                "id": r[0],
                "display_name": r[1],
                "surname": r[2],
                "phone": r[3],
                "is_driver": bool(r[4]),
                "updated_at": str(r[5]),
            })
print(json.dumps(rows, ensure_ascii=False, indent=2))
"""


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_list_fcm_json.py", "w") as f:
        f.write(REMOTE)
    sftp.close()
    _, out, err = ssh.exec_command(
        "cd /root/projects/cab_drive && timeout 60 ./venv/bin/python /tmp/_list_fcm_json.py",
        timeout=70,
    )
    data = out.read()
    err_data = err.read()
    out_path = os.path.join(os.path.dirname(__file__), "_fcm_users_out.json")
    with open(out_path, "wb") as f:
        f.write(data)
    print(data.decode("utf-8", "replace"))
    if err_data.strip():
        print(err_data.decode("utf-8", "replace"))
    print("WROTE", out_path)
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
