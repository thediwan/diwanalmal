/// Common currency presets shown during onboarding and currency setup.
abstract final class AppConstants {
  static const String appName = 'بيت المال';

  static const List<Map<String, String>> presetCurrencies = [
    {'code': 'USD', 'name': 'دولار أمريكي', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'يورو', 'symbol': '€'},
    {'code': 'TRY', 'name': 'ليرة تركية', 'symbol': '₺'},
    {'code': 'SYP', 'name': 'ليرة سورية', 'symbol': 'ل.س'},
    {'code': 'SAR', 'name': 'ريال سعودي', 'symbol': 'ر.س'},
    {'code': 'AED', 'name': 'درهم إماراتي', 'symbol': 'د.إ'},
    {'code': 'EGP', 'name': 'جنيه مصري', 'symbol': 'ج.م'},
    {'code': 'GBP', 'name': 'جنيه إسترليني', 'symbol': '£'},
  ];

  static const List<Map<String, dynamic>> walletIconOptions = [
    {'key': 'cash', 'icon': '💵', 'label': 'كاش'},
    {'key': 'bank', 'icon': '🏦', 'label': 'بنك'},
    {'key': 'wallet', 'icon': '👛', 'label': 'محفظة'},
    {'key': 'card', 'icon': '💳', 'label': 'بطاقة'},
    {'key': 'savings', 'icon': '🐷', 'label': 'ادخار'},
  ];
}
