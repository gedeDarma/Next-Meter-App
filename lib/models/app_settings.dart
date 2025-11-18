// c:\Users\ThinkPad\Documents\Flutter Project\next_meter\lib\models\app_settings.dart
import 'package:hive/hive.dart';

class AppSettings {
  final String currencySymbol;
  final int serviceFee;
  final int baseAmount;
  final int pulsesPerBase;

  AppSettings({
    required this.currencySymbol,
    required this.serviceFee,
    required this.baseAmount,
    required this.pulsesPerBase,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currencySymbol: json['currencySymbol'] ?? 'Rp',
      serviceFee: (json['serviceFee'] ?? 0) as int,
      baseAmount: (json['baseAmount'] ?? 0) as int,
      pulsesPerBase: (json['pulsesPerBase'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencySymbol': currencySymbol,
      'serviceFee': serviceFee,
      'baseAmount': baseAmount,
      'pulsesPerBase': pulsesPerBase,
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
    return AppSettings(
      currencySymbol: currencySymbol,
      serviceFee: serviceFee,
      baseAmount: baseAmount,
      pulsesPerBase: pulsesPerBase,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.write(obj.currencySymbol);
    writer.write(obj.serviceFee);
    writer.write(obj.baseAmount);
    writer.write(obj.pulsesPerBase);
  }
}