import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Builds localized WhatsApp messages for split debt reminders.
abstract final class WhatsAppMessageHelper {
  /// Debt reminder for a split participant share.
  static String splitDebtMessage({
    required AppLocalizations l10n,
    required String localeName,
    required String personName,
    required String transactionTitle,
    required double shareAmount,
    required String currencyCode,
    required DateTime transactionDate,
  }) {
    final date = DateFormat.yMMMd(localeName).format(transactionDate);
    return l10n.whatsappSplitDebtMessage(
      personName,
      transactionTitle,
      shareAmount.toStringAsFixed(2),
      currencyCode,
      date,
    );
  }
}
