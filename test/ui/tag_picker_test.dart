import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/item.dart';
import 'package:wayfinch/ui/detail/tag_picker.dart';

void main() {
  const school = Tag(id: 's', name: 'school', color: 0);
  const work = Tag(id: 'w', name: 'work', color: 0);
  const homework = Tag(id: 'h', name: 'Homework', color: 0);
  const all = [school, work, homework];

  List<String> labels(List<TagOption> options) => [
    for (final o in options)
      switch (o) {
        ExistingTag(:final tag) => tag.name,
        NewTag(:final name) => '+$name',
      },
  ];

  test('empty query lists every tag not already on the item', () {
    expect(labels(tagOptions(allTags: all, alreadyOn: {'w'}, query: '')), [
      'Homework',
      'school',
    ]);
  });

  test('prefix matches first, then contains; plus Create for a new name', () {
    expect(labels(tagOptions(allTags: all, alreadyOn: {}, query: 'wo')), [
      'work',
      'Homework',
      '+wo',
    ]);
  });

  test('an exact name (any case) never offers Create', () {
    expect(labels(tagOptions(allTags: all, alreadyOn: {}, query: 'School')), [
      'school',
    ]);
    // Even when that tag is already on the item.
    expect(
      labels(tagOptions(allTags: all, alreadyOn: {'s'}, query: 'school')),
      isEmpty,
    );
  });

  test('a brand-new name only offers Create, trimmed', () {
    expect(
      labels(tagOptions(allTags: all, alreadyOn: {}, query: '  errands ')),
      ['+errands'],
    );
  });
}
