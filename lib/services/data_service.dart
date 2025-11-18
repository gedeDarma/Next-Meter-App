import '../models/customer.dart';
import '../models/transaction.dart' as tx_model;

class DataService {
  static final List<Customer> mockCustomers = [
    Customer(
      id: 'CUST001',
      meterId: '1234567890',
      name: 'Budi Santoso',
      address: 'Jl. Merdeka No. 10, Jakarta',
      phone: '081234567890',
      registrationDate: DateTime(2023, 1, 15),
    ),
    Customer(
      id: 'CUST002',
      meterId: '1234567891',
      name: 'Siti Nurhaliza',
      address: 'Jl. Sudirman No. 25, Bandung',
      phone: '082345678901',
      registrationDate: DateTime(2023, 2, 20),
    ),
    Customer(
      id: 'CUST003',
      meterId: '1234567892',
      name: 'Ahmad Wijaya',
      address: 'Jl. Ahmad Yani No. 30, Surabaya',
      phone: '083456789012',
      registrationDate: DateTime(2023, 3, 10),
    ),
    Customer(
      id: 'CUST004',
      meterId: '1234567893',
      name: 'Rina Dewi',
      address: 'Jl. Gatot Subroto No. 15, Medan',
      phone: '084567890123',
      registrationDate: DateTime(2023, 4, 5),
    ),
    Customer(
      id: 'CUST005',
      meterId: '1234567894',
      name: 'Hendra Kusuma',
      address: 'Jl. Diponegoro No. 40, Yogyakarta',
      phone: '085678901234',
      registrationDate: DateTime(2023, 5, 12),
    ),
  ];

  // Store for completed transactions (recent activity)
  static final List<tx_model.Transaction> _recentTransactions = [];

  // Add a transaction to recent activity
  static void addRecentTransaction(tx_model.Transaction transaction) {
    _recentTransactions.insert(0, transaction);
    // Keep only the last 10 transactions
    if (_recentTransactions.length > 10) {
      _recentTransactions.removeAt(_recentTransactions.length - 1);
    }
  }

  // Get recent transactions
  static List<tx_model.Transaction> getRecentTransactions() {
    return _recentTransactions;
  }

  // Search customer by meter ID
  static Customer? searchCustomerByMeterId(String meterId) {
    try {
      return mockCustomers.firstWhere(
        (customer) => customer.meterId == meterId,
      );
    } catch (e) {
      return null;
    }
  }

  // Search customer by ID
  static Customer? searchCustomerById(String id) {
    try {
      return mockCustomers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all customers
  static List<Customer> getAllCustomers() {
    return mockCustomers;
  }
}
