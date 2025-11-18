import 'package:hive/hive.dart';
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

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 2;

  @override
  Transaction read(BinaryReader reader) {
    final id = reader.read() as String;
    final customer = reader.read() as Customer;
    final amount = (reader.read() as num).toDouble();
    final electricPulse = reader.read() as int;
    final millis = reader.read() as int;
    final statusIndex = reader.read() as int;
    final token = reader.read() as String?;
    final receipt = reader.read() as String?;
    return Transaction(
      id: id,
      customer: customer,
      amount: amount,
      electricPulse: electricPulse,
      transactionDate: DateTime.fromMillisecondsSinceEpoch(millis),
      status: TransactionStatus.values[statusIndex],
      token: token,
      receipt: receipt,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.id);
    writer.write(obj.customer);
    writer.write(obj.amount);
    writer.write(obj.electricPulse);
    writer.write(obj.transactionDate.millisecondsSinceEpoch);
    writer.write(obj.status.index);
    writer.write(obj.token);
    writer.write(obj.receipt);
  }
}
