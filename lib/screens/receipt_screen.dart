import 'package:flutter/material.dart';
import '../models/transaction.dart' as tx_model;
import '../services/transaction_service.dart';
import '../services/data_service.dart';
import 'home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class ReceiptScreen extends StatefulWidget {
  final tx_model.Transaction transaction;
  final int counter;

  const ReceiptScreen({super.key, required this.transaction, required this.counter});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late final String _encryption;
  late final String _permutation;
  String _buildPlan() {
    final meter = widget.transaction.customer.meterId.replaceAll(RegExp(r'\D'), '').padLeft(8, '0').substring(0, 8);
    final vol = widget.transaction.electricPulse.clamp(0, 999).toString().padLeft(3, '0');
    final ctr = widget.counter.clamp(0, 999).toString().padLeft(3, '0');
    return '$meter$vol$ctr';
  }

  String _buildKeygen() {
    final box = Hive.box<AppSettings>('settings');
    final settings = box.get('app');
    final keygenValue = (settings?.keygen ?? 0).toString().padLeft(7, '0');
    return keygenValue + keygenValue;
  }

  String _buildEncryption() {
    final plan = _buildPlan();
    final keygen = _buildKeygen();
    final buf = StringBuffer();
    for (int i = 0; i < 14; i++) {
      final p = int.parse(plan[i]);
      final k = int.parse(keygen[i]);
      buf.write((p + k) % 10);
    }
    return buf.toString();
  }

  String _getSettingsPermutation() {
    final box = Hive.box<AppSettings>('settings');
    final settings = box.get('app');
    final p = settings?.permutation ?? '0-1-2-3-4-5-6-7-8-9-10-11-12-13';
    final parts = p.split('-');
    final nums = parts.map((e) => int.tryParse(e) ?? -1).toList();
    final valid = nums.length == 14 && nums.toSet().length == 14 && nums.every((n) => n >= 0 && n <= 13);
    if (!valid) {
      final vals = List<int>.generate(14, (i) => i);
      return vals.join('-');
    }
    return nums.join('-');
  }

  String _buildEncryptedToken() {
    final enc = _encryption;
    final parts = _permutation.split('-');
    final indices = parts.map((p) => int.tryParse(p) ?? 0).toList();
    final buf = StringBuffer();
    int x = 0;
    for (int i = 0; i < 14; i++) {
      final idx = indices[i];
      final ch = enc[idx];
      final d = int.parse(ch);
      x ^= d;
      buf.write(ch);
    }
    buf.write((x ~/ 10).toString());
    buf.write((x % 10).toString());
    return buf.toString();
  }

  String _formatTokenBlocks(String t) {
    final b = StringBuffer();
    for (int i = 0; i < t.length; i++) {
      if (i > 0 && i % 4 == 0) b.write('-');
      b.write(t[i]);
    }
    return b.toString();
  }
  @override
  void initState() {
    super.initState();
    _encryption = _buildEncryption();
    _permutation = _getSettingsPermutation();
    final token = _formatTokenBlocks(_buildEncryptedToken());
    final saved = tx_model.Transaction(
      id: widget.transaction.id,
      customer: widget.transaction.customer,
      amount: widget.transaction.amount,
      electricPulse: widget.transaction.electricPulse,
      transactionDate: widget.transaction.transactionDate,
      status: widget.transaction.status,
      token: token,
      receipt: widget.transaction.receipt,
    );
    DataService.addRecentTransaction(saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Transaction Successful',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your water token has been generated',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Receipt Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildReceiptRow('Transaction ID', widget.transaction.id),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        'Date & Time',
                        TransactionService.formatDateTime(
                          widget.transaction.transactionDate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        'Receipt No',
                        widget.transaction.receipt ?? '-',
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildReceiptRow(
                        'Name',
                        widget.transaction.customer.name,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        'Meter ID',
                        widget.transaction.customer.meterId,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        'Address',
                        widget.transaction.customer.address,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        'Phone',
                        widget.transaction.customer.phone,
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Text(
                        'Transaction Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildReceiptRow(
                        'Amount',
                        TransactionService.formatRupiah(
                          widget.transaction.amount,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Volume (m³)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${widget.transaction.electricPulse} m³',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Token Parameters section hidden - uncomment if needed for debugging
              // Card(
              //   elevation: 3,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(20),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Token Parameters',
              //           style: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //             color: Theme.of(context).colorScheme.primary,
              //           ),
              //         ),
              //         const SizedBox(height: 15),
              //         _buildReceiptRow('Plan', _buildPlan()),
              //         const SizedBox(height: 10),
              //         _buildReceiptRow('Key', _buildKey()),
              //         const SizedBox(height: 10),
              //         _buildReceiptRow('Keygen', _buildKeygen()),
              //         const SizedBox(height: 10),
              //         _buildReceiptRow('Encryption', _encryption),
              //         const SizedBox(height: 10),
              //         _buildReceiptRow('Permutation', _permutation),
              //         const SizedBox(height: 10),
              //         _buildReceiptRow('Encrypted Token', _buildEncryptedToken()),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.vpn_key, color: Theme.of(context).colorScheme.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Water Token',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatTokenBlocks(_buildEncryptedToken()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 2,
                              fontFamily: 'Courier',
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Please save this token for water activation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Important Notes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNote('Please save your token in a safe place'),
                    _buildNote('Do not share your token with anyone'),
                    _buildNote('Token will be activated within 24 hours'),
                    _buildNote('For assistance, contact customer service'),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final t = widget.transaction;
                    final msg = 'NexMeter - Receipt\n'
                        'Transaction ID: ${t.id}\n'
                        'Receipt No: ${t.receipt ?? '-'}\n'
                        'Date & Time: ${TransactionService.formatDateTime(t.transactionDate)}\n'
                        'Customer: ${t.customer.name}\n'
                        'Meter ID: ${t.customer.meterId}\n'
                        'Amount: ${TransactionService.formatRupiah(t.amount)}\n'
                        'Volume (m³): ${t.electricPulse}\n'
                        // 'Plan: ${_buildPlan()}\n'
                        // 'Key: ${_buildKey()}\n'
                        // 'Keygen: ${_buildKeygen()}\n'
                        // 'Encryption: ${_encryption}\n'
                        // 'Permutation: ${_permutation}\n'
                        // 'Encrypted Token: ${_buildEncryptedToken()}\n'
                         'Token: ${_formatTokenBlocks(_buildEncryptedToken())}';
                    final encoded = Uri.encodeComponent(msg);
                    final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');
                    if (await canLaunchUrl(whatsappUri)) {
                      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                    } else {
                      final webUri = Uri.parse('https://wa.me/?text=$encoded');
                      await launchUrl(webUri, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text(
                        'Share Receipt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
