import 'package:flutter/material.dart';

import '../../domain/views.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import '../widgets/finch_logo.dart';

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
          const Spacer(),
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
