import 'package:flutter/material.dart';

/// Icon keys persisted on [Categories.icon] rows.
abstract final class CategoryIconStyles {
  static const String shopping = 'shopping';
  static const String food = 'food';
  static const String transport = 'transport';
  static const String home = 'home';
  static const String health = 'health';
  static const String sport = 'sport';
  static const String bills = 'bills';
  static const String salary = 'salary';
  static const String freelance = 'freelance';
  static const String investment = 'investment';
  static const String other = 'other';

  static IconData iconFor(String? key) {
    return switch (key) {
      shopping => Icons.shopping_bag_outlined,
      food => Icons.restaurant_outlined,
      transport => Icons.directions_car_outlined,
      home => Icons.home_outlined,
      health => Icons.medical_services_outlined,
      sport => Icons.fitness_center_outlined,
      bills => Icons.receipt_long_outlined,
      salary => Icons.payments_outlined,
      freelance => Icons.work_outline,
      investment => Icons.trending_up_outlined,
      _ => Icons.category_outlined,
    };
  }

  static Color colorFor(String? keyHex, {Color fallback = const Color(0xFF6B7280)}) {
    if (keyHex == null || keyHex.isEmpty) return fallback;
    final hex = keyHex.replaceFirst('#', '');
    if (hex.length != 6) return fallback;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return fallback;
    return Color(0xFF000000 | value);
  }

  /// Icons available when creating or editing a category.
  static const List<String> selectableIconKeys = [
    shopping,
    food,
    transport,
    home,
    health,
    sport,
    bills,
    salary,
    freelance,
    investment,
    other,
  ];

  /// Preset accent colors for the category form.
  static const List<String> presetColorHexes = [
    '#2563EB',
    '#EA580C',
    '#7C3AED',
    '#0891B2',
    '#DC2626',
    '#16A34A',
    '#CA8A04',
    '#1A56BE',
    '#059669',
    '#6B7280',
  ];
}
