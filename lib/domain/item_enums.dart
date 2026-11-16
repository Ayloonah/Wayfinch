/// Enums shared by the data layer and domain logic.
///
/// Their `name`s are stored in the database and used in the AI exchange
/// format, so never rename an existing value.
library;

/// Whether an item is a task (due by a time) or an event (start to end).
enum ItemType {
  /// Something to do, optionally due by a date/time, that can be marked done.
  task,

  /// Something that happens from a start to an end; it has no checkbox.
  event,
}

/// How important an item is.
enum Priority {
  /// No priority set.
  none,

  /// Low priority.
  low,

  /// Medium priority.
  medium,

  /// High priority.
  high,
}

/// Where an item came from.
enum ItemSource {
  /// Created by the user in the app.
  manual,

  /// Added by an AI import.
  aiImport,

  /// Added by an .ics calendar import (see `Items.icsUid`).
  icsImport,
}
