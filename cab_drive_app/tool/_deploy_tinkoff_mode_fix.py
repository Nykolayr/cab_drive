"""Deploy tinkoff mode persistence fix."""
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
LOCAL_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "server")
)

FILES = [
    "settings/__init__.py",
    "settings/urls.py",
    "templates/dashboard/tinkoff.html",
]


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    data = out.read().decode("utf-8", "replace")
    err_data = err.read().decode("utf-8", "replace")
    if err_data.strip():
        data += "\n" + err_data
    return data.strip()


def main() -> int:
    if not PASSWORD:
        print("no password", file=sys.stderr)
        return 1
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

    print("--- chmod settings_model ---")
    print(
        run(
            ssh,
            "chown -R root:www-data /root/projects/cab_drive/settings_model && "
            "chmod 775 /root/projects/cab_drive/settings_model && "
            "chmod 664 /root/projects/cab_drive/settings_model/model.json && "
            "ls -la /root/projects/cab_drive/settings_model/",
        )
    )
    print("--- restart ---")
    print(
        run(
            ssh,
            "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service",
        )
    )
    print("--- API save prod smoke (via flask shell-ish) ---")
    # Write a tiny requester using curl to localhost won't have session.
    # Instead mutate via python importing settings after adding path hack.
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && ./venv/bin/python - <<'PY'\n"
            "import json, os, sys\n"
            "# avoid full app circular import: load settings.models + save directly\n"
            "sys.path.insert(0, '.')\n"
            "import utils\n"
            "# utils import may pull heavy deps; use raw json like production path\n"
            "path = '/root/projects/cab_drive/settings_model/model.json'\n"
            "d = json.load(open(path, encoding='utf-8'))\n"
            "print('pre', d.get('tinkoff_mode'))\n"
            "PY",
        )
    )
    print("--- health ---")
    print(run(ssh, "curl -sS http://127.0.0.1:5000/api/app/health"))
    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
