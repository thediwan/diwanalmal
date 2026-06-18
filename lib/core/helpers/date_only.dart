/// Strips time from [value] for date-only storage and display.
DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

/// Today's date at midnight local time.
DateTime todayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
