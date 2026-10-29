"""Deploy app_push + FCM token fix + purge + smoke to phone."""
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
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_push.py",
    "app_fcm_ops.py",
    "app_pg.py",
    "app_order_ops.py",
    "app_bids_ops.py",
    "app_chat_pg.py",
    "app_data/__init__.py",
    "scripts/migrate_firestore_to_postgres.py",
]


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 120) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    for rel in FILES:
        local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
        remote = f"{REMOTE_ROOT}/{rel}"
        print(f"put {rel}")
        sftp.put(local, remote)
    sftp.close()

    print("--- purge bad tokens ---")
    print(
        run(
            ssh,
            'psql "$(cat /root/cab_drive_database_url.txt)" -c '
            "\"DELETE FROM app_user_fcm_tokens WHERE length(token) < 80 OR position(':' in token) = 0; "
            "SELECT COUNT(*) AS left_tokens FROM app_user_fcm_tokens;\"",
        )
    )
    print("--- restart ---")
    print(
        run(
            ssh,
            "systemctl restart cab.service cab-wss.service && sleep 3 && "
            "systemctl is-active cab.service cab-wss.service",
        )
    )
    print("--- health ---")
    print(run(ssh, "curl -sS http://127.0.0.1:5000/api/app/health"))

    smoke = r'''
import json, os, sys
sys.path.insert(0, "/root/projects/cab_drive")
os.chdir("/root/projects/cab_drive")
import app as _app  # noqa
import app_push
print("PURGE", app_push.purge_invalid_tokens())
print("SMOKE", json.dumps(app_push.smoke_to_phone("+79526818276", title="Cab Drive тест #2", body="Если видишь это — пуш с сервера доходит."), ensure_ascii=False))
'''
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_fcm_smoke2.py", "w") as f:
        f.write(smoke)
    sftp.close()
    print("--- smoke #2 ---")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && timeout 90 ./venv/bin/python /tmp/_fcm_smoke2.py",
            timeout=100,
        )
    )
    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
