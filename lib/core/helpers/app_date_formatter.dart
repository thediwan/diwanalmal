/// Formats calendar dates for display using numeric `yyyy/MM/dd`.
abstract final class AppDateFormatter {
  /// Returns a zero-padded numeric date, e.g. `2026/06/20`.
  static String format(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }
}
