# Wayfinch

Offline-first to-do app for Windows that works hand in hand with the user's AI of choice: the user exports their list (with a prompt attached) to their AI, the AI edits it, and the user imports the reply back with a preview of every change.

The full product spec is in `docs/SPEC.md`. It is the source of truth for features and behavior. If something here and the spec disagree, the spec wins. If the spec is unclear or silent, stop and ask; don't invent behavior.

## Stack

- Flutter, Windows desktop target first (keep code platform-agnostic where it's free to do so)
- Drift on SQLite, encrypted with SQLCipher (key derived from the user's password with a slow KDF)
- Flutter l10n with ARB files: English + French. **No hardcoded user-facing strings, ever.**
- Recurrence stored as iCal RRULE strings
- Local Windows notifications; the app minimizes to the system tray on close

Prefer well-maintained, widely used packages. Ask before adding any new dependency.

## Architecture rules

- Every item has a stable UUID plus `createdAt` / `updatedAt`. Never reuse or regenerate ids: AI import/export and future sync depend on them.
- "Overdue" is computed (`due < now && doneAt == null`), never stored.
- Items nest with unlimited depth in the data (`parentId`). Every level indents further in the UI (full step for the first 4 levels, smaller step after) so subtasks always read as subtasks.
- The three confirm prompts go through `ItemRules` (`lib/domain/item_rules.dart`). Remembered answers live in the settings table. Cancel is only rememberable for "Mark the parent done too?" (see the spec's "Core behaviors").
- Keep the data layer (Drift, repositories), domain logic (completion rules, import diffing, recurrence) and UI separate. Domain logic must be unit-testable without Flutter widgets.
- The AI exchange format is versioned (`"version": 1` in the JSON) but the version is never shown in the UI.
- The logo's sources live in `docs/brand/` (SVGs plus `build.py`, which generates them). The in-app `FinchLogo` paints the same geometry (outlined in dark mode); the app icon is `windows/runner/resources/app_icon.ico`, the tray icons are `assets/tray/tray_light.ico` (white ink, dark taskbar) and `tray_dark.ico`, and toasts use `assets/brand/notification_icon.png`. Brand colors are fixed and don't follow the accent.
- Theme tokens (colors, accents, priority colors) live in one place. Exact values are in the spec's "Visual design and themes" section.

## Workflow

- Build milestone by milestone, in the order listed in the spec. Don't start a milestone until the previous one is merged.
- Work on a branch per milestone (or per smaller chunk) and open a **draft PR**.
- Every PR description includes:
  - what was implemented
  - test results (what was run, what passed)
  - what was deliberately left untouched or deferred
  - anything that deviates from the spec, and why
- Small, scoped changes. Preserve existing behavior unless the milestone says to change it.
- Core features before stretch goals. Nothing from the spec's "Later" section unless asked.
- Never describe something as working unless it was actually run. Keep "written", "tests pass", "merged" and "verified in the running app" clearly separate.

## Testing

- Unit tests for all domain logic, especially: completion and due-date prompt rules, recurrence, overdue computation, import parsing/validation, and the import diff (new / changed / removed, id matching, Replace keeping done history).
- Migration tests for every Drift schema change.
- Widget tests for the main flows when practical.
- Run `flutter analyze` and `flutter test` before opening or updating a PR.
- To check the UI without touching real data, run the demo entry point (in-memory database with sample items): `flutter run -d windows -t dev/demo_main.dart`. Options, as environment variables or `--dart-define`s: `DEMO_MODE=light|dark`, `DEMO_ACCENT=sky|honey|meadow|lilac|mono`, `DEMO_VIEW=settings|export|import`. Use a release build to launch it outside `flutter run` (a debug build started on its own exits right away, likely because its folder has no `native_assets.json`). A running app locks `build/`, so launch a **copy** of `build/windows/x64/runner/Release` from a scratch folder; one build then covers every view via environment variables.
- To try first-run setup and the password flows on real code without touching real data, run `dev/fresh_main.dart` (the real app on a new temp data folder each launch).
- Tray, close-to-tray, toasts and "Launch at startup" live in `lib/app/desktop.dart` and only run from `lib/main.dart`; the dev entry points skip them. With "Launch at startup" on, the real app writes the `Wayfinch` value under `HKCU\...\CurrentVersion\Run` with the path of the exe that was launched, so turn it off before testing from a scratch copy. Notification timing logic is in `NotificationService` (tested with a fake `Notifier`).
- Daily backups (`lib/data/daily_backups.dart`) run from `AppSession` only, into `<data dir>/backups` by default; `dev/fresh_main.dart` writes them inside its temp folder. Widget tests built on `WayfinchApp` have no backup service, so Settings hides the Backups section there.
- Widget tests open the database inside the test's fake-async zone. Run database work with the `pumpUntilDone` helper in `test/widget/app_test.dart`, not `tester.runAsync`, or the test hangs.

## Style

- Dart: follow `flutter_lints`, small widgets, no giant build methods.
- Docstrings on public classes and non-obvious functions.
- UI copy is friendly, casual and short. Never stressful or naggy.
