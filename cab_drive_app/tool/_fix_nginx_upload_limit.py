"""Set client_max_body_size 20m for cab.artean.ru nginx site, test+reload, verify upload."""
from __future__ import annotations

import os
import sys

import paramiko

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
    or "wZX++X-+TJ7kqn"
)

CONF = "/etc/nginx/sites-available/cab.artean.ru"

CMDS = [
    ("backup conf", f"cp {CONF} {CONF}.bak_$(date +%Y%m%d_%H%M%S) && ls -la {CONF}*"),
    (
        "insert client_max_body_size",
        f"grep -q 'client_max_body_size' {CONF} || sed -i '0,/server_name cab.artean.ru;/s//server_name cab.artean.ru;\\n    client_max_body_size 20m;/' {CONF}; grep -n 'client_max_body_size\\|server_name' {CONF}",
    ),
    ("nginx -t", "nginx -t"),
    ("reload", "systemctl reload nginx && echo reloaded"),
    (
        "verify 2MB upload",
        "head -c 2000000 /dev/urandom > /tmp/big.bin && curl -s -o /tmp/up2.json -w 'HTTP %{http_code}\\n' -F 'file=@/tmp/big.bin' https://cab.artean.ru/kek/files/upload; cat /tmp/up2.json; echo; rm -f /tmp/big.bin /tmp/up2.json /tmp/t.txt /tmp/up.json",
    ),
    ("cleanup test file", "uuid=$(ls -t /root/projects/cab_drive/storage/*.bin 2>/dev/null | head -1); [ -n \"$uuid\" ] && rm -f \"$uuid\" && echo removed $uuid || echo 'no .bin in storage'"),
]


def main() -> int:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(HOST, username=USER, password=PASSWORD, timeout=90)
    rc = 0
    for name, cmd in CMDS:
        print(f"\n===== {name} =====")
        stdin, stdout, stderr = client.exec_command(cmd)
        out = stdout.read().decode("utf-8", "replace").strip()
        err = stderr.read().decode("utf-8", "replace").strip()
        code = stdout.channel.recv_exit_status()
        print(out or "(no output)")
        if err:
            print(f"stderr: {err[:400]}", file=sys.stderr)
        if name == "nginx -t" and code != 0:
            print("ABORT: nginx -t failed, not reloading", file=sys.stderr)
            rc = 1
            break
        if name == "verify 2MB upload" and "200" not in out:
            print("WARN: 2MB upload still not 200", file=sys.stderr)
            rc = 2
    client.close()
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
