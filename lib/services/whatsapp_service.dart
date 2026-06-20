import 'package:url_launcher/url_launcher.dart';

import '../core/helpers/phone_helper.dart';

/// Opens WhatsApp chats via wa.me deep links.
class WhatsAppService {
  /// Opens WhatsApp with [message] pre-filled for [phone].
  Future<bool> openChat({
    required String phone,
    required String message,
  }) async {
    final digits = PhoneHelper.normalize(phone);
    if (digits == null || digits.isEmpty) return false;

    final uri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
    );

    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
