import 'dart:io' show Platform, Process, ProcessException;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Opens external URLs without the url_launcher plugin (avoids androidx.browser).
abstract final class ExternalUrlLauncher {
  static const MethodChannel _channel =
      MethodChannel('com.example.baytalmal/external_url');

  /// Opens [url] in the platform handler (browser, WhatsApp, etc.).
  static Future<bool> open(String url) async {
    if (url.trim().isEmpty) return false;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final opened = await _channel.invokeMethod<bool>(
          'openUrl',
          <String, String>{'url': url},
        );
        return opened ?? false;
      } on PlatformException {
        return false;
      }
    }

    if (kIsWeb) return false;

    try {
      if (Platform.isWindows) {
        await Process.run('cmd', <String>['/c', 'start', '', url]);
        return true;
      }
      if (Platform.isLinux) {
        await Process.run('xdg-open', <String>[url]);
        return true;
      }
      if (Platform.isMacOS) {
        await Process.run('open', <String>[url]);
        return true;
      }
    } on ProcessException {
      return false;
    }

    return false;
  }
}
