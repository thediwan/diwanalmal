/// Category row mapped for transaction UI.
class TransactionCategory {
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.type,
    this.iconKey,
    this.colorHex,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String type;
  final String? iconKey;
  final String? colorHex;
  final bool isDefault;
}
