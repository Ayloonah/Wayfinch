import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/ui/list/item_row.dart';

void main() {
  test('every nesting level indents further, smaller steps past 4', () {
    final indents = [for (var d = 0; d <= 8; d++) indentFor(d)];
    for (var d = 1; d < indents.length; d++) {
      expect(indents[d], greaterThan(indents[d - 1]), reason: 'depth $d');
    }
    expect(indents[1] - indents[0], 34);
    expect(indents[6] - indents[5], 16);
  });
}
