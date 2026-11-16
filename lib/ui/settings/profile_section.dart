import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_session.dart';
import '../../data/encryption/key_vault.dart';
import '../../l10n/app_localizations.dart';
import '../app.dart' show SessionScope;
import '../home/home_controller.dart';
import '../security/password_widgets.dart';
import '../theme/tokens.dart';

/// Settings › Profile: first name, and the password (set, change, remove,
/// new recovery code).
class ProfileSection extends StatefulWidget {
  /// Creates the section.
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _name = TextEditingController();
  Timer? _save;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _name.text = HomeScope.of(context).firstName;
    }
  }

  @override
  void dispose() {
    _save?.cancel();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final session = SessionScope.maybeOf(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            l10n.settingsProfile,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.onboardingNameLabel),
            onChanged: (text) {
              _save?.cancel();
              _save = Timer(const Duration(milliseconds: 400), () {
                // Optional: an empty name just means "Good morning".
                controller.setFirstName(text);
              });
            },
          ),
        ),
        if (session != null) ...[
          const SizedBox(height: 12),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Icon(
              session.hasPassword ? Icons.lock : Icons.lock_open_outlined,
              color: session.hasPassword ? colors.accentText : colors.muted,
            ),
            title: Text(l10n.profilePassword),
            subtitle: Text(
              session.hasPassword
                  ? l10n.profilePasswordOn
                  : l10n.profilePasswordOff,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: session.hasPassword
                  ? [
                      OutlinedButton(
                        onPressed: () => _change(context, session),
                        child: Text(l10n.profileChangePassword),
                      ),
                      OutlinedButton(
                        onPressed: () => _newCode(context, session),
                        child: Text(l10n.profileNewRecoveryCode),
                      ),
                      TextButton(
                        onPressed: () => _remove(context, session),
                        child: Text(l10n.profileRemovePassword),
                      ),
                    ]
                  : [
                      FilledButton(
                        onPressed: () => _set(context, session),
                        child: Text(l10n.profileSetPassword),
                      ),
                    ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _set(BuildContext context, AppSession session) async {
    final setup = await showDialog<VaultSetup>(
      context: context,
      builder: (_) =>
          SessionScope(session: session, child: const _SetPasswordDialog()),
    );
    if (setup == null) return;
    await session.enablePassword(setup);
  }

  Future<void> _change(BuildContext context, AppSession session) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordActionDialog(
        title: l10n.profileChangePassword,
        needsNew: true,
        action: (current, next) => session.changePassword(current, next!),
      ),
    );
    if (ok == true) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profilePasswordChanged)),
      );
    }
  }

  Future<void> _remove(BuildContext context, AppSession session) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordActionDialog(
        title: l10n.profileRemovePassword,
        body: l10n.profileRemoveBody,
        action: (current, _) => session.disablePassword(current),
      ),
    );
  }

  Future<void> _newCode(BuildContext context, AppSession session) async {
    final l10n = AppLocalizations.of(context);
    String? code;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordActionDialog(
        title: l10n.profileNewRecoveryCode,
        body: l10n.profileNewCodeBody,
        action: (current, _) async {
          code = await session.newRecoveryCode(current);
          return code != null;
        },
      ),
    );
    if (ok != true || code == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ShowCodeDialog(code: code!),
    );
  }
}

/// Set a password: fields, then the recovery code (with "I saved it").
/// Returns the prepared [VaultSetup]; the caller turns encryption on.
class _SetPasswordDialog extends StatefulWidget {
  const _SetPasswordDialog();

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  String? _password;
  VaultSetup? _setup;
  bool _saved = false;
  bool _busy = false;

  Future<void> _prepare() async {
    if (_password == null) return;
    setState(() => _busy = true);
    final setup = await SessionScope.maybeOf(context)!
        .preparePassword(_password!);
    if (mounted) {
      setState(() {
        _busy = false;
        _setup = setup;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final setup = _setup;
    return AlertDialog(
      title: Text(setup == null ? l10n.profileSetPassword : l10n.recoveryTitle),
      content: SizedBox(
        width: 440,
        child: setup == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PasswordFields(
                    onChanged: (p) => setState(() => _password = p),
                    onSubmit: _prepare,
                  ),
                  const SizedBox(height: 14),
                  const PasswordWarning(),
                ],
              )
            : RecoveryCodeView(
                code: setup.recoveryCode,
                saved: _saved,
                onSavedChanged: (v) => setState(() => _saved = v),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.promptCancel),
        ),
        if (setup == null)
          FilledButton(
            onPressed: _password == null || _busy ? null : _prepare,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(l10n.onboardingNext),
          )
        else
          FilledButton(
            onPressed: _saved ? () => Navigator.pop(context, setup) : null,
            child: Text(l10n.profileTurnOn),
          ),
      ],
    );
  }
}

/// Asks for the current password (and a new one when [needsNew]) and runs
/// [action]; shows "wrong password" when it returns false.
class _PasswordActionDialog extends StatefulWidget {
  const _PasswordActionDialog({
    required this.title,
    required this.action,
    this.body,
    this.needsNew = false,
  });

  final String title;
  final String? body;
  final bool needsNew;
  final Future<bool> Function(String current, String? next) action;

  @override
  State<_PasswordActionDialog> createState() => _PasswordActionDialogState();
}

class _PasswordActionDialogState extends State<_PasswordActionDialog> {
  final _current = TextEditingController();
  String? _next;
  bool _busy = false;
  bool _wrong = false;

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  bool get _ready =>
      _current.text.isNotEmpty && (!widget.needsNew || _next != null);

  Future<void> _run() async {
    if (!_ready || _busy) return;
    setState(() {
      _busy = true;
      _wrong = false;
    });
    final ok = await widget.action(_current.text, _next);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _busy = false;
        _wrong = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.body != null) ...[
              Text(widget.body!),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _current,
              autofocus: true,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _run(),
              decoration: InputDecoration(
                labelText: l10n.profileCurrentPassword,
                errorText: _wrong ? l10n.unlockWrongPassword : null,
              ),
            ),
            if (widget.needsNew) ...[
              const SizedBox(height: 16),
              PasswordFields(onChanged: (p) => setState(() => _next = p)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(l10n.promptCancel),
        ),
        FilledButton(
          onPressed: _ready && !_busy ? _run : null,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(l10n.promptConfirm),
        ),
      ],
    );
  }
}

class _ShowCodeDialog extends StatefulWidget {
  const _ShowCodeDialog({required this.code});

  final String code;

  @override
  State<_ShowCodeDialog> createState() => _ShowCodeDialogState();
}

class _ShowCodeDialogState extends State<_ShowCodeDialog> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.recoveryTitle),
      content: SizedBox(
        width: 440,
        child: RecoveryCodeView(
          code: widget.code,
          saved: _saved,
          onSavedChanged: (v) => setState(() => _saved = v),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _saved ? () => Navigator.pop(context) : null,
          child: Text(l10n.recoveryDone),
        ),
      ],
    );
  }
}
