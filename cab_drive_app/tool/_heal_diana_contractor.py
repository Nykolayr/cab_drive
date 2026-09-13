import os
import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
    or "wZX++X-+TJ7kqn"
)
sql = (
    "UPDATE app_users SET contractor_id = 21746092 "
    "WHERE id = '132ipwKCpbXrRTyC2p4RNIkkf6D2' "
    "RETURNING id, phone_number, balance, contractor_id;"
)
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
cmd = f'psql "$(cat /root/cab_drive_database_url.txt)" -c "{sql}"'
_, out, err = ssh.exec_command(cmd, timeout=30)
print(out.read().decode("utf-8", "replace"))
print(err.read().decode("utf-8", "replace"))
ssh.close()
