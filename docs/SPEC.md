# Wayfinch: product spec

Nov 15, 2026 · @Judhy Germain

## Overview

Wayfinch is an offline-first to-do app for Windows that works hand in hand with whatever AI the user already uses. The user exports their list with a prompt attached, the AI edits it, and the user imports the reply back with a preview of every change.

- **Who it's for:** anyone who plans with an AI chatbot and wants that plan to live in a real to-do app instead of a chat log.
- **The AI loop:** Export for AI (locked format rules + the user's own instructions + their list as JSON) → user pastes into their AI with a request → user pastes the reply into Import → preview → Add or Replace.
- **Platform:** Windows desktop first. Personal use and testing before any public release.
- **Data:** fully local, no accounts, no network. Multi-platform and sync come later.
- **Languages:** English and French from day one.
- **Tone:** calm, friendly, a bit playful. Never stressful.

## Tech stack and architecture

Flutter + Drift (SQLite), targeting Windows first, so iOS, Android, macOS and web stay possible from the same codebase later.

| Concern | Choice | Why |
| --- | --- | --- |
| UI framework | Flutter (Windows desktop) | One codebase for every platform later |
| Local database | Drift on SQLite | Typed queries, migrations, reactive streams |
| Encryption | SQLCipher, key derived from the user's password | A login screen alone protects nothing; the file itself must be unreadable |
| Recurrence | iCal RRULE strings | Same format AIs know and .ics files use |
| Localization | Flutter's built-in l10n (ARB files), EN + FR | Cheap now, painful to retrofit |
| Notifications | Local Windows notifications | App keeps running in the system tray |
| Calendar files | .ics import/export | Works with Google, Outlook and Apple calendars |

- Sync-ready from day one: every item has a stable UUID plus created/updated timestamps, so a backend can be added later without changing the data model.
- No hardcoded UI strings: everything goes through the l10n files.

## Data model

Everything is an **item**, and every item is either a task or an event. Items nest without a depth limit.

| Field | Applies to | Notes |
| --- | --- | --- |
| id | all | Stable UUID, kept through AI round trips |
| type | all | `task` (due by a time) or `event` (start to end) |
| title, notes | all | Notes are optional free text |
| due | task | Date + optional time |
| start, end | event | Date + time |
| priority | all | None, Low, Medium, High |
| tags | all | Many per item; each tag has a color |
| reminders | all | List of offsets before due/start |
| recurrence | all | RRULE string, optional |
| parentId | all | Null for top-level items |
| sortOrder | all | Manual order among siblings |
| doneAt | task | Null when open |
| createdAt, updatedAt | all | Kept for history and future sync |
| source | all | manual, ai-import or ics-import (+ ICS UID) |

- **Overdue** is computed, never stored: `due < now && doneAt == null`. Changing the due date clears it instantly. It shows as a special "overdue" auto tag that users can't assign or delete, but can recolor (default: the theme's warning color, with "Use default" to go back to it).
- **Nesting:** unlimited depth in the data. Every level indents further in the UI so subtasks always read as subtasks: a full step for the first 4 levels, then a smaller step per extra level.
- **Tags** are user-created with a color picked from a curated palette, or any color via a picker. New tags take the next palette color. A tag's color can be changed from three places, all opening the same color dialog: the tag's dot in the sidebar (or right-click → "Change color..."), a tag chip in the detail panel (its menu also has "Remove tag"), and the dot next to the name in the tag's own view. Curated colors have a lighter partner for dark mode; a custom color shows exactly as picked.

## Core behaviors

Three situations ask the user before acting, all with the same prompt: **Confirm / Cancel**, plus a "don't ask again" checkbox.

| Situation | What the prompt says | Checkbox |
| --- | --- | --- |
| A subtask's due date moves past its parent's | This will also push the parent's due date | "Always do this without asking" |
| A parent is marked done with open subtasks | This will also close its open subtasks | "Always do this without asking" |
| The last open subtask is marked done | Mark the parent done too? | "Remember my answer" |

- **Cancel** on the first two stops the whole action (the date change, or completing the parent). Their checkbox therefore only takes effect with Confirm; a Cancel is never remembered there, since that would silently block the action. "Mark the parent done too?" can remember either answer.
- Pushing a parent's date also pushes any further ancestors that would end up earlier than the new date. "Mark the parent done too?" repeats up the tree, one level at a time.
- **Settings** has a dropdown per prompt: "Ask me" or the remembered choice, so prompts can always be turned back on.
- **Done items** are hidden from every view by default and live in the Done view, with a simple progress stat ("23 done this week"). Inside a parent, hidden done subtasks show as "2 completed subtasks hidden · Show".
- **Reopening** a done task reopens only that task.
- **Events** move to Done automatically once their end time passes. Events have no checkbox.
- **Recurring items:** completing one creates the next occurrence from its RRULE.
  - Its subtasks are copied to the new occurrence: new ids, all open, dates shifted by the same number of days.
  - The rule moves to the new occurrence, so the finished one never repeats twice.
  - A recurring event rolls forward once it ends; missed occurrences are skipped.
- **Deleting** an item also deletes its subtasks, after one confirmation when it has any. A "Deleted … · Undo" message stays up for 10 seconds, and Undo restores everything exactly as it was (same ids and history).
- **Default sort** in every view: due date (a date without a time counts as the end of that day; no date sorts last), then priority as the tiebreaker.
- **Each item shows once per view.** In Today, an overdue item shows only in the Overdue section, even if its parent is due today. In Upcoming, a subtask shows under its own day.

## Screens and layout

A three-pane desktop layout: **sidebar | list | detail panel**. The detail panel opens when an item is clicked, so editing never needs a popup. Mockups: [Wayfinch mockups](https://claude.ai/artifact/1ht3LnUfCTYRVSGDbpufP4).

| View | Shows |
| --- | --- |
| Today | Overdue section on top (warning color), then today's tasks and events |
| Upcoming | Next 7 days, grouped by day |
| All | The full item tree |
| Tags | One filter per tag, plus the overdue auto tag |
| Done | Completed items + progress stat |
| Help | Short searchable sections |

- **Sidebar:** logo + greeting with the user's first name, search, the views, tags with counts, then Export for AI, Import, Help and Settings at the bottom.
- **Start view:** Settings › General › "Open Wayfinch in" picks the view the app opens in (Today, Upcoming, All or Done; Today by default).
- **Sidebar order:** views and tags (including the overdue auto tag) can be reordered by dragging; a plain click still opens them.
  - The order is saved.
  - New tags appear at the end. Until tags are reordered they're sorted by name, with the overdue tag last.
- **Overdue banner:** sits at the top of every view ("3 overdue items need a new plan"). "Review" jumps to Today's overdue section; "Snooze until tomorrow" hides it for the day.
- **Quick add** field at the top of the list. It understands, in English and French:
  - **Dates:** today/tomorrow (aujourd'hui/demain), weekday names, and month + day like "Dec 5" or "5 déc".
  - **Times:** "5pm", "17:00" or "17h30".
  - **Tags and priority:** `#tag`, and `!high`, `!med`, `!low` (or `!haute`, `!moyenne`, `!basse`).
  - Without a date, items added in Today are due today.
- **Detail panel:** Task/Event toggle, title, due or start/end, priority, tags, reminders, repeat, subtask progress bar, notes, Mark as done, Delete.
  - **Date and time** are picked together in one dialog (calendar plus an optional time) and saved in one step.
  - A subtask's panel links back to its parent.
- **Adding subtasks:** "+ Add subtask" in the detail panel, or the **+** on a list row (shown on hover and on the selected row), creates a subtask and opens it right away with its title ready to type.

## AI exchange: format, export, import

The exchange format is JSON, validated strictly against a schema. Only the format is fixed; everything else the AI is told comes from the user.

```json
{
  "format": "wayfinch",
  "version": 1,
  "items": [
    {
      "id": "a1b2",
      "type": "task",
      "title": "CV term project",
      "due": "2026-12-05T23:59",
      "priority": "high",
      "tags": ["school"],
      "recurrence": null,
      "children": [
        { "id": "c3d4", "type": "task", "title": "Write report", "due": "2026-12-03T23:59" }
      ]
    }
  ]
}
```

- `version` is internal only, never shown in the UI. It lets future versions read older files.
- New items from the AI omit `id`; the app assigns one. An `id` the app doesn't know is also treated as a new item, with a fresh id (ids from an AI are never trusted to be new).
- **Fields:**
  - every item: `id`, `type`, `title`, `notes`, `priority` (none/low/medium/high), `tags` (names), `recurrence` (RRULE or null), `children`
  - tasks: `due` (`YYYY-MM-DD` or `YYYY-MM-DDTHH:mm`, local time) and `done: true` when finished
  - events: `start` and `end`
  - Unknown fields are errors (strict schema).
- **Existing items:** a field missing from the reply means "leave it as it is". New items get defaults.

### Export for AI

- One copyable block in three parts: **Format rules** (locked, app-controlled), **My instructions** (user-editable, saved, empty by default with example placeholders), **My list** (the JSON).
- **Format rules:**
  - They tell the AI: reply with only valid JSON in the Wayfinch format, keep every existing id, omit id for new items, don't remove items unless asked, don't add other fields.
  - They describe every field, and include **today's date** so the AI can plan.
  - The rules text follows the app language; the JSON keys don't.
- "What to include" checkboxes: open tasks, events, notes, done items. Done items are off by default. The choices are remembered.
- When a parent is left out (e.g. a done parent with done items unchecked), its included subtasks move up a level in the export.
- Output: Copy to clipboard or Save as file (a `.txt` with the whole block).

### Import

1. **Paste or open:**
   - Paste the AI's reply ("Paste from clipboard" or type into the box) or open a file.
   - The app strips any text and code fences around the JSON, then validates it.
   - Errors say exactly what's wrong and where ("Item 3 › subtask 1: "due" should look like 2026-12-05..."), with a tip to ask the AI to fix them.
2. **Preview:**
   - Counts of new, changed and removed items, done items left alone, and a list of each change with what changed (e.g. "Due Nov 15 → Nov 17", "Priority Medium → High", "Tags added: ta", "Moved under …").
   - A warning appears when the AI removed anything, with a "Keep this item" button per removal.
3. **Choose Add or Replace** (Replace is pre-selected, as in the mockup):
   - **Add** only adds new items, including new subtasks under existing items.
   - **Replace** makes the list match the AI's version, matching items by id so creation dates and history survive. Any open item missing from the reply is removed, whatever the export included. **Done items (and ended events) are never removed or changed by a missing entry.**
   - The reply's nesting decides parents. A top-level item whose current parent isn't in the reply but stays (e.g. an unexported done parent) keeps that parent. Anything left under a removed item moves up to the nearest surviving ancestor.
4. **Backup + undo:**
   - A snapshot of the whole list (items, tags, tag links, reminders) is stored in the database right before every import, Add or Replace. It's encrypted with the database; the last 10 are kept.
   - After importing, "Imported N changes · Undo" stays up for 15 seconds.
   - The Import dialog also offers "Undo last import" (with a confirmation, since it also drops anything changed since). Undo restores the snapshot exactly.
   - **Settings › Import history** lists every stored backup (when, Add or Replace, how many changes, how many items) with a **Restore** button.
     - Restoring first backs up the current list as a "Before a restore" entry, so a restore can be undone the same way.
     - This is separate from the daily auto-backups, which come with milestone 7.

## Calendar import and export

Calendars come in and go out as .ics files. Direct Google/Outlook sync waits for the online phase.

- **Import:** .ics events become Wayfinch events, recurring ones included (RRULE). Only events from today forward by default, with an option to include past ones.
- **Re-import:** events are matched by their ICS UID, so they update instead of duplicating. The same preview screen as AI import shows counts ("8 new, 2 updated").
- **Export:** events go out as VEVENTs. A toggle (off by default) also exports tasks as short events at their due time, since Google Calendar ignores VTODO.

## Security, profile and backups

The password is optional, but when it's set the database is encrypted. A forgotten password with no recovery code means the data is gone for good, so the UI must say so plainly.

- **Profile:** first name (required, used in greetings and the daily digest) and an optional password.
  - Settings › Profile edits the name and can set, change or remove the password, or make a new recovery code. Each action except setting a password asks for the current one.
- **Encryption:** SQLCipher.
  - A random database key is wrapped (AES-256-GCM) twice, once with a key derived from the password and once with one derived from the recovery code, using Argon2id. Either one unlocks.
  - The wrapped keys live in a small vault file next to the database; it holds no secrets in the clear.
  - Turning the password on or off re-encrypts or decrypts the database file in place (SQLCipher export, swapped in only once complete). Changing the password only re-wraps the key.
- **Unlock screen** at start when a password is set: password, or "Use your recovery code". After a recovery-code unlock, the app asks for a new password (or "Keep my old password").
- **Recovery code:** shown once after the password is set, with an "I saved it" checkbox before continuing (Copy and Save as file offered). It can also unlock the database.
- **Daily auto-backups:** the last 7 are kept, in a folder the user picks. Backups are encrypted the same way as the database.
- **Pre-import backup:** taken before every Replace import, separate from the daily ones.
- Windows Hello unlock is a possible later convenience.

## Onboarding and help

Setup takes five short screens, then the app teaches itself through a tutorial that is a real task list.

1. Welcome (the finch says hi)
2. First name
3. Password (optional) → recovery code screen
4. Pick your vibe: light/dark + accent, with a live preview
5. Notifications: quick defaults (task and event reminders, morning digest and its time), "Launch at startup". Windows needs no permission prompt; the screen explains that reminders arrive while Wayfinch runs in the tray.

Then a short **"How to use it with your AI"** screen showing the copy → paste → import loop as a small diagram.

- **Applying the choices:** the password (and the file encryption) is applied only when setup finishes; until then, Back changes nothing. The notification choices are saved now and take effect with the notifications milestone.
- **Existing data:** someone who already has items but never ran setup (e.g. from before this feature) sees setup once, but the tutorial isn't added.
- **Tutorial as tasks:** a pre-loaded "Getting started" task (due today) whose subtasks teach by doing: check this off, add a subtask, give this a tag, export your list for AI.
  - Every step but "Check this off" checks itself off when the user does it: adding a subtask or a tag anywhere in the tutorial (the task, its steps, or their subtasks), or copying or saving an export. Automatic checks never prompt: only the step is checked (its own subtasks stay open). When that was the last step, "Getting started" is marked done too if nothing under it is still open ("You finished…"), otherwise a note says it can be checked off when ready.
  - The tutorial is only created when the list is empty.
- **Skippable:** marking the parent done closes the whole tutorial (through the usual parent-completion prompt). No nagging.
- **Not replayable.** The Help page covers everything instead: basics, nesting, AI import/export (including the exact format rules the AI receives), calendar, themes, backups.
  - Help is a sidebar destination with searchable, expandable sections; searching opens the matches.
  - Calendar and notification sections come with those features.

## Notifications

Windows only delivers Wayfinch's notifications while the app is running, so closing the window minimizes it to the system tray instead of quitting.

| Feature | Default | Notes |
| --- | --- | --- |
| Task reminder | 1 hour before due | Changeable globally and per item; multiple allowed |
| Event reminder | 15 minutes before start | Same |
| Daily digest | On, morning time picked by the user | "Hey Judhy, 4 things today"; can be turned off |
| Quiet hours | Off | No notifications during a set window |
| Snooze from a notification |  | 10 minutes, 1 hour, tomorrow |
| Overdue | No notification | The banner covers it |

- The tray menu has a real "Quit".
- "Launch at startup" is offered during onboarding and lives in Settings.

## Visual design and themes

Neutral backgrounds, with color used only where it means something: priority, tags, overdue, and one accent for actions and selection. Rounded and friendly, with a bit of personality.

| Accent | Fill (light + dark) | Text shade on light | Text on accent fill |
| --- | --- | --- | --- |
| Sky (default) | #60A3EB | #1F5FA8 | #10233A |
| Honey | #FABF66 | #8A5300 | #3A2400 |
| Meadow | #3CCB6B | #1A7A3A | #0C2E17 |
| Lilac | #B9A4EB | #6146B8 | #241645 |
| Mono | #343A40 (dark mode: #DEE2E6) | #343A40 | #FFFFFF |

| Token | Light | Dark |
| --- | --- | --- |
| App background | #E9ECF1 | #121418 |
| Panel | #FFFFFF | #1A1D23 |
| Sidebar | #F4F6F9 | #16191E |
| Border | #D9DEE6 | #2C3039 |
| Text | #1B1F27 | #ECEEF2 |
| Muted text | #565D6A | #A7ADB9 |
| Warning background / text | #FFE2A8 / #6B3A00 | #3A2A10 / #FFCF7A |

- **Priority colors:** High red (#E03131 light, #FF8787 dark), Medium orange (#E67700 / #FFC078), Low blue (#1971C2 / #74C0FC). Each also has a flag icon and a text label, so color is never the only signal.
- **Font:** Nunito (400 to 800), bundled with the app (offline) as the official variable font, with its OFL license in `assets/fonts`.
- **Theme mode:** System (follows Windows; the default), Light or Dark, in Settings › Appearance.
- **Custom theme builder:** a sixth "Custom" accent option.
  - The user picks five colors: accent, background, panels, sidebar and text. They can start from a light or a dark base.
  - Everything else is derived: borders, secondary text, text on the accent, and accent-colored text darkened or lightened until readable.
  - The custom theme decides light or dark by itself (from the panel color), so the mode setting doesn't apply while it's active.
  - An automatic contrast check (WCAG AA, 4.5:1) names the areas where text may be hard to read (e.g. "Text on panels"), without showing numbers. It never blocks.
  - Color pickers are built in (hue, saturation/brightness, hex), with no extra dependency.
- **Delight:**
  - A small confetti burst when a task is completed (skipped when the system asks for reduced motion).
  - The finch mascot in empty states, and later in onboarding.

## Milestones

Seven milestones, each ending in an app that runs. Wayfinch is usable day to day after milestone 2, and the AI loop comes before the polish because it's the point of the app.

1. **Foundation:** Flutter Windows project, Drift + SQLCipher, the data model and migrations, EN/FR l10n setup.
2. **Core list:** three-pane layout, Today / Upcoming / All / Done, create, edit and complete, nesting, the three confirm prompts, recurrence, sorting.
3. **Look and feel:** light/dark themes, the 5 accents, custom theme builder with the contrast check, tag colors, overdue banner + snooze.
4. **AI loop:** Export for AI (format rules + my instructions + include options), Import with validation, preview and diff, Add vs Replace, backup and undo.
5. **Onboarding + Help:** setup flow, password + recovery code, tutorial as tasks, AI loop screen, Help page.
6. **Notifications:** reminders, daily digest, quiet hours, snooze, tray + launch at startup.
7. **Calendar + backups:** .ics import/export with preview, daily auto-backups.

## Later, not in this build

- Calendar view (week/month grid)
- Multi-platform builds (Android, iOS, macOS, web) and sync with accounts
- Direct Google/Outlook calendar sync
- Smart "merge" import mode (the stable ids already make it possible)
- Windows Hello unlock
- Before any public release: a trademark search for "Wayfinch" (USPTO + CIPO) and a Microsoft Store check
