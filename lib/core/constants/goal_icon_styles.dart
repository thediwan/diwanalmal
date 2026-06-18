import 'package:flutter/cupertino.dart';

/// Selectable icon keys for financial goals (matches add-goal mockup).
abstract final class GoalIconStyles {
  static const String car = 'car';
  static const String house = 'house';
  static const String plane = 'plane';
  static const String graduation = 'graduation';
  static const String laptop = 'laptop';
  static const String savings = 'savings';
  static const String gift = 'gift';

  static const List<String> selectable = [
    car,
    house,
    plane,
    graduation,
    laptop,
    savings,
    gift,
  ];

  /// Default icon when the user does not pick one.
  static const String defaultStyle = car;

  /// Legacy emoji stored on treasury rows for goal wallets.
  static String legacyEmoji(String? style) {
    return switch (style) {
      car => '🚗',
      house => '🏠',
      plane => '✈️',
      graduation => '🎓',
      laptop => '💻',
      savings => '💰',
      gift => '🎁',
      _ => '🎯',
    };
  }

  /// Resolves a persisted key to a display icon.
  static IconData iconFor(String? style) {
    return switch (style) {
      car => CupertinoIcons.car_detailed,
      house => CupertinoIcons.house_fill,
      plane => CupertinoIcons.airplane,
      graduation => CupertinoIcons.book_fill,
      laptop => CupertinoIcons.device_laptop,
      savings => CupertinoIcons.money_dollar_circle_fill,
      gift => CupertinoIcons.gift_fill,
      _ => CupertinoIcons.flag_fill,
    };
  }
}
