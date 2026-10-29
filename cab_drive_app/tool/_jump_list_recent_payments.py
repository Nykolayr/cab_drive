"""List recent Jump payments for Diana / phone search (no SSH)."""
from __future__ import annotations

import json
import os
import urllib.error
import urllib.request

KEY = (
    os.environ.get("JUMP_CLIENT_KEY")
    or "12b46b45-f258-4e3c-9509-9dc7280cdeed"
)
BASE = "https://api.jump.finance/services/openapi"


def req(url: str) -> tuple[int, str]:
    r = urllib.request.Request(
        url,
        headers={
            "Accept": "application/json",
            "Client-Key": KEY,
        },
        method="GET",
    )
    try:
        with urllib.request.urlopen(r, timeout=45) as resp:
            return resp.status, resp.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")
    except Exception as e:
        return 0, str(e)


def main() -> int:
    urls = [
        f"{BASE}/payments?limit=20&include=abilities",
        f"{BASE}/payments?limit=20&status_id=4&include=abilities",
        f"{BASE}/payments?limit=20&status_id=7&include=abilities",
        f"{BASE}/payments/182024002?include=abilities,history",
        f"{BASE}/contractors?search=79667499985",
        f"{BASE}/contractors?search=Диана",
    ]
    for u in urls:
        code, body = req(u)
        print("===", code, u)
        print(body[:2500])
        print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
