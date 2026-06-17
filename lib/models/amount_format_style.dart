/// How monetary amounts are grouped and which decimal separator is shown.
///
/// Persisted in [AppSettings] and exposed via [SettingsProvider] for a future
/// settings screen.
enum AmountFormatStyle {
  /// `1,234.56` — thousands `,` decimal `.`
  western(0),

  /// `1.234,56` — thousands `.` decimal `,`
  european(1),

  /// `1234.56` — no thousands separator
  plain(2);

  const AmountFormatStyle(this.storageIndex);

  final int storageIndex;

  /// Resolves a stored Hive index to a style (defaults to [western]).
  static AmountFormatStyle fromStorageIndex(int? index) {
    if (index == null) return western;
    for (final style in values) {
      if (style.storageIndex == index) return style;
    }
    return western;
  }
}
