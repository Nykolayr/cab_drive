"""Simulate tinkoff mode save on VPS and inspect API."""
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

    print("=== get_model via venv ===")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && ./venv/bin/python - <<'PY'\n"
            "import settings, utils, json, os\n"
            "print('script_dir', utils.get_script_dir())\n"
            "p=os.path.join(utils.get_script_dir(),'settings_model','model.json')\n"
            "print('path', p, 'exists', os.path.exists(p))\n"
            "m=settings.get_model()\n"
            "print('before', m.tinkoff_mode, 'tariffs', len(m.driver_tariffs))\n"
            "settings.update_tinkoff_settings(mode='prod')\n"
            "m2=settings.get_model()\n"
            "print('after', m2.tinkoff_mode, 'tariffs', len(m2.driver_tariffs))\n"
            "d=json.load(open(p,encoding='utf-8'))\n"
            "print('file', d.get('tinkoff_mode'))\n"
            "# restore test for now — deploy fix will set properly\n"
            "settings.update_tinkoff_settings(mode='test')\n"
            "print('restored', settings.get_model().tinkoff_mode)\n"
            "PY",
        )
    )
    print("=== nginx kek settings ===")
    print(
        run(
            ssh,
            "grep -RIn 'kek\\|settings/tinkoff' /etc/nginx/ 2>/dev/null | head -40",
        )
    )
    print("=== mtime after test ===")
    print(run(ssh, "ls -la /root/projects/cab_drive/settings_model/model.json"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
