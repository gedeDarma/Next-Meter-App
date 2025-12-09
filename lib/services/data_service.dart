import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as tx_model;

class DataService {
  static Box<Customer> _customersBox() => Hive.box<Customer>('customers');
  static Box<tx_model.Transaction> _transactionsBox() => Hive.box<tx_model.Transaction>('transactions');
  // static final List<Customer> mockCustomers = [
  //   Customer(
  //     id: 'CUST001',
  //     meterId: '01014480',
  //     name: 'Budi Santoso',
  //     address: 'Jl. Merdeka No. 10, Jakarta',
  //     phone: '081234567890',
  //     registrationDate: DateTime(2023, 1, 15),
  //   ),
  //   Customer(
  //     id: 'CUST002',
  //     meterId: '1234567891',
  //     name: 'Siti Nurhaliza',
  //     address: 'Jl. Sudirman No. 25, Bandung',
  //     phone: '082345678901',
  //     registrationDate: DateTime(2023, 2, 20),
  //   ),
  //   Customer(
  //     id: 'CUST003',
  //     meterId: '1234567892',
  //     name: 'Ahmad Wijaya',
  //     address: 'Jl. Ahmad Yani No. 30, Surabaya',
  //     phone: '083456789012',
  //     registrationDate: DateTime(2023, 3, 10),
  //   ),
  //   Customer(
  //     id: 'CUST004',
  //     meterId: '1234567893',
  //     name: 'Rina Dewi',
  //     address: 'Jl. Gatot Subroto No. 15, Medan',
  //     phone: '084567890123',
  //     registrationDate: DateTime(2023, 4, 5),
  //   ),
  //   Customer(
  //     id: 'CUST005',
  //     meterId: '1234567894',
  //     name: 'Hendra Kusuma',
  //     address: 'Jl. Diponegoro No. 40, Yogyakarta',
  //     phone: '085678901234',
  //     registrationDate: DateTime(2023, 5, 12),
  //   ),
  // ];

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
