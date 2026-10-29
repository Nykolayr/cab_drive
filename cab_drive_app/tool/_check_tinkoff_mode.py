"""Check tinkoff_mode on VPS."""
from __future__ import annotations

import json
import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD") or os.environ.get(
    "CAB_SSH_PASSWORD", ""
)
if not PASSWORD:
    PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD") or os.environ.get("CAB_SSH_PASSWORD")


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    data = out.read().decode("utf-8", "replace")
    err_data = err.read().decode("utf-8", "replace")
    if err_data.strip():
        data += "\n" + err_data
    return data.strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    print("=== find model.json ===")
    print(run(ssh, "find /root/projects/cab_drive -name model.json 2>/dev/null"))
    print("=== ls settings_model ===")
    print(run(ssh, "ls -la /root/projects/cab_drive/settings_model/ 2>/dev/null"))
    print("=== tinkoff fields ===")
    print(
        run(
            ssh,
            "python3 - <<'PY'\n"
            "import json\n"
            "p='/root/projects/cab_drive/settings_model/model.json'\n"
            "d=json.load(open(p,encoding='utf-8'))\n"
            "print('tinkoff_mode=', d.get('tinkoff_mode'))\n"
            "print('payments_base_url=', d.get('payments_base_url'))\n"
            "print('has_tinkoff_mode', 'tinkoff_mode' in d)\n"
            "PY",
        )
    )
    print("=== models.py on server ===")
    print(
        run(
            ssh,
            "grep -n tinkoff /root/projects/cab_drive/settings/models.py "
            "/root/projects/cab_drive/settings/__init__.py 2>/dev/null",
        )
    )
    print("=== get_script_dir via flask ===")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && python3 - <<'PY'\n"
            "import utils, settings\n"
            "print('script_dir=', utils.get_script_dir())\n"
            "m=settings.get_model()\n"
            "print('mode=', m.tinkoff_mode)\n"
            "print('url=', m.payments_base_url)\n"
            "PY",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
