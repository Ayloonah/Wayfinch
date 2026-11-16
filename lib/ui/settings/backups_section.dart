import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../data/daily_backups.dart';
import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// Settings › Backups: where the daily backups go, "Back up now", and the
/// last few, each restorable.
class BackupsSection extends StatelessWidget {
  /// Creates the section for [service].
  const BackupsSection({super.key, required this.service});

  /// The daily backup service.
  final DailyBackupService service;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: service,
    builder: (context, _) => _content(context),
  );

  Widget _content(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final backups = service.backups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Text(
            l10n.settingsBackups,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            l10n.settingsBackupsHelp(maxDailyBackups),
            style: TextStyle(color: colors.muted),
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: const Icon(Icons.folder_outlined),
          title: Text(l10n.backupsFolder),
          subtitle: Text(
            service.folder.path,
            style: TextStyle(color: colors.muted),
          ),
          trailing: Wrap(
            spacing: 4,
            children: [
              if (!service.usesDefaultFolder)
                TextButton(
                  onPressed: () => service.setFolder(null),
                  child: Text(l10n.backupsUseDefault),
                ),
              OutlinedButton(
                onPressed: () => _pickFolder(context),
                child: Text(l10n.backupsChangeFolder),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _backUpNow(context),
              icon: const Icon(Icons.backup_outlined),
              label: Text(l10n.backupsNow),
            ),
          ),
        ),
        if (backups.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              l10n.backupsEmpty,
              style: TextStyle(
                color: colors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          for (final b in backups) _DailyRow(service: service, backup: b),
      ],
    );
  }

  Future<void> _pickFolder(BuildContext context) async {
    final path = await getDirectoryPath(
      initialDirectory: service.folder.existsSync()
          ? service.folder.path
          : null,
    );
    if (path != null) await service.setFolder(path);
  }

  Future<void> _backUpNow(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await service.backUpNow();
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupsDone)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupsFailed)));
    }
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({required this.service, required this.backup});

  final DailyBackupService service;
  final DailyBackup backup;

  @override
  Widget build(BuildContext context) {
    final f = Formats.of(context);
    final l10n = f.l10n;
    final kb = (backup.size / 1024).ceil();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(backup.hasVault ? Icons.lock_outline : Icons.inventory_2),
      title: Text(f.relativeDay(backup.day, DateTime.now())),
      subtitle: Text(l10n.backupsSize(kb)),
      trailing: OutlinedButton(
        onPressed: () => _restore(context),
        child: Text(l10n.backupRestore),
      ),
    );
  }

  Future<void> _restore(BuildContext context) async {
    final controller = HomeScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRestoreTitle),
        content: Text(l10n.backupRestoreBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.promptCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    var result = await service.restore(backup);
    while (result == DailyRestoreResult.needsPassword ||
        result == DailyRestoreResult.wrongPassword) {
      if (!context.mounted) return;
      final secret = await showDialog<String>(
        context: context,
        builder: (_) => _OldPasswordDialog(
          wrong: result == DailyRestoreResult.wrongPassword,
        ),
      );
      if (secret == null || secret.isEmpty) return;
      result = await service.restore(backup, secret: secret);
    }
    if (result == DailyRestoreResult.restored) controller.select(null);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result == DailyRestoreResult.restored
              ? l10n.backupRestored
              : l10n.backupsUnreadable,
        ),
      ),
    );
  }
}

/// Asks for the password (or recovery code) a backup was made with.
class _OldPasswordDialog extends StatefulWidget {
  const _OldPasswordDialog({required this.wrong});

  final bool wrong;

  @override
  State<_OldPasswordDialog> createState() => _OldPasswordDialogState();
}

class _OldPasswordDialogState extends State<_OldPasswordDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.backupsOldPasswordTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.backupsOldPasswordBody),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                errorText: widget.wrong ? l10n.unlockWrongPassword : null,
              ),
              onSubmitted: (v) => Navigator.pop(context, v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.promptCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _text.text),
          child: Text(l10n.backupRestore),
        ),
      ],
    );
  }
}
