<img src="docs/brand/wayfinch-mark.svg" alt="" width="96" align="right">

# Wayfinch

**A to-do app that teams up with your AI.**

Ask your AI to break a big project into steps, and Wayfinch turns its answer into a real task list with due dates, subtasks and reminders. When plans change, hand your list back to your AI, let it update things, and import the result. You see every change before anything happens.

Offline-first, private by default, and designed to keep you on track without stressing you out.

> 🚧 **Status:** early development, Windows desktop first. The core to-do list works (Today, Upcoming, All, Done and Tags views, subtasks, recurrence, quick add), along with light/dark themes, accents and a custom theme builder, the full AI loop (Export for AI, Import with preview, Add or Replace, undo), first-run setup with an optional password that encrypts your data, and reminders with a morning digest, quiet hours and snooze (Wayfinch keeps running in the system tray), calendar import/export with `.ics` files, and daily backups. Every planned milestone is in; see the [roadmap](#roadmap).

---

## How the AI loop works

```
+--------------+   Export for AI   +---------------+
|   Wayfinch   | ----------------> |    Your AI    |
|  (your list) |                   | (any chatbot) |
|              | <---------------- |               |
+--------------+      Import       +---------------+
```
 
1. **Export for AI.** Wayfinch builds one copyable block: the format rules your AI needs to follow, your own instructions ("break tasks into steps under 2 hours"), and your list.
2. **Ask your AI.** Paste it into ChatGPT, Claude, Gemini or whatever you use, along with your request ("I have a final project due Dec 5, plan it out").
3. **Import.** Paste the reply back. Wayfinch shows you what's new, changed and removed, then you choose to **add** it to your list or **replace** your list.

Your current list is always backed up before a replace, and you can undo any import.

## Features

- ✅ **Tasks and events.** Tasks have due dates; events have a start and end time.
- 🪆 **Unlimited subtasks.** Break things down as far as you want, each with its own due date.
- 🔁 **Recurring items**, priorities and color-coded tags.
- 🙈 **Done stays out of the way.** Completed items are hidden but tracked in a Done view, so you can see your progress.
- ⚠️ **Gentle overdue nudges.** A banner you can snooze, never a wall of red.
- 📅 **Calendar import/export** with `.ics` files (Google, Outlook, Apple).
- 🔔 **Reminders**, a daily digest and quiet hours.
- 🎨 **Themes:** light and dark, five accent colors (Sky, Honey, Meadow, Lilac, Mono) or your own custom theme.
- 🔒 **Optional password** that actually encrypts your data, plus daily automatic backups.
- 🇬🇧🇫🇷 **English and French.**

## Privacy

Wayfinch has no accounts, no servers and no tracking. Your data lives on your computer. When you share your list with an AI, it's because you copied it there yourself, and you choose exactly what's included.

## Tech stack

| | |
| --- | --- |
| Framework | [Flutter](https://flutter.dev) (Windows desktop) |
| Database | [Drift](https://drift.simonbinder.eu) on SQLite, encrypted with SQLCipher |
| Recurrence | iCal RRULE |
| Localization | Flutter l10n (ARB), English + French |

## Getting started (development)

**Requirements**

- Flutter SDK (stable channel) with Windows desktop support enabled
- Visual Studio with the "Desktop development with C++" workload, including the **C++ ATL** component (needed for Windows notifications)

**Run it**

```bash
git clone https://github.com/Ayloonah/Wayfinch.git
cd Wayfinch
flutter pub get
flutter run -d windows
```

**Try it with sample data** (in-memory database, nothing is saved):

```bash
flutter run -d windows -t dev/demo_main.dart
```

**Try first-run setup** (the real app on a new throwaway data folder each launch, so setup, the password and the tutorial start fresh without touching your list):

```bash
flutter run -d windows -t dev/fresh_main.dart
```

**Checks**

```bash
flutter analyze
flutter test
```

**Build the installer** (needs [Inno Setup 6](https://jrsoftware.org/isinfo.php), e.g. `winget install JRSoftware.InnoSetup`):

```bash
powershell -ExecutionPolicy Bypass -File installer/build.ps1
```

This builds the app and writes `build/installer/WayfinchSetup-<version>.exe` (the version comes from `pubspec.yaml`). The setup wizard is in English and French and installs for the current user by default (no admin), or for everyone on the PC. Uninstalling keeps your list unless you tick "Also delete my list, settings and daily backups". The installer isn't code-signed yet, so Windows SmartScreen warns the first time it runs.

## Docs

- [`docs/SPEC.md`](docs/SPEC.md): the full product spec (features, data model, AI format, design)
- [`CLAUDE.md`](CLAUDE.md): guidelines for AI-assisted development in this repo

## Roadmap

- [x] **Foundation:** project setup, encrypted database, data model, EN/FR
- [x] **Core list:** views, nesting, completing items, recurrence, quick add
- [x] **Look and feel:** themes, accents, custom theme builder, tags, overdue banner
- [x] **AI loop:** Export for AI, Import with preview, add vs replace, undo
- [x] **Onboarding and Help:** setup, optional password with encryption and recovery code, tutorial, Help
- [x] **Notifications:** reminders, daily digest, quiet hours, snooze, tray
- [x] **Calendar and backups:** `.ics` import/export, daily backups

Later: calendar view, Android/iOS/macOS/web, sync.

## License

Wayfinch is free and open source under the [GNU General Public License v3.0](LICENSE). You're free to use, study, change and share it, and any version you distribute must stay open source under the same license.

"Wayfinch" and the Wayfinch logo are not covered by the license. Forks are welcome, but please give yours a different name.
