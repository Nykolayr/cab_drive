"""Confirm Jump payment(s) via POST /payments/confirm."""
from __future__ import annotations

import json
import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
KEY = "12b46b45-f258-4e3c-9509-9dc7280cdeed"
PAYMENT_IDS = sys.argv[1:] if len(sys.argv) > 1 else ["182024002"]


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    pid_str = ",".join(PAYMENT_IDS)
    body = json.dumps({"payment_id": pid_str})
    cmd = (
        "curl -sS -w '\\nHTTP %{http_code}\\n' -X POST "
        "'https://api.jump.finance/services/openapi/payments/confirm' "
        "-H 'Accept: application/json' -H 'Content-Type: application/json' "
        f"-H 'Client-Key: {KEY}' -d '{body}'"
    )
    _, out, err = ssh.exec_command(cmd, timeout=60)
    text = out.read().decode("utf-8", "replace")
    print(text)
    e = err.read().decode("utf-8", "replace").strip()
    if e:
        print("STDERR", e)

    # poll payment status
    for pid in PAYMENT_IDS:
        cmd2 = (
            "curl -sS "
            f"'https://api.jump.finance/services/openapi/payments/{pid}' "
            "-H 'Accept: application/json' "
            f"-H 'Client-Key: {KEY}'"
        )
        _, o2, _ = ssh.exec_command(cmd2, timeout=30)
        print("STATUS", pid, o2.read().decode("utf-8", "replace")[:1500])

    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
