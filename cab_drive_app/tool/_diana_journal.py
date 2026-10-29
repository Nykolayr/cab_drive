import paramiko
import os

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(
    "37.252.20.248",
    username="root",
    password=os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   ,
    timeout=90,
    allow_agent=False,
    look_for_keys=False,
)
cmd = (
    "journalctl -u cab.service --since '2026-09-16' --until '2026-09-20' --no-pager "
    "| grep -E '132ipwKCpbXrRTyC2p4RNIkkf6D2|9270463268|9257426487|56da23bf|cb75d0bb|balance' "
    "| tail -n 100"
)
_, o, e = ssh.exec_command(cmd, timeout=90)
print((o.read() + e.read()).decode("utf-8", "replace")[:12000])
ssh.close()
