import 'package:flutter/material.dart';
import '../main.dart';
import 'transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'customer_manager_screen.dart';
import '../services/data_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart' as tx_model;
import '../models/customer.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeMainScreen(),
      const TransactionHistoryScreen(),
      const CustomerManagerScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Meter'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ThemeProviderInherited.of(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ThemeProviderInherited.of(context).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        ],
      ),
    );
  }
}

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Welcome to Next Meter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066CC),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your water token transactions',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                ValueListenableBuilder<Box<tx_model.Transaction>>(
                  valueListenable: Hive.box<tx_model.Transaction>('transactions').listenable(),
                  builder: (context, box, _) {
                    final all = DataService.getAllTransactions();
                    final now = DateTime.now();
                    final thisMonth = all.where((t) => t.transactionDate.year == now.year && t.transactionDate.month == now.month).toList();
                    final count = thisMonth.length;
                    final total = thisMonth.fold<double>(0, (sum, t) => sum + t.amount);
                    return SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066CC).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.receipt_long, color: Color(0xFF0066CC)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Transactions (This Month)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066CC))),
                                    const SizedBox(height: 6),
                                    Text(
                                      TransactionService.formatRupiah(total),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Count: $count', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<Box<Customer>>(
                  valueListenable: Hive.box<Customer>('customers').listenable(),
                  builder: (context, box, _) {
                    final count = DataService.getAllCustomers().length;
                    return SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.people, color: Color(0xFFFF9800)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Customers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066CC))),
                                    const SizedBox(height: 6),
                                    Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('Active records', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Transaction',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Create a new water token transaction',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionHistoryScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00AA66), Color(0xFF008844)],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Icon(Icons.history, size: 40, color: Colors.white),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'View all past transactions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomerManagerScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF9800), Color(0xFFE68900)],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Icon(Icons.people, size: 40, color: Colors.white),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Manage customer information',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 0),
            const SizedBox(height: 30),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildRecentTransactions(),
            // const SizedBox(height: 30),
            // const Text(
            //   'System Information',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 15),
            // Container(
            //   padding: const EdgeInsets.all(15),
            //   decoration: BoxDecoration(
            //     color: Colors.blue.shade50,
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: Colors.blue.shade200),
            //   ),
            //   child: const Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Calculation Formula',
            //         style: TextStyle(
            //           fontSize: 14,
            //           fontWeight: FontWeight.bold,
            //           color: Color(0xFF0066CC),
            //         ),
            //       ),
            //       SizedBox(height: 10),
            //       Text(
            //         'Rp 10,000 = 30 Water Pulse',
            //         style: TextStyle(fontSize: 13),
            //       ),
            //       SizedBox(height: 5),
            //       Text(
            //         'Example: Rp 50,000 = 150 Water Pulse',
            //         style: TextStyle(fontSize: 13, color: Colors.grey),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return ValueListenableBuilder<Box<tx_model.Transaction>>(
      valueListenable: Hive.box<tx_model.Transaction>('transactions').listenable(),
      builder: (context, box, _) {
        final List<tx_model.Transaction> recent = DataService.getRecentTransactions().take(5).toList();
        if (recent.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Center(child: Text('No recent transactions')),
          );
        }
        return Column(
          children: List.generate(recent.length, (index) {
            final trx = recent[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0066CC).withOpacity(0.18),
                              Color(0xFF0066CC).withOpacity(0.32),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.water_drop,
                            color: Color(0xFF0066CC),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              trx.customer.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${TransactionService.formatRupiah(trx.amount)} • ${trx.electricPulse} Pulse',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              TransactionService.formatDateTime(
                                trx.transactionDate,
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        trx.status == tx_model.TransactionStatus.completed
                            ? 'Completed'
                            : trx.status.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0066CC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
