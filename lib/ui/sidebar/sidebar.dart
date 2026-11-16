import 'package:flutter/material.dart';

import '../../domain/views.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import '../widgets/finch_logo.dart';
import '../widgets/tag_color_dialog.dart';

/// The left sidebar: logo, greeting, views and settings.
class Sidebar extends StatelessWidget {
  /// Creates the sidebar.
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: colors.sidebar,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(now: controller.now),
          const SizedBox(height: 24),
          _NavButton(
            destination: Destination.today,
            icon: Icons.wb_sunny_outlined,
            label: l10n.navToday,
            trailing: '${controller.view(AppView.today).count}',
          ),
          _NavButton(
            destination: Destination.upcoming,
            icon: Icons.calendar_month_outlined,
            label: l10n.navUpcoming,
            trailing: '${controller.view(AppView.upcoming).count}',
          ),
          _NavButton(
            destination: Destination.all,
            icon: Icons.format_list_bulleted,
            label: l10n.navAll,
            trailing: '${controller.view(AppView.all).count}',
          ),
          _NavButton(
            destination: Destination.done,
            icon: Icons.check_circle_outline,
            label: l10n.navDone,
            trailing: l10n.doneThisWeekShort(
              controller.view(AppView.done).doneThisWeek,
            ),
          ),
          const SizedBox(height: 20),
          const Expanded(child: _TagList()),
          _NavButton(
            destination: Destination.settings,
            icon: Icons.tune,
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

/// "TAGS": one row per tag with its open-item count, then the overdue auto
/// tag. Scrolls when there are many.
/// The overdue auto tag's dot: the user's color, or the theme's warning
/// color by default.
Color _overdueDot(HomeController controller, WayfinchColors colors) {
  final picked = controller.overdueTagColor;
  return picked == null ? colors.warningText : colors.tagColor(picked);
}

class _TagList extends StatelessWidget {
  const _TagList();

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final tags = controller.tagsById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final selectedTag = controller.destination == Destination.tag
        ? controller.tagFilter
        : null;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: Text(
            l10n.sidebarTags.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: colors.muted,
            ),
          ),
        ),
        for (final tag in tags)
          _TagRow(
            label: tag.name,
            dot: colors.tagColor(tag.color),
            count: controller.tagCount(tag.id),
            selected: selectedTag == tag.id,
            onTap: () => controller.openTag(tag.id),
            onChangeColor: () => changeTagColor(context, tag),
          ),
        _TagRow(
          label: l10n.overdueTag,
          dot: _overdueDot(controller, colors),
          count: controller.overdueCount,
          selected: selectedTag == overdueTagId,
          auto: true,
          onTap: () => controller.openTag(overdueTagId),
          onChangeColor: () => changeOverdueTagColor(context),
        ),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.label,
    required this.dot,
    required this.count,
    required this.selected,
    required this.onTap,
    this.onChangeColor,
    this.auto = false,
  });

  final String label;
  final Color dot;
  final int count;
  final bool selected;
  final bool auto;
  final VoidCallback onTap;

  /// Opens the color dialog; null for the overdue auto tag.
  final VoidCallback? onChangeColor;

  Future<void> _showMenu(BuildContext context, Offset position) async {
    final l10n = AppLocalizations.of(context);
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final choice = await showMenu<bool>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: true,
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.changeTagColorMenu),
          ),
        ),
      ],
    );
    if (choice == true) onChangeColor?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final dotWidget = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? colors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          // Right-click: "Change color...".
          onSecondaryTapUp: onChangeColor == null
              ? null
              : (details) => _showMenu(context, details.globalPosition),
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  // The dot is also a button for the color dialog.
                  if (onChangeColor == null)
                    SizedBox(width: 34, child: Center(child: dotWidget))
                  else
                    SizedBox(
                      width: 34,
                      height: 40,
                      child: Tooltip(
                        message: l10n.changeTagColor,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onChangeColor,
                          child: Center(child: dotWidget),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selected ? colors.accentText : colors.text,
                      ),
                    ),
                  ),
                  if (auto) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.warningBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.autoTag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.warningText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '$count',
                    style: TextStyle(fontSize: 13, color: colors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = WayfinchColors.of(context);
    final greeting = now.hour < 12
        ? l10n.greetingMorning
        : now.hour < 18
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const FinchLogo(),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                greeting,
                style: TextStyle(fontSize: 13, color: colors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.icon,
    required this.label,
    this.trailing,
  });

  final Destination destination;
  final IconData icon;
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final selected = controller.destination == destination;
    final foreground = selected ? colors.accentText : colors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? colors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => controller.go(destination),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Flexible(
                      child: Text(
                        trailing!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? colors.accentText : colors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
