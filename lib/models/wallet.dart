import 'package:hive/hive.dart';

/// Wallet stores only initial balance; current balance is calculated from transactions.
class Wallet extends HiveObject {
  Wallet({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.initialBalance,
    required this.icon,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String currencyCode;
  final double initialBalance;
  final String icon;
  final DateTime createdAt;

  Wallet copyWith({
    String? id,
    String? name,
    String? currencyCode,
    double? initialBalance,
    String? icon,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 1;

  @override
  Wallet read(BinaryReader reader) {
    return Wallet(
      id: reader.readString(),
      name: reader.readString(),
      currencyCode: reader.readString(),
      initialBalance: reader.readDouble(),
      icon: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.currencyCode)
      ..writeDouble(obj.initialBalance)
      ..writeString(obj.icon)
      ..writeString(obj.createdAt.toIso8601String());
  }
}
