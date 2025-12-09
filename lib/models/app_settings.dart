import 'package:hive/hive.dart';

class AppSettings {
  final String currencySymbol;
  final int serviceFee;
  final int baseAmount;
  final int pulsesPerBase;
  final int keygen;
  final String permutation;

  AppSettings({
    required this.currencySymbol,
    required this.serviceFee,
    required this.baseAmount,
    required this.pulsesPerBase,
    required this.keygen,
    required this.permutation,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currencySymbol: json['currencySymbol'] ?? 'Rp',
      serviceFee: (json['serviceFee'] ?? 0) as int,
      baseAmount: (json['baseAmount'] ?? 0) as int,
      pulsesPerBase: (json['pulsesPerBase'] ?? 0) as int,
      keygen: (json['keygen'] ?? 0) as int,
      permutation: (json['permutation'] ?? '0-1-2-3-4-5-6-7-8-9-10-11-12-13') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencySymbol': currencySymbol,
      'serviceFee': serviceFee,
      'baseAmount': baseAmount,
      'pulsesPerBase': pulsesPerBase,
      'keygen': keygen,
      'permutation': permutation,
    };
  }
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final currencySymbol = reader.read() as String;
    final serviceFee = reader.read() as int;
    final baseAmount = reader.read() as int;
    final pulsesPerBase = reader.read() as int;
    int keygen = 0;
    try {
      keygen = reader.read() as int;
    } catch (_) {}
    String permutation = '0-1-2-3-4-5-6-7-8-9-10-11-12-13';
    try {
      permutation = reader.read() as String;
    } catch (_) {}
    return AppSettings(
      currencySymbol: currencySymbol,
      serviceFee: serviceFee,
      baseAmount: baseAmount,
      pulsesPerBase: pulsesPerBase,
      keygen: keygen,
      permutation: permutation,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.write(obj.currencySymbol);
    writer.write(obj.serviceFee);
    writer.write(obj.baseAmount);
    writer.write(obj.pulsesPerBase);
    writer.write(obj.keygen);
    writer.write(obj.permutation);
  }
}
