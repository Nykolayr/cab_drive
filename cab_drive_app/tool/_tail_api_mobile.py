"""Tail nginx for mobile app API hits (non-curl)."""
from __future__ import annotations

import os
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(
    "37.252.20.248",
    username="root",
    password=os.environ["CAB_DRIVE_SSH_PASSWORD"],
    timeout=30,
)
cmd = r"""
echo '--- last 30 /api/app not curl ---'
grep '/api/app/' /var/log/nginx/access.log | grep -v 'curl/' | tail -n 30
echo '--- last 5 min timestamps with dart/http/okhttp ---'
awk -v d="$(date -d '5 minutes ago' '+%d/%b/%Y:%H:%M')" '
  $0 ~ /\/api\/app\// && $4 > "["d {
    print
  }
' /var/log/nginx/access.log | tail -n 40
echo '--- health ---'
curl -sS https://cab.artean.ru/api/app/health
"""
_, out, err = ssh.exec_command(cmd)
print((out.read() + err.read()).decode("utf-8", "replace"))
ssh.close()
