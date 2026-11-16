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

- **Overdue** is computed, never stored: `due < now && doneAt == null`. Changing the due date clears it instantly. It shows as a special "overdue" auto tag that users can't assign or delete.
- **Nesting:** unlimited depth in the data. The UI indents up to 3 or 4 levels, then collapses deeper levels.
- **Tags** are user-created with a color picked from a curated palette, or any color via a picker.

## Core behaviors

Three situations ask the user before acting, all with the same prompt: **Confirm / Cancel / Always do this**.

| Situation | What the prompt says |
| --- | --- |
| A subtask's due date moves past its parent's | This will also push the parent's due date |
| A parent is marked done with open subtasks | This will also close its open subtasks |
| The last open subtask is marked done | Mark the parent done too? |

- Every "Always do this" choice has a toggle in Settings, so the prompts can be turned back on.
- **Done items** are hidden from every view by default and live in the Done view, with a simple progress stat ("23 done this week"). Inside a parent, hidden done subtasks show as "2 completed subtasks hidden · Show".
- **Events** move to Done automatically once their end time passes. Events have no checkbox.
- **Recurring items:** completing one creates the next occurrence from its RRULE.
- **Default sort** in every view: due date, then priority as the tiebreaker.

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
- **Overdue banner:** sits at the top of every view ("3 overdue items need a new plan"). "Review" jumps to Today's overdue section; "Snooze until tomorrow" hides it for the day.
- **Quick add** field at the top of the list.
- **Detail panel:** Task/Event toggle, title, due or start/end, priority, tags, reminders, repeat, subtask progress bar, notes, Mark as done, Delete.

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
- New items from the AI omit `id`; the app assigns one.

### Export for AI

- One copyable block in three parts: **Format rules** (locked, app-controlled), **My instructions** (user-editable, saved, empty by default with example placeholders), **My list** (the JSON).
- Format rules tell the AI: reply with only valid JSON in the Wayfinch format, keep every existing id, omit id for new items, don't remove items unless asked.
- "What to include" checkboxes: open tasks, events, notes, done items. Done items are off by default.
- Output: Copy to clipboard or Save as file.

### Import

1. Paste the AI's reply or open a file. The app strips any text around the JSON, then validates it. Errors say exactly what's wrong.
2. **Preview:** counts of new, changed and removed items, plus a list of each change. A warning appears when the AI removed anything, with a "Keep this item" button per removal.
3. **Choose Add or Replace.** Add only adds new items. Replace makes the list match the AI's version, matching items by id so Done history and creation dates survive.
4. **Backup + undo:** the current list is backed up automatically before every Replace, and an "Undo import" action restores it.

## Calendar import and export

Calendars come in and go out as .ics files. Direct Google/Outlook sync waits for the online phase.

- **Import:** .ics events become Wayfinch events, recurring ones included (RRULE). Only events from today forward by default, with an option to include past ones.
- **Re-import:** events are matched by their ICS UID, so they update instead of duplicating. The same preview screen as AI import shows counts ("8 new, 2 updated").
- **Export:** events go out as VEVENTs. A toggle (off by default) also exports tasks as short events at their due time, since Google Calendar ignores VTODO.

## Security, profile and backups

The password is optional, but when it's set the database is encrypted. A forgotten password with no recovery code means the data is gone for good, so the UI must say so plainly.

- **Profile:** first name (required, used in greetings and the daily digest) and an optional password.
- **Encryption:** SQLCipher, with the key derived from the password using a slow key-derivation function (e.g. Argon2 or PBKDF2).
- **Recovery code:** shown once after the password is set, with an "I saved it" checkbox before continuing. It can also unlock the database.
- **Daily auto-backups:** the last 7 are kept, in a folder the user picks. Backups are encrypted the same way as the database.
- **Pre-import backup:** taken before every Replace import, separate from the daily ones.
- Windows Hello unlock is a possible later convenience.

## Onboarding and help

Setup takes five short screens, then the app teaches itself through a tutorial that is a real task list.

1. Welcome (the finch says hi)
2. First name
3. Password (optional) → recovery code screen
4. Pick your vibe: light/dark + accent, with a live preview
5. Notifications: permission, quick defaults, "Launch at startup"

Then a short **"How to use it with your AI"** screen showing the copy → paste → import loop as a small diagram.

- **Tutorial as tasks:** a pre-loaded "Getting started" task whose subtasks teach by doing: check this off, add a subtask, give this a tag, export your list for AI.
- **Skippable:** marking the parent done closes the whole tutorial (through the usual parent-completion prompt). No nagging.
- **Not replayable.** The Help page covers everything instead: basics, nesting, AI import/export (including the exact format rules the AI receives), calendar, themes, backups.

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
- **Font:** Nunito (400 to 800).
- **Custom theme builder:** color pickers plus an automatic contrast check that warns (but doesn't block) when text may be hard to read.
- **Delight:** a small celebration animation when something is completed, and the finch mascot in onboarding and empty states.

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
