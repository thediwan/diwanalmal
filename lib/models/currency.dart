import 'package:hive/hive.dart';

/// Stored currency with exchange rate relative to the base currency.
class Currency extends HiveObject {
  Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateToBase,
    required this.isBase,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final String symbol;
  final double rateToBase;
  final bool isBase;
  final DateTime createdAt;

  Currency copyWith({
    String? id,
    String? code,
    String? name,
    String? symbol,
    double? rateToBase,
    bool? isBase,
    DateTime? createdAt,
  }) {
    return Currency(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      rateToBase: rateToBase ?? this.rateToBase,
      isBase: isBase ?? this.isBase,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 0;

  @override
  Currency read(BinaryReader reader) {
    return Currency(
      id: reader.readString(),
      code: reader.readString(),
      name: reader.readString(),
      symbol: reader.readString(),
      rateToBase: reader.readDouble(),
      isBase: reader.readBool(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.code)
      ..writeString(obj.name)
      ..writeString(obj.symbol)
      ..writeDouble(obj.rateToBase)
      ..writeBool(obj.isBase)
      ..writeString(obj.createdAt.toIso8601String());
  }
}
