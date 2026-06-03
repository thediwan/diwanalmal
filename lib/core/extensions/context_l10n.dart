import 'package:flutter/widgets.dart';
import 'package:baytalmal/l10n/app_localizations.dart';

/// Project localization shortcut per Cursor rules.
extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
