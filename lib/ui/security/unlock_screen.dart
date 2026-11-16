import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../app.dart' show SessionScope;
import '../theme/tokens.dart';
import '../widgets/finch_logo.dart';
import 'password_widgets.dart';

/// Shown at start when a password is set: password, or the recovery code.
class UnlockScreen extends StatefulWidget {
  /// Creates the screen.
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _text = TextEditingController();
  bool _useRecovery = false;
  bool _busy = false;
  bool _wrong = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final session = SessionScope.maybeOf(context)!;
    if (_text.text.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _wrong = false;
    });
    final ok = _useRecovery
        ? await session.unlockWithRecoveryCode(_text.text)
        : await session.unlockWithPassword(_text.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _wrong = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = WayfinchColors.of(context);
    return SecurityCard(
      children: [
        const Center(child: FinchLogo(size: 72)),
        const SizedBox(height: 16),
        Text(
          l10n.unlockTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          _useRecovery ? l10n.unlockRecoveryHint : l10n.unlockHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.muted),
        ),
        const SizedBox(height: 24),
        TextField(
          key: ValueKey(_useRecovery),
          controller: _text,
          autofocus: true,
          obscureText: !_useRecovery,
          enabled: !_busy,
          onSubmitted: (_) => _unlock(),
          decoration: InputDecoration(
            labelText: _useRecovery
                ? l10n.recoveryCodeLabel
                : l10n.passwordLabel,
            errorText: _wrong
                ? (_useRecovery
                      ? l10n.unlockWrongCode
                      : l10n.unlockWrongPassword)
                : null,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            backgroundColor: colors.accent,
            foregroundColor: colors.onAccent,
          ),
          onPressed: _busy ? null : _unlock,
          child: _busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onAccent,
                  ),
                )
              : Text(l10n.unlock),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() {
                  _useRecovery = !_useRecovery;
                  _wrong = false;
                  _text.clear();
                }),
          child: Text(
            _useRecovery ? l10n.unlockUsePassword : l10n.unlockUseRecovery,
          ),
        ),
      ],
    );
  }
}

/// After unlocking with the recovery code: choose a new password (or keep
/// the old one).
class NewPasswordScreen extends StatefulWidget {
  /// Creates the screen.
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  String? _password;
  bool _busy = false;

  Future<void> _finish(String? password) async {
    setState(() => _busy = true);
    await SessionScope.maybeOf(context)!.finishRecovery(password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = WayfinchColors.of(context);
    return SecurityCard(
      children: [
        Text(
          l10n.newPasswordTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(l10n.newPasswordBody, style: TextStyle(color: colors.muted)),
        const SizedBox(height: 20),
        PasswordFields(
          onChanged: (p) => setState(() => _password = p),
          onSubmit: () {
            if (_password != null) _finish(_password);
          },
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            backgroundColor: colors.accent,
            foregroundColor: colors.onAccent,
          ),
          onPressed: _password == null || _busy
              ? null
              : () => _finish(_password),
          child: Text(l10n.newPasswordSave),
        ),
        TextButton(
          onPressed: _busy ? null : () => _finish(null),
          child: Text(l10n.newPasswordKeepOld),
        ),
      ],
    );
  }
}
