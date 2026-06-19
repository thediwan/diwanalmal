/// User-selectable font size preset applied app-wide via [TextScaler].
enum FontSizePreference {
  /// Design baseline — scale factor 1.0.
  normal(0, 1.0),

  /// Moderate readability bump.
  large(1, 1.15),

  /// Strong accessibility; capped to limit layout overflow.
  extraLarge(2, 1.25);

  const FontSizePreference(this.storageIndex, this.scaleFactor);

  final int storageIndex;

  /// Linear multiplier passed to [TextScaler.linear].
  final double scaleFactor;

  /// Resolves a stored Hive index (defaults to [normal]).
  static FontSizePreference fromStorageIndex(int? index) {
    if (index == null) return normal;
    for (final pref in values) {
      if (pref.storageIndex == index) return pref;
    }
    return normal;
  }
}
