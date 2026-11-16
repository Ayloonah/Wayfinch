import 'package:flutter/material.dart';

import '../../data/import_repository.dart';
import '../../domain/exchange/import_plan.dart';
import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// Settings › Import history: every stored backup, each restorable.
/// Restoring first backs up the current list, so it can be undone too.
class ImportHistorySection extends StatelessWidget {
  /// Creates the section.
  const ImportHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final backups = controller.backups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Text(
            l10n.settingsImportHistory,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            l10n.settingsImportHistoryHelp(maxImportBackups),
            style: TextStyle(color: colors.muted),
          ),
        ),
        if (backups.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              l10n.importHistoryEmpty,
              style: TextStyle(
                color: colors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          for (final backup in backups) _BackupRow(backup: backup),
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({required this.backup});

  final ImportBackupInfo backup;

  @override
  Widget build(BuildContext context) {
    final f = Formats.of(context);
    final l10n = f.l10n;
    final when = l10n.dateWithTime(
      f.relativeDay(backup.createdAt, DateTime.now()),
      f.time(backup.createdAt),
    );
    final String what;
    if (backup.reason == BackupReason.restore) {
      what = l10n.backupBeforeRestore;
    } else {
      final mode = switch (backup.mode) {
        ImportMode.add => l10n.importAdd,
        ImportMode.replace => l10n.importReplace,
        null => null,
      };
      what = mode == null
          ? l10n.backupBeforeImport
          : backup.changes == null
          ? l10n.backupBeforeImportMode(mode)
          : l10n.backupBeforeImportDetail(mode, backup.changes!);
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(
        backup.reason == BackupReason.restore
            ? Icons.restore
            : Icons.download_outlined,
      ),
      title: Text(when),
      subtitle: Text('$what · ${l10n.backupItemCount(backup.itemCount)}'),
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
    if (ok != true) return;
    if (await controller.restoreBackup(backup.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
    }
  }
}
