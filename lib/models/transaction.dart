import 'customer.dart';

enum TransactionStatus { pending, confirmed, completed }

class Transaction {
  final String id;
  final Customer customer;
  final double amount;
  final int electricPulse;
  final DateTime transactionDate;
  final TransactionStatus status;
  final String? token;
  final String? receipt;

  Transaction({
    required this.id,
    required this.customer,
    required this.amount,
    required this.electricPulse,
    required this.transactionDate,
    required this.status,
    this.token,
    this.receipt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      customer: Customer.fromJson(json['customer'] ?? {}),
      amount: (json['amount'] ?? 0.0).toDouble(),
      electricPulse: json['electricPulse'] ?? 0,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : DateTime.now(),
      status: TransactionStatus.values[json['status'] ?? 0],
      token: json['token'],
      receipt: json['receipt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer.toJson(),
      'amount': amount,
      'electricPulse': electricPulse,
      'transactionDate': transactionDate.toIso8601String(),
      'status': status.index,
      'token': token,
      'receipt': receipt,
    };
  }
}
