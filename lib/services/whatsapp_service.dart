import '../core/helpers/phone_helper.dart';
import 'external_url_launcher.dart';

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

    return ExternalUrlLauncher.open(uri.toString());
  }
}
