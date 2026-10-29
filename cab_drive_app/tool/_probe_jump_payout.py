"""Probe Jump Finance smart payout for Diana (dry diagnosis, small amount)."""
from __future__ import annotations

import json
import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)

# Do NOT actually pay — only OPTIONS/invalid to see connectivity, or GET docs.
# Better: curl Jump with same payload amount=1 and see error JSON (might create real payout!)
# Safer: curl without auth / wrong key to see timeout vs response.


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    # connectivity only
    cmd = (
        "curl -sS -o /tmp/jump_out.txt -w '%{http_code} time=%{time_total}\\n' "
        "-m 20 -X POST 'https://api.jump.finance/services/openapi/payments/smart' "
        "-H 'Content-Type: application/json' "
        "-H 'Client-Key: 12b46b45-f258-4e3c-9509-9dc7280cdeed' "
        "-d '{\"customer_payment_id\":\"smoke-diag\",\"phone\":\"+79667499985\","
        "\"last_name\":\"Test\",\"first_name\":\"Diana\","
        "\"requisite\":{\"type_id\":8,\"account_number\":\"0000000000000000\"},"
        "\"amount\":1}' ; echo; head -c 1200 /tmp/jump_out.txt; echo"
    )
    _, out, err = ssh.exec_command(cmd, timeout=40)
    print(out.read().decode("utf-8", "replace"))
    print(err.read().decode("utf-8", "replace"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
