# Demo mode and `DemoData` audit

`kDemoMode` is defined in [`lib/utils/demo_data/demo_data.dart`](lib/utils/demo_data/demo_data.dart):

- **Release** (no `--dart-define=DEMO_MODE=true`): `kDemoMode == false` → real login and API paths.
- **Debug** (default): `kDemoMode == false` → same as production auth (`_demoReviewEnabled = false`).
- **Explicit demo**: `flutter run` or `flutter build ... --dart-define=DEMO_MODE=true` → demo data + orange **DEMO** banner ([`demo_mode_banner.dart`](lib/widgets/demo_mode_banner.dart)).

## Call sites (grep baseline 2026-10-14)

| Location | When `kDemoMode` | Release + logged in |
|----------|------------------|---------------------|
| `splash_screen_controller` | Skip auth → bottom nav | Token check → login or home |
| `home_screen_controller` | Demo projects, timer, charts | API |
| `project_details_screen_controller` | Demo project, time, **notes** | API; missing `projectId` → error (no `demo_p1`) |
| `profile_controller` | Demo profile | API |
| `personal_information_controller` | Demo profile edits | API |
| `gallery_screen_controller` | Demo gallery | API |
| `payrole_screen_controller` | Demo payroll | API |
| `break_screen_controller` | Demo leave balance/history | API |
| `leave_screen_controller` | Demo leave flows | API |
| `notification_screen_controller` | Demo notifications | API |
| `notification_preferences_controller` | Defaults; save blocked | GET/PATCH preferences |
| `change_password_controller` | No API call | API |
| `socket_service` / `employee_socket_subscriptions` | No socket | Socket + JWT |
| `create_note_screen` | Local-only save result | `NoteRepository.createNote` when `projectId` set |

## Not gated by `kDemoMode` (documented, out of Phase 0)

| Area | Behavior |
|------|----------|
| [`language_screen.dart`](lib/screens/profile_screen/language_screen/language_screen.dart) | Local notification toggles; not wired to `/notification-preferences` |
| [`project_notes_screen`](lib/screens/home_screen/projects_notes/) | Local chat-style UI; not the primary employee notes path |

## Verification

See [`PHASE_0_RELEASE_VERIFICATION.md`](PHASE_0_RELEASE_VERIFICATION.md) for release build commands and smoke checklist.
