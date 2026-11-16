import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// A choice in the tag picker: an existing tag, or a new one to create.
sealed class TagOption {
  const TagOption();
}

/// An existing tag.
class ExistingTag extends TagOption {
  /// Wraps [tag].
  const ExistingTag(this.tag);

  /// The tag.
  final Tag tag;
}

/// "Create “name”".
class NewTag extends TagOption {
  /// A new tag called [name].
  const NewTag(this.name);

  /// The name typed.
  final String name;
}

/// The options for [query]: existing tags not already on the item (names
/// starting with the query first, then names containing it), plus
/// "Create" when no tag has exactly that name.
List<TagOption> tagOptions({
  required Iterable<Tag> allTags,
  required Set<String> alreadyOn,
  required String query,
}) {
  final q = query.trim().toLowerCase();
  final available = allTags.where((t) => !alreadyOn.contains(t.id));
  final starts = <Tag>[];
  final contains = <Tag>[];
  for (final tag in available) {
    final name = tag.name.toLowerCase();
    if (name.startsWith(q)) {
      starts.add(tag);
    } else if (name.contains(q)) {
      contains.add(tag);
    }
  }
  int byName(Tag a, Tag b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  starts.sort(byName);
  contains.sort(byName);
  final exists = allTags.any((t) => t.name.toLowerCase() == q);
  return [
    for (final t in [...starts, ...contains]) ExistingTag(t),
    if (q.isNotEmpty && !exists) NewTag(query.trim()),
  ];
}

/// Text field with a dropdown of existing tags and a "Create" option.
/// Calls [onDone] after a tag was added, or when the user leaves the field.
class TagPicker extends StatefulWidget {
  /// Creates the picker for [item].
  const TagPicker({super.key, required this.item, required this.onDone});

  /// The item getting a tag.
  final Item item;

  /// Closes the picker.
  final VoidCallback onDone;

  @override
  State<TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) widget.onDone();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _pick(TagOption option) async {
    final controller = HomeScope.of(context);
    final item = controller.tree[widget.item.id] ?? widget.item;
    switch (option) {
      case ExistingTag(:final tag):
        await controller.addTagId(item, tag.id);
      case NewTag(:final name):
        await controller.addTag(item, name);
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 180,
      child: RawAutocomplete<TagOption>(
        textEditingController: _text,
        focusNode: _focus,
        optionsBuilder: (value) => tagOptions(
          allTags: controller.tagsById.values,
          alreadyOn: widget.item.tagIds.toSet(),
          query: value.text,
        ),
        displayStringForOption: (option) => switch (option) {
          ExistingTag(:final tag) => tag.name,
          NewTag(:final name) => name,
        },
        onSelected: _pick,
        fieldViewBuilder: (context, text, focus, onSubmitted) => TextField(
          controller: text,
          focusNode: focus,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(isDense: true, hintText: l10n.tagHint),
          onSubmitted: (_) => onSubmitted(),
        ),
        optionsViewBuilder: (context, onSelected, options) {
          final highlighted = AutocompleteHighlightedOption.of(context);
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: colors.panel,
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 260,
                  maxHeight: 260,
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  children: [
                    for (final (i, option) in options.indexed)
                      _OptionRow(
                        option: option,
                        highlighted: i == highlighted,
                        onTap: () => onSelected(option),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.highlighted,
    required this.onTap,
  });

  final TagOption option;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final (Widget leading, String label) = switch (option) {
      ExistingTag(:final tag) => (
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colors.tagColor(tag.color),
            shape: BoxShape.circle,
          ),
        ),
        tag.name,
      ),
      NewTag(:final name) => (
        Icon(Icons.add, size: 16, color: colors.accentText),
        l10n.createTag(name),
      ),
    };
    return InkWell(
      // Not focusable: taking focus from the field would close the picker
      // before the choice lands.
      canRequestFocus: false,
      onTap: onTap,
      child: Container(
        color: highlighted ? colors.accentSoft : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(width: 16, child: Center(child: leading)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: option is NewTag ? colors.accentText : colors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
