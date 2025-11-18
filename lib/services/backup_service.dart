// c:\Users\ThinkPad\Documents\Flutter Project\next_meter\lib\services\backup_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/customer.dart';
import '../models/transaction.dart' as tx_model;
import '../models/app_settings.dart';

class BackupService {
  static Future<String> backupAll() async {
    final customersBox = Hive.box<Customer>('customers');
    final transactionsBox = Hive.box<tx_model.Transaction>('transactions');
    final settingsBox = Hive.box<AppSettings>('settings');

    final customers = customersBox.values.map((c) => c.toJson()).toList();
    final transactions = transactionsBox.values.map((t) => t.toJson()).toList();
    final settings = settingsBox.get('app')?.toJson();

    final payload = {
      'customers': customers,
      'transactions': transactions,
      'settings': settings,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/next_meter_backup.json');
    await file.writeAsString(jsonEncode(payload));
    return file.path;
  }

  static Future<void> restoreLatest() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/next_meter_backup.json');
    if (!await file.exists()) return;

    final text = await file.readAsString();
    final map = jsonDecode(text) as Map<String, dynamic>;

    final customersBox = Hive.box<Customer>('customers');
    final transactionsBox = Hive.box<tx_model.Transaction>('transactions');
    final settingsBox = Hive.box<AppSettings>('settings');

    final customers = (map['customers'] as List<dynamic>? ?? [])
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
    final transactions = (map['transactions'] as List<dynamic>? ?? [])
        .map((e) => tx_model.Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    final settingsMap = map['settings'] as Map<String, dynamic>?;

    await customersBox.clear();
    for (final c in customers) {
      await customersBox.put(c.id, c);
    }

    await transactionsBox.clear();
    for (final t in transactions) {
      await transactionsBox.put(t.id, t);
    }

    if (settingsMap != null) {
      await settingsBox.put('app', AppSettings.fromJson(settingsMap));
    }
  }
}