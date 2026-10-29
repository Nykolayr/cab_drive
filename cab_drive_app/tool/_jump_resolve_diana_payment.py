"""Try Jump API actions on Diana pending payment #182024002."""
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
KEY = "12b46b45-f258-4e3c-9509-9dc7280cdeed"
PID = "182024002"
BASE = "https://api.jump.finance/services/openapi"


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    script = rf'''
import json, urllib.request, urllib.error
KEY="{KEY}"
PID="{PID}"
BASE="{BASE}"
H={{"Accept":"application/json","Content-Type":"application/json","Client-Key":KEY}}

def req(method, url, body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(url, data=data, headers=H, method=method)
    try:
        with urllib.request.urlopen(r, timeout=45) as resp:
            b = resp.read().decode("utf-8","replace")
            return resp.status, b[:2000]
    except urllib.error.HTTPError as e:
        b = e.read().decode("utf-8","replace")
        return e.code, b[:2000]
    except Exception as e:
        return 0, str(e)

# current state
for u in [
    f"{{BASE}}/payments/{{PID}}?include=abilities,history",
]:
    st, b = req("GET", u)
    print("GET", u, st, b[:1200])
    print("---")

actions = [
    ("POST", f"{{BASE}}/payments/{{PID}}/approve", {{}}),
    ("POST", f"{{BASE}}/payments/{{PID}}/confirm", {{}}),
    ("POST", f"{{BASE}}/payments/{{PID}}/pay", {{}}),
    ("POST", f"{{BASE}}/payments/{{PID}}/start", {{}}),
    ("POST", f"{{BASE}}/payments/{{PID}}/cancel", {{}}),
    ("DELETE", f"{{BASE}}/payments/{{PID}}", None),
]
for method, url, body in actions:
    st, b = req(method, url, body)
    print(method, url, st, b[:800])
    print("---")
'''
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_jump_resolve.py", "w") as f:
        f.write(script)
    sftp.close()
    _, out, err = ssh.exec_command("python3 /tmp/_jump_resolve.py", timeout=120)
    print(out.read().decode("utf-8", "replace"))
    e = err.read().decode("utf-8", "replace").strip()
    if e:
        print("STDERR", e)
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
