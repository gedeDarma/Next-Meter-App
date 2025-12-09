import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as tx_model;
import '../services/transaction_service.dart';
import '../services/data_service.dart';
import 'receipt_screen.dart';

class TransactionSummaryScreen extends StatefulWidget {
  final Customer customer;
  final double amount;
  final int waterPulse;
  final double serviceFee;
  final double totalPayment;
  final int counter;

  const TransactionSummaryScreen({
    super.key,
    required this.customer,
    required this.amount,
    required this.waterPulse,
    required this.serviceFee,
    required this.totalPayment,
    required this.counter,
  });

  @override
  State<TransactionSummaryScreen> createState() =>
      _TransactionSummaryScreenState();
}

class _TransactionSummaryScreenState extends State<TransactionSummaryScreen> {
  bool _isConfirming = false;

  void _confirmTransaction() {
    setState(() {
      _isConfirming = true;
    });

    // Simulate confirmation process
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final cnt = DataService.getTransactionCountByMeterId(widget.customer.meterId) + 1;
      final transaction = tx_model.Transaction(
        id: TransactionService.generateTransactionId(),
        customer: widget.customer,
        amount: widget.amount,
        electricPulse: widget.waterPulse,
        transactionDate: DateTime.now(),
        status: tx_model.TransactionStatus.completed,
        token: TransactionService.generateToken(),
        receipt: 'RCPT${DateTime.now().millisecondsSinceEpoch}',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(transaction: transaction, counter: cnt),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Confirm Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please review the transaction details before confirming',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow('Name', widget.customer.name),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Meter ID', widget.customer.meterId),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Address', widget.customer.address),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Phone', widget.customer.phone),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow(
                        'Amount',
                        TransactionService.formatRupiahValue(widget.amount),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Service Fee',
                        TransactionService.formatRupiahValue(widget.serviceFee),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Total Payment',
                        TransactionService.formatRupiahValue(widget.totalPayment),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Volume (m³)',
                        '${widget.waterPulse} m³',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Date & Time',
                        TransactionService.formatDateTime(DateTime.now()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Once confirmed, the transaction cannot be reversed. Please verify all details.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _confirmTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Transaction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isConfirming ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
}
