import 'item.dart';
import 'sorting.dart';

/// Fast parent/child lookups over a flat list of items.
class ItemTree {
  /// Indexes [items].
  ItemTree(Iterable<Item> items) {
    for (final item in items) {
      _byId[item.id] = item;
    }
    for (final item in _byId.values) {
      (_children[item.parentId] ??= []).add(item);
    }
    for (final list in _children.values) {
      list.sort(compareItems);
    }
  }

  final Map<String, Item> _byId = {};
  final Map<String?, List<Item>> _children = {};

  /// All items.
  Iterable<Item> get all => _byId.values;

  /// The item with [id], or null.
  Item? operator [](String? id) => id == null ? null : _byId[id];

  /// Direct children of [id] (top-level items when null), in default order.
  List<Item> childrenOf(String? id) => _children[id] ?? const [];

  /// Every descendant of [id], depth first.
  List<Item> descendantsOf(String id) {
    final result = <Item>[];
    void walk(String parent) {
      for (final child in childrenOf(parent)) {
        result.add(child);
        walk(child.id);
      }
    }

    walk(id);
    return result;
  }

  /// Ancestors of [id], nearest first.
  List<Item> ancestorsOf(String id) {
    final result = <Item>[];
    final seen = <String>{id};
    var parent = this[this[id]?.parentId];
    while (parent != null && seen.add(parent.id)) {
      result.add(parent);
      parent = this[parent.parentId];
    }
    return result;
  }
}
