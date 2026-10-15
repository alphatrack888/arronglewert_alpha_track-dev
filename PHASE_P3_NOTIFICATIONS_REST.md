# P3 — Notifications REST (device verification)

**Build:** Play **internal testing** from tag **`v1.0.6+`** (includes P3 pagination/retry fixes) or **`v1.0.5`** for baseline. No `DEMO_MODE`.

**Account:** Production employee login (not `marc@demo.co`).

Record results in [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) §4.3 **Notifications REST** row.

---

## Prerequisites

- Inbox with **more than 20** notifications if you need to prove pagination (otherwise note **N/A — sparse inbox** and use API logs for `page=2`).
- Logcat: filter `notifications` or Dio paths — **do not** paste JWTs.

---

## Checklist

| Step | Pass when | Result | Evidence |
|------|-----------|--------|----------|
| Inbox load | Real API list or empty (no demo Marc inbox) | Pending device | |
| Pagination | Scroll to bottom → more items; page 2 IDs ≠ page 1 when total > 20 | Pending device | |
| Mark one read | Details/long-press or Manage → read; **force-stop app** → still read | Pending device | |
| Mark all read | Manage → Mark all → restart → all still read | Pending device | |
| PATCH failure | Airplane mode on mark read → snackbar and unread state restored | Pending device | |

---

## Automated pre-check (developer machine)

```bash
cd alpha_track_app
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test test/notification_inbox_pagination_test.dart
```

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Developer | | |
| Client (optional) | | |

When all applicable rows pass, check P3 in [PRODUCTION_PHASED_PLAN.md](PRODUCTION_PHASED_PLAN.md) and Phase 1 **1.5** in [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md).
