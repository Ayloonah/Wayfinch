import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../theme/tokens.dart';

/// Password + confirmation fields. [onChanged] gets the password when both
/// match and aren't empty, else null.
class PasswordFields extends StatefulWidget {
  /// Creates the fields.
  const PasswordFields({super.key, required this.onChanged, this.onSubmit});

  /// Called with the valid password, or null.
  final ValueChanged<String?> onChanged;

  /// Called when Enter is pressed in the confirmation field.
  final VoidCallback? onSubmit;

  @override
  State<PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _changed() {
    setState(() {});
    final ok = _password.text.isNotEmpty && _password.text == _confirm.text;
    widget.onChanged(ok ? _password.text : null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mismatch =
        _confirm.text.isNotEmpty && _confirm.text != _password.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _password,
          obscureText: !_show,
          autofocus: true,
          onChanged: (_) => _changed(),
          decoration: InputDecoration(
            labelText: l10n.passwordLabel,
            suffixIcon: IconButton(
              tooltip: _show ? l10n.passwordHide : l10n.passwordShow,
              onPressed: () => setState(() => _show = !_show),
              icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirm,
          obscureText: !_show,
          onChanged: (_) => _changed(),
          onSubmitted: (_) => widget.onSubmit?.call(),
          decoration: InputDecoration(
            labelText: l10n.passwordConfirmLabel,
            errorText: mismatch ? l10n.passwordMismatch : null,
          ),
        ),
      ],
    );
  }
}

/// The plain warning shown wherever a password is set: no recovery
/// without the password or the recovery code.
class PasswordWarning extends StatelessWidget {
  /// Creates the warning.
  const PasswordWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        border: Border.all(color: colors.warningBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 18, color: colors.warningText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context).passwordWarning,
              style: TextStyle(
                color: colors.warningText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a recovery code once, with Copy and Save, and an "I saved it"
/// checkbox. [onSavedChanged] reports the checkbox.
class RecoveryCodeView extends StatelessWidget {
  /// Creates the view.
  const RecoveryCodeView({
    super.key,
    required this.code,
    required this.saved,
    required this.onSavedChanged,
  });

  /// The code to show.
  final String code;

  /// Whether "I saved it" is checked.
  final bool saved;

  /// Called when the checkbox changes.
  final ValueChanged<bool> onSavedChanged;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.recoveryExplain),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.subtle,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: SelectableText(
            code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Consolas',
              fontFamilyFallback: ['Courier New', 'monospace'],
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                messenger?.showSnackBar(
                  SnackBar(content: Text(l10n.recoveryCopied)),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.recoveryCopy),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final location = await getSaveLocation(
                  suggestedName: 'wayfinch-recovery-code.txt',
                );
                if (location == null) return;
                await File(location.path)
                    .writeAsString('${l10n.recoveryFileHeader}\n\n$code\n');
              },
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.recoverySave),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: saved,
          onChanged: (v) => onSavedChanged(v ?? false),
          title: Text(
            l10n.recoverySavedCheck,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// A centered card used by the unlock and new-password screens.
class SecurityCard extends StatelessWidget {
  /// Creates the card.
  const SecurityCard({super.key, required this.children});

  /// Card contents.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: colors.panel,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colors.border),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
