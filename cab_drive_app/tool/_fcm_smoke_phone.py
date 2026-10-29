"""Find user by phone and send test FCM; print raw result."""
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


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 120) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    remote = r'''
import json, os, sys
sys.path.insert(0, "/root/projects/cab_drive")
os.chdir("/root/projects/cab_drive")

import app as _app  # noqa: F401
import app_pg
import app_fcm_ops

phone_digits = "79526818276"
uids = []
with app_pg.connection() as conn:
    if conn is None:
        print("NO_DB")
        sys.exit(1)
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, phone_number, display_name
            FROM app_users
            WHERE RIGHT(REGEXP_REPLACE(COALESCE(phone_number,''), '[^0-9]', '', 'g'), 10)
                  = RIGHT(%s, 10)
            LIMIT 10
            """,
            (phone_digits,),
        )
        users = cur.fetchall()
        print("USERS", users)
        if not users:
            print("NO_USER")
            sys.exit(2)
        uids = [u[0] for u in users]
        cur.execute(
            "SELECT user_id, left(token,24), length(token) FROM app_user_fcm_tokens WHERE user_id = ANY(%s)",
            (uids,),
        )
        toks = cur.fetchall()
        print("TOKENS", toks)

result = app_fcm_ops.send_to_users(
    uids,
    title="Cab Drive тест",
    body="Проверка пуша с сервера. Если видишь — FCM доходит.",
    data={"event": "smoke_test"},
)
print("RESULT", json.dumps(result, ensure_ascii=False, default=str))
'''
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_fcm_smoke_phone.py", "w") as f:
        f.write(remote)
    sftp.close()

    print("=== smoke ===")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && timeout 90 ./venv/bin/python /tmp/_fcm_smoke_phone.py",
            timeout=100,
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
