import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';

/// Settings › General: which view the app opens in.
class GeneralSection extends StatelessWidget {
  /// Creates the section.
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final l10n = AppLocalizations.of(context);
    String name(Destination d) => switch (d) {
      Destination.today => l10n.navToday,
      Destination.upcoming => l10n.navUpcoming,
      Destination.all => l10n.navAll,
      Destination.done => l10n.navDone,
      Destination.tag || Destination.help || Destination.settings => '',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Text(
            l10n.settingsGeneral,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(l10n.settingStartView),
          trailing: SizedBox(
            width: 250,
            child: DropdownButton<Destination>(
              isExpanded: true,
              value: controller.startView,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onChanged: (view) {
                if (view != null) controller.setStartView(view);
              },
              items: [
                for (final view in HomeController.startViews)
                  DropdownMenuItem(value: view, child: Text(name(view))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
