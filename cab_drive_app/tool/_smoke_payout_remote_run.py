"""Smoke payout validation on VPS via paramiko."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
    or "wZX++X-+TJ7kqn"
)


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 90) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def safe_print(text: str) -> None:
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode("utf-8", "replace").decode("ascii", "replace"))


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    safe_print("--- http no auth ---")
    safe_print(
        run(
            ssh,
            "curl -sS -w '\\nHTTP %{http_code}\\n' -X POST "
            "http://127.0.0.1:5000/api/app/me/payout "
            "-H 'Content-Type: application/json' -d '{}'",
        )
    )

    safe_print("--- python smoke ---")
    safe_print(
        run(
            ssh,
            "cd /root/projects/cab_drive && ./venv/bin/python - <<'PY'\n"
            "import app as _a\n"
            "import app_payout_ops as p\n"
            "import app_pg\n"
            "print('comm200', p.payout_commission(200), 'amt', p.amount_to_card(200))\n"
            "try:\n"
            "    p.create_payout('nonexistent-uid', pan='4111111111111111')\n"
            "except Exception as e:\n"
            "    print('missing_user', type(e).__name__, repr(str(e)[:160]))\n"
            "conn = app_pg.connection()\n"
            "try:\n"
            "    with conn.cursor() as cur:\n"
            "        cur.execute(\n"
            "            'SELECT id, phone_number, balance, contractor_id FROM app_users '\n"
            "            \"WHERE phone_number LIKE %s LIMIT 2\",\n"
            "            ('%9667499985%',),\n"
            "        )\n"
            "        cols = [d[0] for d in cur.description]\n"
            "        rows = [dict(zip(cols, r)) for r in cur.fetchall()]\n"
            "finally:\n"
            "    conn.close()\n"
            "print('diana', rows)\n"
            "if rows:\n"
            "    uid = rows[0]['id']\n"
            "    try:\n"
            "        p.create_payout(uid, pan='1234')\n"
            "    except Exception as e:\n"
            "        print('short_pan', type(e).__name__, repr(str(e)[:160]))\n"
            "print('OK')\n"
            "PY",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
