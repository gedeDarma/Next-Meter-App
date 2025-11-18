// c:\Users\ThinkPad\Documents\Flutter Project\next_meter\lib\screens\settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/app_settings.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _serviceFeeCtrl;
  late final TextEditingController _baseAmountCtrl;
  late final TextEditingController _pulsesPerBaseCtrl;

  AppSettings _settings = AppSettings(
    currencySymbol: 'Rp',
    serviceFee: 3000,
    baseAmount: 10000,
    pulsesPerBase: 30,
  );

  @override
  void initState() {
    super.initState();
    final box = Hive.box<AppSettings>('settings');
    final existing = box.get('app');
    if (existing != null) {
      _settings = existing;
    } else {
      box.put('app', _settings);
    }
    _currencyCtrl = TextEditingController(text: _settings.currencySymbol);
    _serviceFeeCtrl = TextEditingController(text: _settings.serviceFee.toString());
    _baseAmountCtrl = TextEditingController(text: _settings.baseAmount.toString());
    _pulsesPerBaseCtrl = TextEditingController(text: _settings.pulsesPerBase.toString());
  }

  @override
  void dispose() {
    _currencyCtrl.dispose();
    _serviceFeeCtrl.dispose();
    _baseAmountCtrl.dispose();
    _pulsesPerBaseCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final currencySymbol = _currencyCtrl.text.trim().isEmpty ? 'Rp' : _currencyCtrl.text.trim();
    final serviceFee = int.tryParse(_serviceFeeCtrl.text.trim()) ?? 0;
    final baseAmount = int.tryParse(_baseAmountCtrl.text.trim()) ?? 0;
    final pulsesPerBase = int.tryParse(_pulsesPerBaseCtrl.text.trim()) ?? 0;

    final box = Hive.box<AppSettings>('settings');
    final updated = AppSettings(
      currencySymbol: currencySymbol,
      serviceFee: serviceFee,
      baseAmount: baseAmount,
      pulsesPerBase: pulsesPerBase,
    );
    await box.put('app', updated);
    setState(() {
      _settings = updated;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  Future<void> _backup() async {
    final path = await BackupService.backupAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved: $path')));
    }
  }

  Future<void> _restore() async {
    await BackupService.restoreLatest();
    final box = Hive.box<AppSettings>('settings');
    final updated = box.get('app') ?? _settings;
    setState(() {
      _settings = updated;
      _currencyCtrl.text = updated.currencySymbol;
      _serviceFeeCtrl.text = updated.serviceFee.toString();
      _baseAmountCtrl.text = updated.baseAmount.toString();
      _pulsesPerBaseCtrl.text = updated.pulsesPerBase.toString();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore complete')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionTitle('General'),
            const SizedBox(height: 8),
            _buildTextField('Currency Symbol', _currencyCtrl, prefix: const Icon(Icons.currency_exchange)),
            const SizedBox(height: 12),
            _buildTextField('Service Fee', _serviceFeeCtrl, keyboardType: TextInputType.number, prefix: const Icon(Icons.request_quote)),
            const SizedBox(height: 12),
            _buildTextField('Base Amount', _baseAmountCtrl, keyboardType: TextInputType.number, prefix: const Icon(Icons.attach_money)),
            const SizedBox(height: 12),
            _buildTextField('Pulses per Base', _pulsesPerBaseCtrl, keyboardType: TextInputType.number, prefix: const Icon(Icons.water)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Backup & Restore'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _backup,
                child: const Text('Backup Data'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restore,
                child: const Text('Restore Latest Backup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Row(
      children: [
        const Icon(Icons.settings, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    Widget? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}