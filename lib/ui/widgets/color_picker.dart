import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/color_math.dart';
import '../theme/tokens.dart';

/// Opens a color picker dialog. [presets] show as quick swatches above the
/// picker. Returns the chosen color, or null when cancelled.
Future<Color?> showColorPicker(
  BuildContext context, {
  required Color initial,
  String? title,
  List<Color> presets = const [],
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) =>
        _ColorPickerDialog(initial: initial, title: title, presets: presets),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({
    required this.initial,
    required this.title,
    required this.presets,
  });

  final Color initial;
  final String? title;
  final List<Color> presets;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial);
  late final _hex = TextEditingController(text: toHex(widget.initial));

  Color get _color => _hsv.toColor();

  void _set(HSVColor hsv, {bool updateHex = true}) {
    setState(() => _hsv = hsv);
    if (updateHex) _hex.text = toHex(hsv.toColor());
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = WayfinchColors.of(context);
    return AlertDialog(
      title: widget.title == null ? null : Text(widget.title!),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.presets.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in widget.presets)
                    Swatch(
                      color: preset,
                      selected: preset.toARGB32() == _color.toARGB32(),
                      onTap: () => _set(HSVColor.fromColor(preset)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            AspectRatio(
              aspectRatio: 1.6,
              child: _SaturationValueArea(
                hsv: _hsv,
                onChanged: _set,
                label: l10n.colorArea,
              ),
            ),
            const SizedBox(height: 12),
            _HueSlider(hsv: _hsv, onChanged: _set, label: l10n.colorHue),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _hex,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: l10n.colorHex,
                    ),
                    onChanged: (text) {
                      final parsed = parseHex(text);
                      if (parsed != null) {
                        _set(HSVColor.fromColor(parsed), updateHex: false);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.promptCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _color),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// A round color swatch button.
class Swatch extends StatelessWidget {
  /// Creates a swatch.
  const Swatch({
    super.key,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.size = 28,
    this.tooltip,
  });

  /// Fill color.
  final Color color;

  /// Called when tapped.
  final VoidCallback onTap;

  /// Whether to show the selection ring.
  final bool selected;

  /// Diameter.
  final double size;

  /// Optional tooltip / accessible label.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final swatch = Semantics(
      button: true,
      selected: selected,
      label: tooltip ?? toHex(color),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.text : colors.border,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  size: size * 0.55,
                  color: mostContrasting(color, const [
                    Colors.black,
                    Colors.white,
                  ]),
                )
              : null,
        ),
      ),
    );
    return tooltip == null ? swatch : Tooltip(message: tooltip!, child: swatch);
  }
}

class _SaturationValueArea extends StatelessWidget {
  const _SaturationValueArea({
    required this.hsv,
    required this.onChanged,
    required this.label,
  });

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  final String label;

  void _update(Offset local, Size size) {
    final s = (local.dx / size.width).clamp(0.0, 1.0);
    final v = 1 - (local.dy / size.height).clamp(0.0, 1.0);
    onChanged(hsv.withSaturation(s).withValue(v));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Semantics(
          label: label,
          child: GestureDetector(
            onPanDown: (d) => _update(d.localPosition, size),
            onPanUpdate: (d) => _update(d.localPosition, size),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: hsv.saturation * size.width - 8,
                    top: (1 - hsv.value) * size.height - 8,
                    child: _Thumb(color: hsv.toColor()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({
    required this.hsv,
    required this.onChanged,
    required this.label,
  });

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          void update(Offset local) => onChanged(
            hsv.withHue((local.dx / width).clamp(0.0, 1.0) * 359.9),
          );
          return Semantics(
            label: label,
            slider: true,
            value: '${hsv.hue.round()}°',
            child: GestureDetector(
              onPanDown: (d) => update(d.localPosition),
              onPanUpdate: (d) => update(d.localPosition),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            for (var h = 0; h <= 360; h += 60)
                              HSVColor.fromAHSV(1, h % 360, 1, 1).toColor(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: hsv.hue / 360 * width - 8,
                    top: 2,
                    child: _Thumb(
                      color: HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3)],
    ),
  );
}
