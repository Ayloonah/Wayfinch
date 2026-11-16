# Wayfinch: product spec

Nov 15, 2026 · @Judhy Germain

## Overview

Wayfinch is an offline-first to-do app for Windows that works hand in hand with whatever AI the user already uses. The user exports their list with a prompt attached, the AI edits it, and the user imports the reply back with a preview of every change.

- **Who it's for:** anyone who plans with an AI chatbot and wants that plan to live in a real to-do app instead of a chat log.
- **The AI loop:** Import › "Message for your AI" (locked format rules + the list as JSON) → user pastes it into their AI with their own request → user pastes the reply into Import → preview → Add or Replace.
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
- **Counts** follow one rule everywhere (sidebar, view subtitles like "4 tasks, 1 event", section headers, tag counts, the overdue banner): count the **top-level rows** a view shows. Subtasks shown under their parent don't add to the count; a subtask that shows on its own (its parent isn't in that view) counts as a row.
- **Subtask progress** ("2 of 4" on a row, "2 of 4 done" in the detail panel) counts **leaf subtasks** at every depth: tasks with no subtasks of their own. Inner parents aren't counted, and events under a task aren't steps.
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
| AI instructions | How to use Wayfinch with your AI, with the format rules |

- **Sidebar:** logo + greeting with the user's first name (just "Good morning" without one), the views, tags with counts, then Export, Import, AI instructions and Settings at the bottom.
- **Start view:** Settings › General › "Open Wayfinch in" picks the view the app opens in (Today, Upcoming, All or Done; Today by default).
- **Sidebar order:** views are All, Today, Upcoming, Done by default. Views and tags (including the overdue auto tag) can be reordered by dragging; a plain click still opens them.
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

### Message for your AI

- A button in the Import dialog, "Message for your AI", opens a window with what to send the AI, in two parts: **Format rules** (locked, app-controlled) and **My list** (the JSON). The user writes their own request to the AI; Wayfinch doesn't ask for instructions.
- The window shows exactly what gets copied, with Copy to clipboard and Save as file (a `.txt`).
- **Format rules:**
  - They tell the AI: reply with only valid JSON in the Wayfinch format, keep every existing id, omit id for new items, don't remove items unless asked, don't add other fields.
  - They describe every field, and include **today's date** so the AI can plan.
  - The rules text follows the app language; the JSON keys don't.
- "What to include" checkboxes: open tasks, events, notes, done items. Done items are off by default. The choices are shared with Export and remembered.
- When a parent is left out (e.g. a done parent with done items unchecked), its included subtasks move up a level in the list.

### Export

- The sidebar's **Export** opens one window with two formats:
  - **Your list (JSON):** the "What to include" checkboxes (shared with the message for your AI) and a preview of the list as JSON, with Copy to clipboard and Save as file (`.json`). Only the data: no format rules or instructions.
  - **Calendar (.ics):** see "Calendar import and export".

### Import

1. **Paste or open:**
   - "Message for your AI" (see above) is the first button, for getting what to send the AI.
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
     - This is separate from the daily auto-backups (see "Security, profile and backups").

## Calendar import and export

Calendars come in and go out as .ics files. Direct Google/Outlook sync waits for the online phase.

- **Where:** importing goes through the regular Import dialog: an "Import a calendar (.ics)..." button, and any .ics file opened (or pasted) there goes to the calendar review. Exporting is the Calendar (.ics) format in the Export window (so nothing in the sidebar looks like it opens a calendar view).
- **Import:** .ics events become Wayfinch events, recurring ones included (RRULE). Only events from today forward by default, with an option to include past ones.
  - A repeating event counts as past only once its rule has run out.
  - All-day events come in as events from midnight to midnight (a 3-day trip runs from day 1 00:00 to day 4 00:00).
  - Times in UTC or a named zone (IANA names, or the Windows names Outlook writes) are converted to local time; times without a zone are taken as local.
  - Not carried over: exceptions to repeating events (EXDATE, single changed occurrences), cancelled events, to-dos (VTODO) and alarms. The preview says how many were skipped.
  - Imported events are top-level, with source `ics-import` and their ICS UID.
- **Re-import:** events are matched by their ICS UID, so they update instead of duplicating. The preview (same rows as AI import) shows counts ("8 new, 2 updated", "3 already up to date").
  - A match updates title, start, end, notes and repeat rule; tags, priority, reminders and subtasks stay. Nothing is ever removed.
  - A file exported by Wayfinch matches the original items too (its UIDs are `<id>@wayfinch`).
  - The list is backed up first (it shows in Import history as "Before a calendar import"), and "Imported N events · Undo" stays up for 15 seconds.
- **Export:** events go out as VEVENTs, saved as an .ics file. A toggle (off by default) also exports open tasks as short (30-minute) events at their due time, or all-day for date-only tasks, since Google Calendar ignores VTODO.
  - Midnight-to-midnight events export as all-day events. One-off times are written in UTC; repeating events in local "floating" time so "every Monday at 9" stays at 9 across daylight-saving changes.

## Security, profile and backups

The password is optional, but when it's set the database is encrypted. A forgotten password with no recovery code means the data is gone for good, so the UI must say so plainly.

- **Profile:** first name (optional, used in greetings and the daily digest) and an optional password.
  - Settings › Profile edits the name and can set, change or remove the password, or make a new recovery code. Each action except setting a password asks for the current one.
- **Encryption:** SQLCipher.
  - A random database key is wrapped (AES-256-GCM) twice, once with a key derived from the password and once with one derived from the recovery code, using Argon2id. Either one unlocks.
  - The wrapped keys live in a small vault file next to the database; it holds no secrets in the clear.
  - Turning the password on or off re-encrypts or decrypts the database file in place (SQLCipher export, swapped in only once complete). Changing the password only re-wraps the key.
- **Unlock screen** at start when a password is set: password, or "Use your recovery code". After a recovery-code unlock, the app asks for a new password (or "Keep my old password").
- **Recovery code:** shown once after the password is set, with an "I saved it" checkbox before continuing (Copy and Save as file offered). It can also unlock the database. The same screen explains that losing both the password and the code means the list can't be recovered, and that both are managed in Settings › Profile. The window is only as tall as its content.
- **Daily auto-backups:** the last 7 are kept, in a folder the user picks. Backups are encrypted the same way as the database.
  - By default they go to a `backups` folder next to the database (in AppData). Settings › Backups shows the folder with "Change" (and "Use default"), "Back up now", and the stored backups with Restore.
  - One backup per day (`wayfinch-backup-YYYY-MM-DD.db`), checked at startup and every 30 minutes; "Back up now" replaces today's. Not during setup.
  - Each is a full copy of the database encrypted with the same key (plain when no password is set). With a password, a copy of that day's key vault sits next to it, so a backup made before a password change can still be opened with the password (or recovery code) from back then; Restore asks for it when needed.
  - Restoring replaces the list and first backs up the current one in Import history, so it can be undone.
- **Pre-import backup:** taken before every Replace import, separate from the daily ones.
- Windows Hello unlock is a possible later convenience.

## Onboarding and help

Setup is short and skippable, then the app teaches itself through a tutorial that is a real task list.

1. Welcome (the finch says hi), with **Let's start** and **Skip setup**.
2. **About you:** first name (optional) and an optional password on one screen → recovery code screen when a password was entered.
3. **Look and notifications:** light/dark + accent with a live preview, and the notification defaults (task and event reminders, morning digest and its time, "Launch at startup") on one screen. Windows needs no permission prompt; the screen explains that reminders arrive while Wayfinch runs in the tray.
4. **How to use it with your AI:** the copy → paste → import loop as a small diagram.

- **Skip setup** saves the defaults (no name, so the greeting is just "Good morning"; no password; system theme and the Sky accent; default reminders, digest and "Launch at startup") and adds the tutorial. Everything can be changed later in Settings.
- **Applying the choices:** the password (and the file encryption) is applied only when setup finishes; until then, Back changes nothing.
- **Existing data:** someone who already has items but never ran setup (e.g. from before this feature) sees setup once, but the tutorial isn't added.
- **Tutorial as tasks:** a pre-loaded "Getting started" task (due today) whose subtasks teach by doing: check this off, add a subtask, give this a tag, get the message for your AI.
  - Every step but "Check this off" checks itself off when the user does it: adding a subtask or a tag anywhere in the tutorial (the task, its steps, or their subtasks), or copying or saving the message for your AI (or an export). Automatic checks never prompt. When that was the last step, the whole tutorial closes: "Getting started" and anything still open under it (practice subtasks added while learning) are marked done, not deleted, with a "You finished…" message.
  - The tutorial is only created when the list is empty.
- **Skippable:** marking the parent done closes the whole tutorial (through the usual parent-completion prompt). No nagging.
- **Not replayable.** The **AI instructions** page (a sidebar destination) explains the one thing that isn't obvious from the app: how to use Wayfinch with your AI, with the loop diagram (three equal cards) and the exact format rules the AI receives. Everything else is learned from the app and the tutorial; password and recovery-code advice lives on the recovery code screen.

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

- The tray icon and the running window's icon (title bar, taskbar) follow the Windows system theme, not the app's theme, and switch as soon as it changes: the regular mark on a light system theme, the light-check mark on a dark one. The outlined mark is only the exe's own icon (shortcuts, pinned taskbar button when closed).
- The tray menu has "Open Wayfinch" and a real "Quit". Clicking the tray icon brings the window back. The first time the window is closed, a notification explains that Wayfinch is still running in the tray.
- Only one copy runs: launching Wayfinch again brings the running window forward.
- "Launch at startup" is offered during onboarding and lives in Settings › Notifications. At login Wayfinch starts hidden in the tray.
- **Which tasks get reminders:** only tasks with a due time. Date-only tasks are covered by the daily digest. Events remind before their start. Done tasks and ended events never remind.
- **Per-item reminders:** the detail panel's Reminders row shows the item's reminders (marked "default" while it follows the global setting). Adding or removing one gives the item its own list (it can be empty, meaning no reminders); "Use default" goes back to the global setting. Choices: at the time, 5, 15, 30 minutes, 1 or 2 hours, 1 day before.
- **Global defaults** (Settings › Notifications, and onboarding): one choice each for tasks and events, or "No reminder".
- **Quiet hours:** a start and end time (default 22:00–07:00 once turned on; the window can cross midnight). Reminders and the digest that come due during quiet hours are held and shown when the window ends.
- **Missed reminders:** if Wayfinch wasn't running or the PC was asleep, reminders more than 30 minutes late are skipped rather than shown late. The first time notifications run, they start from "now" instead of replaying the past.
- **Daily digest:** once a day at or after the chosen time (default 08:00), even if the app starts later. Title "Morning, {name}! N things on today", with the first 3 items from Today and "+ N more". A free day gets a short "Nothing due today" note. Clicking it opens Wayfinch.
- **Snooze:** each reminder has 10 min / 1 hour / Tomorrow buttons. Clicking the reminder itself opens the item.

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
- A code-signed installer and automatic updates

Done before the 1.0 release (November 16, 2026): trademark searches for "Wayfinch" found no marks at the USPTO or CIPO, and the Microsoft Store has no app by that name. Similar marks exist: Finch Care PBC owns FINCH for its habit and self-care pet app (US Reg. 7992822; Canada No. 2422362, class 9), among many other coexisting "finch" software marks (FINCH from several owners, WILLOWFINCH, GOLDFINCH, GREYFINCH…). The name was kept for this free, open-source release; get a trademark lawyer's clearance before selling Wayfinch, listing it in the Microsoft Store or registering the name, and keep the branding away from virtual-pet and self-care themes.
