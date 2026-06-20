import 'package:flutter/material.dart';

import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/helpers/phone_helper.dart';
import '../../../core/helpers/whatsapp_message_helper.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/whatsapp_service.dart';

/// One participant row for the post-save WhatsApp reminder sheet.
class SplitWhatsAppParticipant {
  const SplitWhatsAppParticipant({
    required this.name,
    required this.phone,
    required this.shareAmount,
  });

  final String name;
  final String? phone;
  final double shareAmount;
}

/// Bottom sheet shown after saving a shared transaction.
class SplitWhatsAppSuccessSheet extends StatelessWidget {
  const SplitWhatsAppSuccessSheet({
    super.key,
    required this.participants,
    required this.transactionTitle,
    required this.currencyCode,
    required this.transactionDate,
    required this.localeName,
  });

  final List<SplitWhatsAppParticipant> participants;
  final String transactionTitle;
  final String currencyCode;
  final DateTime transactionDate;
  final String localeName;

  static Future<void> show(
    BuildContext context, {
    required List<SplitWhatsAppParticipant> participants,
    required String transactionTitle,
    required String currencyCode,
    required DateTime transactionDate,
    required String localeName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SplitWhatsAppSuccessSheet(
        participants: participants,
        transactionTitle: transactionTitle,
        currencyCode: currencyCode,
        transactionDate: transactionDate,
        localeName: localeName,
      ),
    );
  }

  Future<void> _send(
    BuildContext context,
    SplitWhatsAppParticipant participant,
  ) async {
    final l10n = context.l10n;
    final phone = PhoneHelper.normalize(participant.phone);
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappNoPhone)),
      );
      return;
    }

    final message = WhatsAppMessageHelper.splitDebtMessage(
      l10n: l10n,
      localeName: localeName,
      personName: participant.name,
      transactionTitle: transactionTitle,
      shareAmount: participant.shareAmount,
      currencyCode: currencyCode,
      transactionDate: transactionDate,
    );

    final opened = await WhatsAppService().openChat(
      phone: phone,
      message: message,
    );
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.transactionSplitSendWhatsappAfterSave,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final participant in participants)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(participant.name),
              subtitle: Text(
                CurrencyFormatter.formatCodeFirst(
                  participant.shareAmount,
                  currencyCode,
                ),
              ),
              trailing: IconButton(
                tooltip: l10n.whatsappSend,
                onPressed: participant.phone != null &&
                        participant.phone!.trim().isNotEmpty
                    ? () => _send(context, participant)
                    : null,
                icon: const Icon(Icons.chat_outlined),
                color: const Color(0xFF25D366),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
  }
}
