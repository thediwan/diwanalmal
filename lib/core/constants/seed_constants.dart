/// Controls automatic demo/test database seeding only.
/// System categories ([SystemCategoryService]) are always ensured separately.
abstract final class SeedConstants {
  /// When false, all seed services skip inserting generated rows.
  /// Pass `--dart-define=SEED_DEMO=true` for screenshot / demo builds.
  static const bool enabled = bool.fromEnvironment(
    'SEED_DEMO',
    defaultValue: false,
  );
}
