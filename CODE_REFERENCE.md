# Code Reference - Key Implementations
Last updated: 2025-12-10

## Core Calculation Logic

### Electric Pulse Calculation Service

```dart
// From: lib/services/transaction_service.dart

static int calculateElectricPulse(double amountInRupiah) {
  return (amountInRupiah / 10000).toInt() * 10;
}

// Example:
// Rp 50,000 → (50000 / 10000) * 10 = 50 Pulse
// Rp 75,000 → (75000 / 10000) * 10 = 75 Pulse
// Rp 100,000 → (100000 / 10000) * 10 = 100 Pulse
```

### Token Generation

```dart
// From: lib/services/transaction_service.dart

static String generateToken() {
  final random = Random();
  final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  String token = '';
  for (int i = 0; i < 20; i++) {
    token += chars[random.nextInt(chars.length)];
  }
  // Format: XXXX-XXXX-XXXX-XXXX-XXXX
  return '${token.substring(0, 4)}-${token.substring(4, 8)}-'
         '${token.substring(8, 12)}-${token.substring(12, 16)}-'
         '${token.substring(16, 20)}';
}
```

### Rupiah Formatting

```dart
// From: lib/services/transaction_service.dart

static String formatRupiah(double amount) {
  final formatter = amount.toStringAsFixed(0);
  final parts = <String>[];
  for (int i = formatter.length - 1; i >= 0; i -= 3) {
    final start = i - 2 < 0 ? 0 : i - 2;
    parts.insert(0, formatter.substring(start, i + 1));
    i -= 2;
    if (i < 0) break;
  }
  return 'Rp ${parts.join('.')}';
}

// Example:
// 50000 → "Rp 50.000"
// 100000 → "Rp 100.000"
// 1500000 → "Rp 1.500.000"
```

## Data Models

### Customer Model

```dart
// From: lib/models/customer.dart

class Customer {
  final String id;
  final String meterId;
  final String name;
  final String address;
  final String phone;
  final DateTime registrationDate;

  Customer({
    required this.id,
    required this.meterId,
    required this.name,
    required this.address,
    required this.phone,
    required this.registrationDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      meterId: json['meterId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meterId': meterId,
      'name': name,
      'address': address,
      'phone': phone,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }
}
```

### Transaction Model

```dart
// From: lib/models/transaction.dart

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
}
```

## Database/Service

### Customer Search Service

```dart
// From: lib/services/data_service.dart

static Customer? searchCustomerByMeterId(String meterId) {
  try {
    return mockCustomers.firstWhere(
      (customer) => customer.meterId == meterId,
    );
  } catch (e) {
    return null;
  }
}

// Usage
final customer = DataService.searchCustomerByMeterId('1234567890');
if (customer != null) {
  print('Found: ${customer.name}');
} else {
  print('Customer not found');
}
```

## UI Patterns

### Real-time Calculation in Form

```dart
// From: lib/screens/transaction_form_screen.dart

@override
void initState() {
  super.initState();
  _amountController.addListener(_onAmountChanged);
}

void _onAmountChanged() {
  final amount = double.tryParse(_amountController.text) ?? 0.0;
  setState(() {
    _electricPulse = TransactionService.calculateElectricPulse(amount);
  });
}

// In build:
TextField(
  controller: _amountController,
  keyboardType: TextInputType.number,
  // ... other properties
)
```

### Navigation with Data Passing

```dart
// From: lib/screens/transaction_screen.dart

// Navigate to form screen with customer data
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TransactionFormScreen(
      customer: _selectedCustomer!,
    ),
  ),
);

// In TransactionFormScreen
final Customer customer;
const TransactionFormScreen({
  Key? key,
  required this.customer,
}) : super(key: key);
```

### Search with Validation

```dart
// From: lib/screens/transaction_screen.dart

void _searchCustomer() {
  final meterId = _meterIdController.text.trim();
  
  if (meterId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter meter ID')),
    );
    return;
  }

  setState(() => _isSearching = true);

  Future.delayed(const Duration(milliseconds: 500), () {
    final customer = DataService.searchCustomerByMeterId(meterId);
    setState(() => _isSearching = false);

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer not found')),
      );
    }
  });
}
```

### List with Search Filter

```dart
// From: lib/screens/customer_list_screen.dart

void _filterCustomers() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    _filteredCustomers = _customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
             customer.meterId.contains(query) ||
             customer.id.contains(query);
    }).toList();
  });
}
```

### Dialog with Details

```dart
// From: lib/screens/transaction_history_screen.dart

void _showTransactionDetail(Transaction transaction) {
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
              // ... more fields
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
```

## Material Design 3 Theming

### App Theme Configuration

```dart
// From: lib/main.dart

MaterialApp(
  title: 'Next Meter - Water Token',
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0066CC),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF0066CC),
      foregroundColor: Colors.white,
    ),
  ),
  home: const IntroScreen(),
)
```

## Bottom Navigation Implementation

```dart
// From: lib/screens/home_screen.dart

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeMainScreen(),
    const TransactionHistoryScreen(),
    const CustomerListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next Meter')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
        ],
      ),
    );
  }
}
```

## Useful Patterns

### Loading State Management

```dart
bool _isLoading = false;

void _executeAsync() {
  setState(() => _isLoading = true);

  Future.delayed(const Duration(milliseconds: 500), () {
    // Perform operation
    setState(() => _isLoading = false);
  });
}

// In UI
_isLoading 
  ? const CircularProgressIndicator()
  : const Text('Load')
```

### Input Validation

```dart
bool _validateAmount(String value) {
  final amount = double.tryParse(value);
  return amount != null && amount > 0;
}

if (!_validateAmount(_amountController.text)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid amount')),
  );
  return;
}
```

### Formatting and Cleanup

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## Common Patterns Used in This App

1. **StatefulWidget** - For screens with changing state
2. **Navigation** - Using Navigator.push() and pushReplacementNamed()
3. **Data Passing** - Through constructor parameters
4. **Async Operations** - Using Future.delayed() for simulation
5. **State Management** - Using setState() for local state
6. **Search/Filter** - Using List.where() and addListener()
7. **Dialogs** - Using showDialog() and showModalBottomSheet()
8. **Validation** - Input checking and error messages via SnackBar

---

**For more Flutter patterns and best practices, visit:**
- https://flutter.dev/docs/development/ui/widgets-intro
- https://flutter.dev/docs/development/data-and-backend
- https://dart.dev/guides
