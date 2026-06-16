import '../../l10n/app_localizations.dart';

/// Maps thrown errors to short, user-readable messages (no SQL dumps).
abstract final class UserFacingError {
  /// Returns a safe message for UI feedback.
  static String message(AppLocalizations l10n, Object error) {
    if (error is StateError) {
      final msg = error.message;
      if (msg.isNotEmpty && !_looksTechnical(msg)) {
        return msg;
      }
    }

    if (error is ArgumentError) {
      final msg = error.message?.toString();
      if (msg != null && msg.isNotEmpty && !_looksTechnical(msg)) {
        return msg;
      }
    }

    final raw = error.toString();
    if (_looksTechnical(raw)) {
      return l10n.feedbackDatabaseError;
    }

    final cleaned = _cleanExceptionText(raw);
    if (cleaned.isEmpty || _looksTechnical(cleaned)) {
      return l10n.errorGeneric;
    }

    return l10n.errorGenericWithDetail(cleaned);
  }

  /// Wallet-specific business error codes from [TreasuryService].
  static String walletMessage(AppLocalizations l10n, Object error) {
    final raw = error.toString();
    if (raw.contains('duplicate_currency')) {
      return l10n.walletFormDuplicateCurrency;
    }
    if (raw.contains('account_has_transactions')) {
      return l10n.walletFormAccountHasTransactions;
    }
    return message(l10n, error);
  }

  /// Currency CRUD business error codes.
  static String currencyMessage(AppLocalizations l10n, Object error) {
    final raw = error.toString();
    if (raw.contains('base_currency_already_exists')) {
      return l10n.currencyBaseAlreadyExists;
    }
    if (raw.contains('currency_already_exists')) {
      return l10n.currencyAlreadyExists;
    }
    return message(l10n, error);
  }

  static bool _looksTechnical(String value) {
    return value.contains('SqliteException') ||
        value.contains('SQL logic error') ||
        value.contains('Causing statement') ||
        value.contains('package:') ||
        value.contains('PRAGMA') ||
        value.length > 160;
  }

  static String _cleanExceptionText(String raw) {
    return raw
        .replaceFirst(RegExp(r'^(\w+Exception|Error):\s*'), '')
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();
  }
}
