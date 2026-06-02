import 'package:uuid/uuid.dart';

/// Generates unique IDs for local records.
abstract final class UuidHelper {
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
