import 'package:flutter/material.dart';
import '../models/transaction.dart' as tx_model;
import '../services/transaction_service.dart';
import '../services/data_service.dart';
import 'home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiptScreen extends StatefulWidget {
  final tx_model.Transaction transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  void initState() {
    super.initState();
    // Save transaction to recent activity
    DataService.addRecentTransaction(widget.transaction);
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
                      const Text(
                        'Transaction Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066CC),
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
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066CC),
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
                      const Text(
                        'Transaction Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066CC),
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
                            'Water Pulse',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${widget.transaction.electricPulse} Water Pulse',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vpn_key, color: Color(0xFF0066CC), size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Water Token',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0066CC),
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
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.transaction.token ?? '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
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
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    final msg = 'Next Meter - Receipt\n'
                        'Transaction ID: ${t.id}\n'
                        'Receipt No: ${t.receipt ?? '-'}\n'
                        'Date & Time: ${TransactionService.formatDateTime(t.transactionDate)}\n'
                        'Customer: ${t.customer.name}\n'
                        'Meter ID: ${t.customer.meterId}\n'
                        'Amount: ${TransactionService.formatRupiah(t.amount)}\n'
                        'Water Pulse: ${t.electricPulse}\n'
                        'Token: ${t.token ?? '-'}';
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
                    foregroundColor: const Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color(0xFF0066CC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
