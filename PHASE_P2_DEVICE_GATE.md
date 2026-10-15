# P2 device gate — Steps 1–3 (Play internal)

Use this runbook after **Mobile release** uploads a build from **`main`** with P0/P1 (commit `99fd8d4` or later). Tag **`v1.0.4`** points at an older commit **without** P0/P1 — prefer **`v1.0.5+`** for this gate.

## Install

1. Play Console → **Internal testing** → install latest build (from tag `v1.0.5` or newer).
2. Or: GitHub → **Actions** → **Mobile release** → download artifact `android-{version}-{build_number}`.
3. **Clear app data** or uninstall before Step 1 (no saved token).

Record results in [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md).

## Step 1 — Cold start

| Check | Pass when |
|-------|-----------|
| Cold start | Onboarding or login (not home with Marc G. / demo banner) |
| No token | Cannot reach home without login |

## Step 2 — Hosts (Logcat during login + home)

Filter: `api.alphatrack.app`, `alphatrack`, `socket` — **do not** log or paste JWTs.

| Check | Pass when |
|-------|-----------|
| REST | Requests to `api.alphatrack.app` |
| Socket | Production host (not `88.198.112.109` or custom dev URL) |
| Logs | No JWT substrings in log output |

## Step 3 — Smoke (prod employee account)

| Flow | Pass when |
|------|-----------|
| Login → home | Your real projects |
| Project → Notes | API notes or empty (not demo lawn copy) |
| Create note | Saves via API; list refreshes |
| Profile | Your name/email |
| Notifications | API inbox or empty (not demo Marc inbox) |

**Optional P2.3:** Airplane mode on Notifications or Profile → error/empty, not `DemoData` strings.

## Sign-off

When Steps 1–3 pass, check **Go** or **Go with limits** in [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) and add developer/client names and date.
