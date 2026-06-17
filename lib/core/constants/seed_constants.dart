/// Controls automatic demo/test database seeding only.
/// System categories ([SystemCategoryService]) are always ensured separately.
abstract final class SeedConstants {
  /// When false, all seed services skip inserting generated rows.
  static const bool enabled = false;
}
