"""Test tinkoff save via app import; grep access logs."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD") or os.environ.get(
    "CAB_SSH_PASSWORD", ""
)


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    print("=== save via app import ===")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && ./venv/bin/python - <<'PY'\n"
            "import app  # noqa: F401 — init graph\n"
            "import settings, utils, json, os\n"
            "p=os.path.join(utils.get_script_dir(),'settings_model','model.json')\n"
            "print('path', p)\n"
            "print('before', settings.get_model().tinkoff_mode)\n"
            "settings.update_tinkoff_settings(mode='prod')\n"
            "print('after_mem', settings.get_model().tinkoff_mode)\n"
            "print('after_file', json.load(open(p,encoding='utf-8')).get('tinkoff_mode'))\n"
            "import os as _os\n"
            "print('mtime', _os.path.getmtime(p))\n"
            "PY",
        )
    )
    print("=== access logs settings/tinkoff ===")
    print(
        run(
            ssh,
            "grep -h 'settings/tinkoff' /var/log/nginx/access.log /var/log/nginx/access.log.* 2>/dev/null | tail -30; "
            "journalctl -u cab.service --since '14 days ago' --no-pager 2>/dev/null | grep -i 'settings/tinkoff\\|update_tinkoff\\|tinkoff_mode' | tail -30",
        )
    )
    print("=== ls model ===")
    print(run(ssh, "ls -la /root/projects/cab_drive/settings_model/model.json; grep tinkoff /root/projects/cab_drive/settings_model/model.json"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
