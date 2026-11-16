import 'package:flutter/material.dart';

import '../detail/detail_panel.dart';
import '../list/list_pane.dart';
import '../prompts/prompts.dart';
import '../settings/settings_pane.dart';
import '../sidebar/sidebar.dart';
import 'home_controller.dart';

/// The three-pane layout: sidebar | list | detail panel.
class HomeScreen extends StatefulWidget {
  /// Creates the screen around [controller].
  const HomeScreen({super.key, required this.controller});

  /// App state and actions.
  final HomeController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.asker = (kind, count) =>
        showRulePrompt(context, kind, count);
  }

  @override
  Widget build(BuildContext context) {
    return HomeScope(
      controller: widget.controller,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final controller = widget.controller;
            if (!controller.loaded) return const SizedBox.shrink();
            final view = controller.destination.view;
            final selected = controller.selected;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Sidebar(),
                Expanded(
                  child: view == null
                      ? const SettingsPane()
                      : ListPane(view: view),
                ),
                if (selected != null && view != null)
                  DetailPanel(key: ValueKey(selected.id), item: selected),
              ],
            );
          },
        ),
      ),
    );
  }
}
