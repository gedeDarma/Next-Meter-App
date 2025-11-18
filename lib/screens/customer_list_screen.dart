import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../services/data_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  late List<Customer> _customers;
  late List<Customer> _filteredCustomers;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customers = DataService.getAllCustomers();
    _filteredCustomers = _customers;
    _searchController.addListener(_filterCustomers);
  }

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

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onQRScanned: (meterId) {
            _searchController.text = meterId;
            _filterCustomers();
          },
        ),
      ),
    );
  }

  void _showCustomerDetail(Customer customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 32,
                      color: Color(0xFF0066CC),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: ${customer.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                _buildDetailSection('Contact Information', [
                  ('Meter ID', customer.meterId),
                  ('Phone', customer.phone),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('Address Information', [
                  ('Address', customer.address),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('Account Information', [
                  (
                    'Registered Since',
                    '${customer.registrationDate.day}/${customer.registrationDate.month}/${customer.registrationDate.year}'
                  ),
                ]),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openCustomerForm(existing: customer);
                        },
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _deleteCustomerConfirm(customer),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<(String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0066CC),
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.$1,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$2,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCustomerForm(),
        tooltip: 'Add Customer',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or meter ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCustomers();
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _openQRScanner,
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF0066CC),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Customer>('customers').listenable(),
              builder: (context, box, _) {
                _customers = DataService.getAllCustomers();
                _filterCustomers();
                if (_filteredCustomers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No customers found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _showCustomerDetail(customer),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066CC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Meter: ${customer.meterId}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.phone,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _reloadCustomers() {
    setState(() {
      _customers = DataService.getAllCustomers();
      _filterCustomers();
    });
  }

  void _openCustomerForm({Customer? existing}) {
    final idController = TextEditingController(text: existing?.id ?? '');
    final meterController = TextEditingController(text: existing?.meterId ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                  existing == null ? 'Add Customer' : 'Edit Customer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066CC),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Customer ID',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  enabled: existing == null,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Customer ID is required';
                    if (s.contains(' ')) return 'No spaces allowed';
                    if (s.length < 4) return 'Minimum 4 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: meterController,
                  decoration: const InputDecoration(
                    labelText: 'Meter ID',
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Meter ID is required';
                    if (!RegExp(r'^\d{6,20}
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Name is required';
                    if (s.length < 3) return 'Minimum 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return null;
                    if (!RegExp(r'^\d{8,20}
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final form = formKey.currentState;
                      if (form == null || !form.validate()) return;
                      final id = idController.text.trim();
                      final meterId = meterController.text.trim();
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();
                      final phone = phoneController.text.trim();
                      try {
                        if (existing == null) {
                          if (DataService.existsById(id)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer ID already exists')),
                            );
                            return;
                          }
                          if (DataService.existsByMeterId(meterId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already exists')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: DateTime.now(),
                          );
                          await DataService.createCustomer(customer);
                        } else {
                          final conflict = DataService
                              .getAllCustomers()
                              .any((c) => c.id != existing.id && c.meterId == meterId);
                          if (conflict) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already used by another customer')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: existing.id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: existing.registrationDate,
                          );
                          await DataService.updateCustomer(customer);
                        }
                        Navigator.of(ctx).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save customer')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCustomerConfirm(Customer customer) {
    showDialog(
      context: context,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DataService.deleteCustomer(customer.id);
                Navigator.of(dCtx).pop();
                Navigator.of(context).pop();
                _reloadCustomers();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerScreen({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (!_isScanning) return;
    if (code != null && code.isNotEmpty) {
      _isScanning = false;
      widget.onQRScanned(code);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Point the camera at the QR code',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
).hasMatch(s)) {
                      return 'Meter ID must be 6-20 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Name is required';
                    if (s.length < 3) return 'Minimum 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return null;
                    if (!RegExp(r'^\d{8,20} ?').hasMatch(s)) {
                      return 'Phone must be 8-20 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final id = idController.text.trim();
                      final meterId = meterController.text.trim();
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();
                      final phone = phoneController.text.trim();
                      try {
                        if (existing == null) {
                          if (DataService.existsById(id)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer ID already exists')),
                            );
                            return;
                          }
                          if (DataService.existsByMeterId(meterId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already exists')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: DateTime.now(),
                          );
                          await DataService.createCustomer(customer);
                        } else {
                          final conflict = DataService
                              .getAllCustomers()
                              .any((c) => c.id != existing.id && c.meterId == meterId);
                          if (conflict) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already used by another customer')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: existing.id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: existing.registrationDate,
                          );
                          await DataService.updateCustomer(customer);
                        }
                        Navigator.of(ctx).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save customer')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCustomerConfirm(Customer customer) {
    showDialog(
      context: context,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DataService.deleteCustomer(customer.id);
                Navigator.of(dCtx).pop();
                Navigator.of(context).pop();
                _reloadCustomers();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerScreen({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (!_isScanning) return;
    if (code != null && code.isNotEmpty) {
      _isScanning = false;
      widget.onQRScanned(code);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Point the camera at the QR code',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
).hasMatch(s)) {
                      return 'Phone must be 8-20 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final id = idController.text.trim();
                      final meterId = meterController.text.trim();
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();
                      final phone = phoneController.text.trim();
                      try {
                        if (existing == null) {
                          if (DataService.existsById(id)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer ID already exists')),
                            );
                            return;
                          }
                          if (DataService.existsByMeterId(meterId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already exists')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: DateTime.now(),
                          );
                          await DataService.createCustomer(customer);
                        } else {
                          final conflict = DataService
                              .getAllCustomers()
                              .any((c) => c.id != existing.id && c.meterId == meterId);
                          if (conflict) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already used by another customer')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: existing.id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: existing.registrationDate,
                          );
                          await DataService.updateCustomer(customer);
                        }
                        Navigator.of(ctx).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save customer')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCustomerConfirm(Customer customer) {
    showDialog(
      context: context,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DataService.deleteCustomer(customer.id);
                Navigator.of(dCtx).pop();
                Navigator.of(context).pop();
                _reloadCustomers();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerScreen({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (!_isScanning) return;
    if (code != null && code.isNotEmpty) {
      _isScanning = false;
      widget.onQRScanned(code);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Point the camera at the QR code',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
).hasMatch(s)) {
                      return 'Meter ID must be 6-20 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Name is required';
                    if (s.length < 3) return 'Minimum 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return null;
                    if (!RegExp(r'^\d{8,20} ?').hasMatch(s)) {
                      return 'Phone must be 8-20 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final id = idController.text.trim();
                      final meterId = meterController.text.trim();
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();
                      final phone = phoneController.text.trim();
                      try {
                        if (existing == null) {
                          if (DataService.existsById(id)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer ID already exists')),
                            );
                            return;
                          }
                          if (DataService.existsByMeterId(meterId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already exists')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: DateTime.now(),
                          );
                          await DataService.createCustomer(customer);
                        } else {
                          final conflict = DataService
                              .getAllCustomers()
                              .any((c) => c.id != existing.id && c.meterId == meterId);
                          if (conflict) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meter ID already used by another customer')),
                            );
                            return;
                          }
                          final customer = Customer(
                            id: existing.id,
                            meterId: meterId,
                            name: name,
                            address: address,
                            phone: phone,
                            registrationDate: existing.registrationDate,
                          );
                          await DataService.updateCustomer(customer);
                        }
                        Navigator.of(ctx).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save customer')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCustomerConfirm(Customer customer) {
    showDialog(
      context: context,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DataService.deleteCustomer(customer.id);
                Navigator.of(dCtx).pop();
                Navigator.of(context).pop();
                _reloadCustomers();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerScreen({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (!_isScanning) return;
    if (code != null && code.isNotEmpty) {
      _isScanning = false;
      widget.onQRScanned(code);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Point the camera at the QR code',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
