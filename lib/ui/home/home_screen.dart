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
  const HomeScreen({super.key, required this.controller, this.onReady});

  /// App state and actions.
  final HomeController controller;

  /// Called once, after the first frame with data, with a context inside
  /// the screen (used by the dev demo to open a dialog for screenshots).
  final void Function(BuildContext context)? onReady;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _readyCalled = false;

  void _maybeReady(BuildContext context) {
    final onReady = widget.onReady;
    if (onReady == null || _readyCalled) return;
    _readyCalled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) onReady(context);
    });
  }

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
            _maybeReady(context);
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
