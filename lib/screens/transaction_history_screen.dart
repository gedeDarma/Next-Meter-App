import 'package:flutter/material.dart';
import '../models/transaction.dart' as tx_model;
import '../services/transaction_service.dart';
import '../services/data_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum _HistoryFilter { today, last7, range }

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {

  _HistoryFilter _filter = _HistoryFilter.today;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  String _formatLongDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }



  void _showTransactionDetail(tx_model.Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transaction Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailField('Transaction ID', transaction.id),
                const SizedBox(height: 10),
                _buildDetailField('Customer', transaction.customer.name),
                const SizedBox(height: 10),
                _buildDetailField('Meter ID', transaction.customer.meterId),
                const SizedBox(height: 10),
                _buildDetailField(
                  'Amount',
                  TransactionService.formatRupiah(transaction.amount),
                ),
                const SizedBox(height: 10),
                _buildDetailField(
                  'Volume (m³)',
                  '${transaction.electricPulse} m³',
                ),
                const SizedBox(height: 10),
                _buildDetailField(
                  'Date & Time',
                  TransactionService.formatDateTime(transaction.transactionDate),
                ),
                const SizedBox(height: 10),
                _buildDetailField('Receipt', transaction.receipt ?? '-'),
                const SizedBox(height: 15),
                if (transaction.token != null) ...[
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Token:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      transaction.token!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share to WhatsApp'),
              onPressed: () async {
                final msg = 'NexMeter - Transaction\n'
                    'ID: ${transaction.id}\n'
                    'Customer: ${transaction.customer.name}\n'
                    'Meter ID: ${transaction.customer.meterId}\n'
                    'Amount: ${TransactionService.formatRupiah(transaction.amount)}\n'
                    'Volume (m³): ${transaction.electricPulse}\n'
                    'Date: ${TransactionService.formatDateTime(transaction.transactionDate)}\n'
                    'Token: ${transaction.token ?? '-'}';
                final encoded = Uri.encodeComponent(msg);
                final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                } else {
                  final webUri = Uri.parse('https://wa.me/?text=$encoded');
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Today'),
                  selected: _filter == _HistoryFilter.today,
                  onSelected: (v) {
                    if (v) setState(() => _filter = _HistoryFilter.today);
                  },
                ),
                ChoiceChip(
                  label: const Text('Last 7 days'),
                  selected: _filter == _HistoryFilter.last7,
                  onSelected: (v) {
                    if (v) setState(() => _filter = _HistoryFilter.last7);
                  },
                ),
                ChoiceChip(
                  label: const Text('Range'),
                  selected: _filter == _HistoryFilter.range,
                  onSelected: (v) async {
                    if (!v) return;
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: (_rangeStart != null && _rangeEnd != null)
                          ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
                          : null,
                    );
                    if (picked != null) {
                      setState(() {
                        _rangeStart = DateTime(picked.start.year, picked.start.month, picked.start.day);
                        _rangeEnd = DateTime(picked.end.year, picked.end.month, picked.end.day);
                        _filter = _HistoryFilter.range;
                      });
                    } else {
                      setState(() => _filter = _HistoryFilter.range);
                    }
                  },
                ),
                if (_filter == _HistoryFilter.range && _rangeStart != null && _rangeEnd != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${_rangeStart!.day}/${_rangeStart!.month}/${_rangeStart!.year} - ${_rangeEnd!.day}/${_rangeEnd!.month}/${_rangeEnd!.year}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<tx_model.Transaction>>(
              valueListenable: Hive.box<tx_model.Transaction>('transactions').listenable(),
              builder: (context, box, _) {
                final all = DataService.getAllTransactions();
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                List<tx_model.Transaction> list = all.where((t) {
                  final d = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
                  switch (_filter) {
                    case _HistoryFilter.today:
                      return d == today;
                    case _HistoryFilter.last7:
                      final start = today.subtract(const Duration(days: 6));
                      return d.compareTo(start) >= 0 && d.compareTo(today) <= 0;
                    case _HistoryFilter.range:
                      if (_rangeStart == null || _rangeEnd == null) return true;
                      return d.compareTo(_rangeStart!) >= 0 && d.compareTo(_rangeEnd!) <= 0;
                  }
                }).toList();

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different filter',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                final Map<DateTime, List<tx_model.Transaction>> groups = {};
                for (final t in list) {
                  final d = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
                  groups.putIfAbsent(d, () => []).add(t);
                }
                final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final d in dates) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        child: Text(
                          _formatLongDate(d),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      for (final transaction in groups[d]!) Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: InkWell(
                          onTap: () => _showTransactionDetail(transaction),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.customer.name,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text('ID: ${transaction.customer.meterId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                                      child: Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Amount', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Text(
                                          TransactionService.formatRupiah(transaction.amount),
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Volume (m³)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Text('${transaction.electricPulse} m³', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Date', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Text('${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
