#!/usr/bin/env python3
"""P2.1 static checks: production ApiUrls and no DEMO_MODE/SOCKET_URL in CI builds."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
API_URLS = ROOT / "lib/core/api_urls/api_urls.dart"
WORKFLOW = ROOT / ".github/workflows/mobile-release.yml"

EXPECTED_BASE = "https://api.alphatrack.app/api/v1"
EXPECTED_LIVE = "https://api.alphatrack.app/"


def main() -> int:
    errors: list[str] = []
    text = API_URLS.read_text()
    if f'liveDomain = "{EXPECTED_LIVE}"' not in text:
        errors.append(f"liveDomain must be {EXPECTED_LIVE!r}")
    if f'baseUrl = "${{liveDomain}}api/v1"' not in text and 'baseUrl = "${liveDomain}api/v1"' not in text:
        if f'baseUrl = "{EXPECTED_BASE}"' not in text and "${liveDomain}api/v1" not in text:
            errors.append(f"baseUrl must resolve to {EXPECTED_BASE}")
    if "defaultValue: liveDomain" not in text:
        errors.append("socketUrl must default to liveDomain via String.fromEnvironment")

    wf = WORKFLOW.read_text()
    build_step = re.search(r"flutter build appbundle[^\n]+", wf)
    if build_step and "DEMO_MODE" in build_step.group(0):
        errors.append("mobile-release build step must not pass DEMO_MODE")
    if build_step and "SOCKET_URL" in build_step.group(0):
        errors.append("mobile-release build step must not pass SOCKET_URL")

    for path in (ROOT / ".github/workflows").glob("*.yml"):
        content = path.read_text()
        for line in content.splitlines():
            if "dart-define" in line and "DEMO_MODE=true" in line.replace(" ", ""):
                if not line.strip().startswith("#"):
                    errors.append(f"{path.name}: DEMO_MODE=true in active dart-define")

    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 1

    print("P2.1 OK: baseUrl -> api.alphatrack.app/api/v1, socket default liveDomain")
    print("P2.1 OK: release workflow has no DEMO_MODE/SOCKET_URL dart-defines")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
