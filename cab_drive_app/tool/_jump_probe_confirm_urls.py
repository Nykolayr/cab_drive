import os
import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_SSH_PASSWORD")
KEY = "12b46b45-f258-4e3c-9509-9dc7280cdeed"
BODY = '{"payment_id":"182024002"}'
URLS = [
    "https://api.jump.finance/services/openapi/payments/confirm",
    "https://api.jump.finance/openapi/payments/confirm",
    "https://api.jump.finance/1c-api/payments/confirm",
    "https://api.jump.finance/services/1c-api/payments/confirm",
    "https://api.jump.finance/services/openapi/v1/payments/confirm",
    "https://api.jump.finance/services/openapi/payments/182024002/confirm",
]

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
for u in URLS:
    cmd = (
        f"curl -sS -w '\\nHTTP %{{http_code}}\\n' -X POST '{u}' "
        f"-H 'Client-Key: {KEY}' -H 'Content-Type: application/json' -d '{BODY}'"
    )
    _, out, _ = ssh.exec_command(cmd, timeout=30)
    print("===", u)
    print(out.read().decode("utf-8", "replace")[:500])
ssh.close()
