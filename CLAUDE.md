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
- Items nest with unlimited depth in the data (`parentId`). The UI caps visual indentation around 3 to 4 levels.
- Keep the data layer (Drift, repositories), domain logic (completion rules, import diffing, recurrence) and UI separate. Domain logic must be unit-testable without Flutter widgets.
- The AI exchange format is versioned (`"version": 1` in the JSON) but the version is never shown in the UI.
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

## Style

- Dart: follow `flutter_lints`, small widgets, no giant build methods.
- Docstrings on public classes and non-obvious functions.
- UI copy is friendly, casual and short. Never stressful or naggy.
