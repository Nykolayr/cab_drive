"""Smoke push to Diana Test and Natalya Test."""
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
import app_push

targets = [
    ("132ipwKCpbXrRTyC2p4RNIkkf6D2", "Диана Тест", "+79667499985"),
    ("4EFSVlkodRUv5BrnSJQUS6kjmom1", "Наталья Тест", "+79918783116"),
]
for uid, name, phone in targets:
    r = app_push.notify(
        "smoke_test",
        [uid],
        title="Cab Drive тест",
        body="Тестовый пуш. Если видите — уведомления доходят.",
        data={"event": "smoke_test"},
    )
    print(json.dumps({"name": name, "phone": phone, "uid": uid, "result": r}, ensure_ascii=False))
"""


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_fcm_diana_natalya.py", "w") as f:
        f.write(REMOTE)
    sftp.close()
    _, out, err = ssh.exec_command(
        "cd /root/projects/cab_drive && timeout 90 ./venv/bin/python /tmp/_fcm_diana_natalya.py",
        timeout=100,
    )
    data = out.read().decode("utf-8", "replace")
    err_data = err.read().decode("utf-8", "replace")
    out_path = os.path.join(os.path.dirname(__file__), "_fcm_diana_natalya_out.json")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(data)
    print(data)
    if err_data.strip():
        print(err_data)
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
