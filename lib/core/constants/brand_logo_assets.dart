import 'package:flutter/material.dart';

/// Theme-aware brand logo asset paths.
abstract final class BrandLogoAssets {
  static const lightTheme = 'assets/images/logo-dark.png';
  static const darkTheme = 'assets/images/logo-light.png';

  static String forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  static String forContext(BuildContext context) {
    return forBrightness(Theme.of(context).brightness);
  }
}
