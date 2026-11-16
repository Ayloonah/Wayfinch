import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../exchange/export_dialog.dart' show formatRules;
import '../home/home_controller.dart';
import '../onboarding/onboarding_flow.dart' show AiLoopDiagram;
import '../theme/tokens.dart';

/// "AI instructions": how to use Wayfinch with your AI, the loop diagram,
/// and the exact format rules the AI receives. (The sidebar destination is
/// still [Destination.help] internally.)
class AiInstructionsPane extends StatelessWidget {
  /// Creates the pane.
  const AiInstructionsPane({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final rules = formatRules(context, HomeScope.of(context).now);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
      children: [
        Text(
          l10n.navHelp,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Material(
              color: colors.panel,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.helpAiTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.helpAiBody,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    const AiLoopDiagram(),
                    const SizedBox(height: 22),
                    Text(
                      l10n.helpAiRulesTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.helpAiRulesBody,
                      style: TextStyle(fontSize: 14, color: colors.muted),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        // A code panel stays dark in both themes.
                        color: const Color(0xFF1B1F27),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        rules,
                        style: const TextStyle(
                          fontFamily: 'Consolas',
                          fontFamilyFallback: ['Courier New', 'monospace'],
                          fontSize: 13,
                          height: 1.55,
                          color: Color(0xFFE6E9EF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
