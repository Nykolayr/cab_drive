"""Server logs for payout / Diana phone around withdrawal."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 60) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    print("=== journal payout/tinkoff/cards last 2d ===")
    print(
        run(
            ssh,
            "journalctl -u cab.service --since '2 days ago' --no-pager 2>/dev/null | "
            "grep -iE 'payout|withdraw|132ipwKCpbXrRTyC2p4RNIkkf6D2|GetCardList|Payment|cards|sposob|profile|error|Exception|Traceback' | "
            "tail -80",
        )
    )
    print("=== tinkoff events ===")
    print(
        run(
            ssh,
            "tail -n 80 /root/projects/cab_drive/tinkoff_events.jsonl 2>/dev/null | "
            "python3 -c \"import sys,json\\n"
            "for line in sys.stdin:\\n"
            "  line=line.strip()\\n"
            "  if not line: continue\\n"
            "  try: d=json.loads(line)\\n"
            "  except: print(line[:200]); continue\\n"
            "  t=d.get('type') or d.get('event') or ''\\n"
            "  print(d.get('ts',''), t, d.get('level',''), str(d.get('message') or d.get('error') or '')[:120], d.get('orderId') or d.get('paymentId') or '')\\n\"",
        )
    )
    print("=== diana cards/balance ===")
    print(
        run(
            ssh,
            'psql "$(cat /root/cab_drive_database_url.txt)" -c '
            "\"SELECT id, display_name, balance, bonus_balance, phone_number FROM app_users WHERE id='132ipwKCpbXrRTyC2p4RNIkkf6D2'; "
            "SELECT id, user_id, left(card_id::text,20), pan, status FROM app_saved_cards WHERE user_id='132ipwKCpbXrRTyC2p4RNIkkf6D2' LIMIT 10;\"",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
