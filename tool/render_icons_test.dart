// Renders the themed Windows icons (tray, running window, taskbar) from the
// in-app mark painter, which uses the same geometry as
// docs/brand/wayfinch-mark.svg and wayfinch-mark-dark.svg.
//
// Not part of the regular test run. Regenerate with:
//
//   flutter test tool/render_icons_test.dart
//
// It writes PNGs to build/icon_render/ and packs them into
// assets/icons/wayfinch_light.ico and wayfinch_dark.ico.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/ui/widgets/finch_logo.dart';

/// Sizes Windows asks for: small icons (tray, title bar) at 100–200% scale,
/// big icons (taskbar, Alt+Tab), and 256 for large views.
const _sizes = [16, 20, 24, 32, 40, 48, 64, 96, 128, 256];

Future<Uint8List> _render(int size, {required bool dark}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  WayfinchMarkPainter(dark: dark)
      .paint(canvas, Size(size.toDouble(), size.toDouble()));
  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// One .ico with a 32-bit BMP (DIB) entry per size: the format every
/// Windows icon loader understands.
Uint8List _ico(Map<int, Uint8List> rgbaBySize) {
  final entries = <int, Uint8List>{};
  for (final MapEntry(key: size, value: rgba) in rgbaBySize.entries) {
    final maskStride = ((size + 31) ~/ 32) * 4;
    final dib = BytesBuilder();
    final header = ByteData(40)
      ..setUint32(0, 40, Endian.little)
      ..setInt32(4, size, Endian.little)
      ..setInt32(8, size * 2, Endian.little)
      ..setUint16(12, 1, Endian.little)
      ..setUint16(14, 32, Endian.little)
      ..setUint32(20, size * size * 4 + maskStride * size, Endian.little);
    dib.add(header.buffer.asUint8List());
    for (var y = size - 1; y >= 0; y--) {
      for (var x = 0; x < size; x++) {
        final i = (y * size + x) * 4;
        // RGBA (premultiplied off: rawRgba is straight alpha) → BGRA.
        dib.add([rgba[i + 2], rgba[i + 1], rgba[i], rgba[i + 3]]);
      }
    }
    dib.add(Uint8List(maskStride * size));
    entries[size] = dib.toBytes();
  }
  final out = BytesBuilder();
  final dir = ByteData(6 + 16 * entries.length)
    ..setUint16(2, 1, Endian.little)
    ..setUint16(4, entries.length, Endian.little);
  var offset = 6 + 16 * entries.length;
  var i = 0;
  for (final MapEntry(key: size, value: data) in entries.entries) {
    final at = 6 + 16 * i++;
    dir
      ..setUint8(at, size % 256)
      ..setUint8(at + 1, size % 256)
      ..setUint16(at + 4, 1, Endian.little)
      ..setUint16(at + 6, 32, Endian.little)
      ..setUint32(at + 8, data.length, Endian.little)
      ..setUint32(at + 12, offset, Endian.little);
    offset += data.length;
  }
  out.add(dir.buffer.asUint8List());
  for (final data in entries.values) {
    out.add(data);
  }
  return out.toBytes();
}

void main() {
  testWidgets('render the themed Windows icons', (tester) async {
    await tester.runAsync(() async {
      Directory('assets/icons').createSync(recursive: true);
      for (final dark in [false, true]) {
        final images = {
          for (final size in _sizes) size: await _render(size, dark: dark),
        };
        final name = dark ? 'wayfinch_dark' : 'wayfinch_light';
        File('assets/icons/$name.ico').writeAsBytesSync(_ico(images));
      }
    });
  });
}
