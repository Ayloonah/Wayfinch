import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../exchange/export_dialog.dart' show formatRules;
import '../home/home_controller.dart';
import '../onboarding/onboarding_flow.dart' show AiLoopDiagram;
import '../theme/tokens.dart';

/// One Help section.
class HelpSection {
  /// Creates a section.
  const HelpSection({
    required this.icon,
    required this.title,
    required this.body,
    this.code,
    this.diagram = false,
  });

  /// Section icon.
  final IconData icon;

  /// Title.
  final String title;

  /// Text.
  final String body;

  /// Optional code block (the format rules).
  final String? code;

  /// Whether to show the AI loop diagram.
  final bool diagram;

  /// Whether this section matches a search [query] (case-insensitive).
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '$title\n$body\n${code ?? ''}'.toLowerCase().contains(q);
  }
}

/// The Help sections, in the app language.
List<HelpSection> helpSections(BuildContext context, DateTime now) {
  final l10n = AppLocalizations.of(context);
  return [
    HelpSection(
      icon: Icons.wb_sunny_outlined,
      title: l10n.helpBasicsTitle,
      body: l10n.helpBasicsBody,
    ),
    HelpSection(
      icon: Icons.edit_outlined,
      title: l10n.helpItemsTitle,
      body: l10n.helpItemsBody,
    ),
    HelpSection(
      icon: Icons.account_tree_outlined,
      title: l10n.helpNestingTitle,
      body: l10n.helpNestingBody,
    ),
    HelpSection(
      icon: Icons.repeat,
      title: l10n.helpRecurringTitle,
      body: l10n.helpRecurringBody,
    ),
    HelpSection(
      icon: Icons.sell_outlined,
      title: l10n.helpTagsTitle,
      body: l10n.helpTagsBody,
    ),
    HelpSection(
      icon: Icons.auto_awesome_outlined,
      title: l10n.helpAiTitle,
      body: l10n.helpAiBody,
      diagram: true,
      code: formatRules(context, now),
    ),
    HelpSection(
      icon: Icons.event_outlined,
      title: l10n.helpCalendarTitle,
      body: l10n.helpCalendarBody,
    ),
    HelpSection(
      icon: Icons.notifications_none,
      title: l10n.helpNotificationsTitle,
      body: l10n.helpNotificationsBody,
    ),
    HelpSection(
      icon: Icons.palette_outlined,
      title: l10n.helpThemesTitle,
      body: l10n.helpThemesBody,
    ),
    HelpSection(
      icon: Icons.lock_outline,
      title: l10n.helpPasswordTitle,
      body: l10n.helpPasswordBody,
    ),
    HelpSection(
      icon: Icons.restore,
      title: l10n.helpBackupsTitle,
      body: l10n.helpBackupsBody,
    ),
  ];
}

/// Help: short, searchable sections.
class HelpPane extends StatefulWidget {
  /// Creates the pane.
  const HelpPane({super.key});

  @override
  State<HelpPane> createState() => _HelpPaneState();
}

class _HelpPaneState extends State<HelpPane> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final sections = helpSections(
      context,
      HomeScope.of(context).now,
    ).where((s) => s.matches(_query)).toList();
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
            constraints: const BoxConstraints(maxWidth: 720),
            child: TextField(
              onChanged: (q) => setState(() => _query = q),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.helpSearch,
                filled: true,
                fillColor: colors.panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (sections.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              l10n.helpNoResults,
              style: TextStyle(color: colors.muted),
            ),
          ),
        for (final section in sections)
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _SectionCard(
                // Searching opens the matching sections.
                key: ValueKey('${section.title}-${_query.isNotEmpty}'),
                section: section,
                expanded: _query.trim().isNotEmpty,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
    required this.section,
    required this.expanded,
  });

  final HelpSection section;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.panel,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: expanded,
          shape: const Border(),
          leading: Icon(section.icon, color: colors.accentText),
          title: Text(
            section.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              section.body,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            if (section.diagram) ...[
              const SizedBox(height: 14),
              const AiLoopDiagram(),
            ],
            if (section.code != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1F27),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  section.code!,
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
          ],
        ),
      ),
    );
  }
}
