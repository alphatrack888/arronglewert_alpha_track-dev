# Client-reported issues — phased fix plan

**App:** `alpha_track_app/`  
**Backend reference:** `time-tracker/` → `https://api.alphatrack.app/api/v1`  
**Prerequisite:** [BUGFIX_PHASED_PLAN.md](BUGFIX_PHASED_PLAN.md) Phase 1–2 (auth/session, `companyId`, preferences link) — already done.

**Principles**

- Fix root causes; no new product features beyond wiring what UI/backend already imply.
- One release can include multiple phases; **no separate git tag per phase** (tag only when a build ships to testers).
- Each phase has exit criteria and a short manual smoke — not a full regression program.

---

## Issue index

| ID | Report | Phase |
|----|--------|-------|
| C1 | Login sometimes fails | 5 (triage + targeted fixes) |
| C2 | Gallery: storage/photos toggle missing in Settings; pick blocked | 4 |
| C3 | Pause / break setting resets or feels broken | 3 |
| C4 | Leave date lag + submit fails | 2 |
| C5 | Push prefs appear off after leaving settings | 3 |
| C6 | Automatic break toggle not hooked up | 3 |
| C7 | Break History shows demo data only | 3 |
| C8 | Gallery delete not synced to server | 4 (optional same pass as C2) |
| C9 | Duplicate leave routes (`LeaveScreen` vs schedule) | 2 |

---

## Phase 2 — Leave apply path (C4, C9)

**Problems**

1. Legacy full-page leave UI had **test mode** submit (removed).
2. Profile opens [**Leave Schedule**](lib/screens/break_screen/leave_screen/leave_schedule_screen.dart) (sheet → `applyLeaveFromSheet()`).
3. **`/leaveScreen`** and leave notifications now land on the same **Leave Schedule** screen.

**Tasks**

- [x] **2.1** Retired test-mode `LeaveScreen`; apply path is **Leave Schedule** sheet → `applyLeaveFromSheet()` → API.
- [x] **2.2** `AppRoute.leaveScreen` aliases to `LeaveScheduleScreen`; notification routing uses `leaveScheduleScreen`; duplicate page deleted.
- [x] **2.3** N/A — heavy date UI removed with deprecated screen; schedule uses `showDatePicker`.

**Exit criteria**

- Apply leave from **both** schedule sheet and full leave form hits `applyforLeave` API and shows success/failure from server.
- No user-facing “test mode” copy on submit.
- Opening leave from Account still works without empty `companyId` (Phase 2 guard).

**Smoke (~5 min)**

- Login → Account → Leave Schedule → apply 1 day → success + appears in upcoming/history.
- If `leaveScreen` route remains, open it → submit → same API behavior.

---

## Phase 3 — Break preference + notifications UX (C3, C5, C6, C7)

**Problems**

1. **Break Settings** toggle ([`break_screen.dart`](lib/screens/break_screen/break_screen/break_screen.dart)) is local `State` only — resets on exit (C3/C6).
2. **Hourly auto-pause** + “Time for a break?” dialog ([`home_screen_controller.dart`](lib/screens/home_screen/main_home/controller/home_screen_controller.dart) `_startTimer`) runs for **everyone**, ignoring the setting.
3. Backend has **`manualBreak`** on user ([`user.model.ts`](../time-tracker/src/app/modules/user/user.model.ts)) but no server logic; app never reads/writes it from Break Settings.
4. **Notification preferences**: toggles update memory only; **Save** required ([`notification_preferences_screen.dart`](lib/screens/notification_preferences_screen/notification_preferences_screen.dart)) — reopen refetches → looks “turned off” (C5).
5. **Break History** ([`history_screens.dart`](lib/screens/break_screen/history_screens.dart)) is static demo; API exists: `GET /user/todays-break-periods` (C7).

**Tasks**

- [x] **3.1 Break preference service** — [`break_preference_service.dart`](lib/services/break_preference/break_preference_service.dart), profile `patchProfileFields`, [`BreakSettingsController`](lib/screens/break_screen/break_screen/controller/break_settings_controller.dart), sync on [`profile_controller`](lib/screens/profile_screen/profile_screen_main/controller/profile_controller.dart).

- [x] **3.2 Gate hourly break prompt** — [`home_screen_controller.dart`](lib/screens/home_screen/main_home/controller/home_screen_controller.dart) `_isAutomaticBreakEnabled()` in `_startTimer`.

- [x] **3.3 Notification prefs** — debounced auto-save in [`notification_preferences_controller.dart`](lib/screens/notification_preferences_screen/controller/notification_preferences_controller.dart); `updatePreferences` checks `success == true`.

- [x] **3.4 Break History** — [`break_history_controller.dart`](lib/screens/break_screen/break_history_controller.dart) + API for last 7 days; demo fallback in controller.

**Exit criteria**

- Toggle Break Settings → leave app → return → **same** value; hourly dialog **off** when automatic break off, **on** when on (after 1h tracked time in test).
- Notification prefs: toggle push → back → reopen → **matches** last saved state without requiring Save (if Option A).
- Break History lists real pause intervals when user has paused sessions.

**Smoke (~10 min)**

- Automatic break **off** → run timer >1h (or temporarily lower threshold in debug) → no hourly dialog.
- Automatic break **on** → hourly dialog appears.
- Settings → Notification preferences → toggle category → leave → reopen → persisted.
- Break History after a real pause → at least one period shown.

---

## Phase 4 — Gallery pick + delete (C2, C8)

**Problems**

1. **Reported symptom:** User opens app Settings to allow storage/photos, but **no storage or photos permission appears** — so they cannot fix access from Settings. **Cause:** manifest **removes** `READ_MEDIA_IMAGES` / legacy storage ([`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)), so Android does not expose those toggles; meanwhile [`ImagePickerService`](lib/services/image_picker_service/image_picker_service.dart) still **requests** `Permission.photos` (API 33+) before the gallery picker → denial + “open Settings” dialog with nothing to enable → **picker never opens** (upload never starts). Fix is picker-first on API 33+, not adding broad storage permission back.
2. Profile gallery delete is local-only in controller; backend supports `DELETE /gallery` ([`gallery.route.ts`](../time-tracker/src/app/modules/gallery/gallery.route.ts)).

**Tasks**

- [x] **4.1 Android gallery:** On SDK ≥ 33, **do not** call `Permission.photos` before `ImagePicker.pickImage(gallery)` (system Photo Picker needs no declared storage permission — avoids dead-end Settings). Keep camera permission for camera path. Soften/remove misleading “open Settings for photos” when no manifest permission exists.
- [x] **4.2 iOS:** Confirm `Info.plist` usage strings; no code change unless picker fails in test.
- [x] **4.3 Delete:** Wire [`GalleryScreenController.deleteImage`](lib/screens/profile_screen/gallery_screen/controller/gallery_screen_controller.dart) to `ProfileRepository` delete API; refresh list on success.

**Exit criteria**

- Android 13+: pick from gallery without stuck permission loop.
- Delete removes image on server and from grid after refresh.

**Smoke (~5 min)**

- Profile → Gallery → add photo → delete → gone after refresh / relaunch.

**Follow-up (gallery permissions):** Phase 4.1 picker-first was superseded by standard Android runtime permissions (`READ_MEDIA_IMAGES` + legacy storage `maxSdkVersion="32"`, SDK-split `Permission.photos` / `Permission.storage`). See [GALLERY_PERMISSIONS.md](GALLERY_PERMISSIONS.md).

---

## Phase 5 — Auth reliability (C1)

**Triage doc:** [C1_AUTH_TRIAGE.md](C1_AUTH_TRIAGE.md)

**Problems (remaining after Phase 1)**

- No **refresh-token** retry on 401 — session ends abruptly.
- Intermittent failures may be network, OTP (407), guest-without-token, or install/signing — not one code path.

**Tasks**

- [x] **5.1** Reproduce matrix: bad password, 407 OTP, expired token, guest home, airplane mode — log status + message shown ([C1_AUTH_TRIAGE.md](C1_AUTH_TRIAGE.md)).
- [x] **5.2** If refresh endpoint exists and `getRefreshToken()` is populated: add **one** Dio retry on 401 (refresh → replay request) before `SessionUnauthorized.handle()`; avoid infinite loops.
- [ ] **5.3** Login/guest copy: skipped (not in scope for this pass).

**Exit criteria**

- Documented repro for any still-open C1 report; refresh flow works when backend sends refresh token.
- 401 still routes to login (Phase 1), not onboarding.

**Smoke (~5 min)**

- Login → kill access token in storage → action that calls API → refresh or clean login prompt (no silent failure).

---

## Deferred (do not block above)

| Item | Reason |
|------|--------|
| Server-side break reminders (push `kind`) | No backend template; hourly in-app gating is enough for C6. |
| `manualBreak` enforcement on API | Field exists; document client mapping only until HR policy defined. |
| Full auth/token audit | Only if C1 still open after 5.2. |

---

## Verification before publish

1. `flutter test` in `alpha_track_app/`.
2. `python3 ci/p2_static_verify.py` if present.
3. Manual smoke: one row per phase completed in this release.
4. `rsync` to `arronglewert_alpha_track-dev/` (no `--delete` on clone).
5. **Single tag** when shipping a tester build (optional; not per phase).

---

## Suggested implementation order

1. **Phase 2** (leave) — highest user-visible “submit broken.”  
2. **Phase 3** (break toggle + notifications + history) — client pause/prefs reports + your hook-up requirement.  
3. **Phase 4** (gallery).  
4. **Phase 5** (auth) — only as needed from retest.
