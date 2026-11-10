"""Deploy ByteHand SMS auth: bytehand module + users api/view/models + config keys."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
)
ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "server")
)
REMOTE = "/root/projects/cab_drive"

FILES = [
    ("bytehand/__init__.py", "bytehand/__init__.py"),
    ("users/api.py", "users/api.py"),
    ("users/view.py", "users/view.py"),
    ("users/models.py", "users/models.py"),
]


def run(ssh, cmd, timeout=60):
    _, o, e = ssh.exec_command(cmd, timeout=timeout)
    out = (o.read() + e.read()).decode()
    print(f"$ {cmd}\n{out}")
    return out


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    sftp = ssh.open_sftp()
    run(ssh, f"mkdir -p {REMOTE}/bytehand")
    for local_rel, remote_rel in FILES:
        local = os.path.join(ROOT, local_rel)
        remote = f"{REMOTE}/{remote_rel}"
        print("put", local, "->", remote)
        sftp.put(local, remote)
    sftp.close()

    # Ключи в config.py на VPS — добавляем только если их там ещё нет.
    add_cfg = (
        "grep -q BYTEHAND_API_KEY /root/projects/cab_drive/config.py || "
        "printf '\\n    BYTEHAND_API_KEY = \"8GzT7vodF67q96G8k4PivuC2Fp940JPh\"\\n"
        "    BYTEHAND_SENDER = \"SMS-INFO\"\\n' >> /root/projects/cab_drive/config.py"
    )
    run(ssh, add_cfg)
    run(ssh, "grep -n BYTEHAND /root/projects/cab_drive/config.py | sed 's/=.*/= ***/'")

    run(ssh, "cd /root/projects/cab_drive && python3 -c 'import bytehand; print(\"import ok\")'")
    run(ssh, "systemctl restart cab.service && sleep 3 && systemctl is-active cab.service")
    run(ssh, "curl -sS http://127.0.0.1:5000/api/app/health")

    # Smoke: auth на тест-номер (SMS не шлётся — ветка тестовых номеров).
    run(
        ssh,
        "curl -sS -X POST http://127.0.0.1:5000/kek/users/auth "
        "-F phone=9001112233",
    )
    # Smoke: resend — должен ответить ok без реальной отправки (тест-номер).
    run(
        ssh,
        "curl -sS -X POST http://127.0.0.1:5000/kek/users/auth_resend "
        "-H 'Content-Type: application/json' -d '{\"phone\": \"9001112233\"}'",
    )
    # Smoke: живой вызов bytehand._send с тестового скрипта — проверка ключа/связи.
    # Комментируем реальную отправку: вместо этого делаем только проверку ключа
    # валидным запросом на невалидный номер — создаст сообщение в очереди BH.
    run(
        ssh,
        "cd /root/projects/cab_drive && python3 -c '"
        "import bytehand\n"
        "r = bytehand._send(\"+70000000000\", \"test\")\n"
        "print(\"bytehand_probe\", r)\n'",
    )

    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
