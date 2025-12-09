import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as tx_model;

class DataService {
  static Box<Customer> _customersBox() => Hive.box<Customer>('customers');
  static Box<tx_model.Transaction> _transactionsBox() => Hive.box<tx_model.Transaction>('transactions');

  static Future<void> seedMockCustomersIfEmpty() async {
    // Mock customers are disabled - no seeding needed
    // Users can add customers manually through the app
  }

  static void addRecentTransaction(tx_model.Transaction transaction) {
    _transactionsBox().put(transaction.id, transaction);
  }

  static List<tx_model.Transaction> getRecentTransactions() {
    final list = _transactionsBox().values.toList();
    list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return list.take(10).toList();
  }

  static List<tx_model.Transaction> getAllTransactions() {
    final list = _transactionsBox().values.toList();
    list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return list;
  }

  static Customer? searchCustomerByMeterId(String meterId) {
    try {
      return _customersBox().values.firstWhere((customer) => customer.meterId == meterId);
    } catch (_) {
      return null;
    }
  }

  static Customer? searchCustomerById(String id) {
    return _customersBox().get(id);
  }

  static List<Customer> getAllCustomers() {
    return _customersBox().values.toList();
  }

  static Future<void> createCustomer(Customer customer) async {
    await _customersBox().put(customer.id, customer);
  }

  static Future<void> updateCustomer(Customer customer) async {
    await _customersBox().put(customer.id, customer);
  }

  static Future<bool> deleteCustomer(String id) async {
    if (!_customersBox().containsKey(id)) return false;
    await _customersBox().delete(id);
    return true;
  }

  static Future<void> clearCustomers() async {
    await _customersBox().clear();
  }

  static bool existsById(String id) {
    return _customersBox().containsKey(id);
  }

  static bool existsByMeterId(String meterId) {
    return _customersBox().values.any((c) => c.meterId == meterId);
  }

  static int getTransactionCountByMeterId(String meterId) {
    return _transactionsBox()
        .values
        .where((t) => t.customer.meterId == meterId)
        .length;
  }

  // static Future<void> clearTransactions() async {
  //   await _transactionsBox().clear();
  // }
}
