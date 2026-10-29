"""Direct JSON write test + leave mode readable."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)

REMOTE_PY = r"""
import json, os
path = "/root/projects/cab_drive/settings_model/model.json"
with open(path, encoding="utf-8") as f:
    d = json.load(f)
print("before", d.get("tinkoff_mode"), "mtime", os.path.getmtime(path))
d["tinkoff_mode"] = "prod"
if not d.get("payments_base_url"):
    d["payments_base_url"] = "https://cab.artean.ru"
tmp = path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(d, f, ensure_ascii=False, indent=3)
    f.write("\n")
os.replace(tmp, path)
with open(path, encoding="utf-8") as f:
    d2 = json.load(f)
print("after", d2.get("tinkoff_mode"), "mtime", os.path.getmtime(path))
"""


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_tinkoff_mode_write.py", "w") as f:
        f.write(REMOTE_PY)
    sftp.close()
    _, out, err = ssh.exec_command("python3 /tmp/_tinkoff_mode_write.py")
    print(out.read().decode("utf-8", "replace"))
    print(err.read().decode("utf-8", "replace"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
