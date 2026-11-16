import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// The quick-add field at the top of the list. Understands dates, times,
/// `#tags` and `!priority` (see `parseQuickAdd`).
class QuickAddField extends StatefulWidget {
  /// Creates the field.
  const QuickAddField({super.key});

  @override
  State<QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends State<QuickAddField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit(String text) async {
    _controller.clear();
    _focus.requestFocus();
    await HomeScope.of(context).quickAdd(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.add, size: 18, color: colors.accentText),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              onSubmitted: _submit,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: l10n.quickAddHint,
                semanticCounterText: l10n.quickAddLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
