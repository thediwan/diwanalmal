/// Normalizes phone numbers for storage and WhatsApp links.
abstract final class PhoneHelper {
  /// Strips spaces, dashes, and parentheses. Returns null when empty.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    final withoutPlus = digits.startsWith('+') ? digits.substring(1) : digits;
    final cleaned = withoutPlus.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return null;
    return cleaned;
  }

  /// Validates that the normalized phone has a reasonable length.
  static bool isValid(String? raw) {
    final normalized = normalize(raw);
    if (normalized == null) return false;
    return normalized.length >= 8 && normalized.length <= 15;
  }
}
