/// Default time windows for editing and deleting transactions.
///
/// Override via [AppSettings] once exposed in the settings UI.
abstract final class TransactionPolicyDefaults {
  static const int deleteWindowHours = 3;
  static const int editWindowDays = 1;
}

/// Evaluates whether a record is still within the allowed delete/edit window.
abstract final class TransactionPolicy {
  /// True when [createdAt] is within [deleteWindowHours] of now.
  static bool canDelete({
    required DateTime createdAt,
    required int deleteWindowHours,
    DateTime? now,
  }) {
    final hours = deleteWindowHours > 0
        ? deleteWindowHours
        : TransactionPolicyDefaults.deleteWindowHours;
    final reference = now ?? DateTime.now();
    return reference.difference(createdAt) <= Duration(hours: hours);
  }

  /// True when [createdAt] is within [editWindowDays] of now.
  static bool canEdit({
    required DateTime createdAt,
    required int editWindowDays,
    DateTime? now,
  }) {
    final days = editWindowDays > 0
        ? editWindowDays
        : TransactionPolicyDefaults.editWindowDays;
    final reference = now ?? DateTime.now();
    return reference.difference(createdAt) <= Duration(days: days);
  }
}
