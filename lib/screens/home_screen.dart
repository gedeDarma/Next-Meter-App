import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/logo.png'), context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  

  Widget _buildDockItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.water_drop,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NexMeter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text('Water Token Management', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                ThemeProviderInherited.of(context).isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                ThemeProviderInherited.of(context).toggleTheme();
              },
              tooltip: 'Toggle Theme',
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: _screens[_selectedIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TransactionScreen()),
            );
          },
          elevation: 4,
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 8,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _buildDockItem(Icons.home, 'Home', 0),
                  const SizedBox(width: 12),
                  _buildDockItem(Icons.history, 'History', 1),
                ]),
                Row(children: [
                  _buildDockItem(Icons.people, 'Customers', 2),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings, color: Colors.grey),
                          SizedBox(height: 2),
                          Text('Setting', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ValueListenableBuilder<Box<tx_model.Transaction>>(
                  valueListenable: Hive.box<tx_model.Transaction>('transactions').listenable(),
                  builder: (context, txBox, _) {
                    final all = DataService.getAllTransactions();
                    final now = DateTime.now();
                    final thisMonth = all.where((t) => t.transactionDate.year == now.year && t.transactionDate.month == now.month).toList();
                    final txCount = thisMonth.length;
                    final txTotal = thisMonth.fold<double>(0, (sum, t) => sum + t.amount);
                    return ValueListenableBuilder<Box<Customer>>(
                      valueListenable: Hive.box<Customer>('customers').listenable(),
                      builder: (context, custBox, __) {
                        final customersCount = DataService.getAllCustomers().length;
                        return SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E40AF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'This Month',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                TransactionService.formatRupiah(txTotal),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.receipt, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Text('$txCount Transactions', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors.white.withValues(alpha: 0.3),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.people_outline, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Text('$customersCount Customers', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 0),
              ],
            ),
            //const SizedBox(height: 30),
            // const Text(
            //   'Quick Actions',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            //const SizedBox(height: 15),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const TransactionScreen(),
            //       ),
            //     );
            //   },
            //   child: Card(
            //     elevation: 3,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         gradient: const LinearGradient(
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //           colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
            //         ),
            //       ),
            //       padding: const EdgeInsets.all(20),
            //       child: const Row(
            //         children: [
            //           Icon(
            //             Icons.add_circle_outline,
            //             size: 40,
            //             color: Colors.white,
            //           ),
            //           SizedBox(width: 20),
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   'New Transaction',
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //                 SizedBox(height: 5),
            //                 Text(
            //                   'Create a new water token transaction',
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.white70,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           Icon(Icons.arrow_forward, color: Colors.white),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 15),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const TransactionHistoryScreen(),
            //       ),
            //     );
            //   },
            //   child: Card(
            //     elevation: 3,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         gradient: const LinearGradient(
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //           colors: [Color(0xFF00AA66), Color(0xFF008844)],
            //         ),
            //       ),
            //       padding: const EdgeInsets.all(20),
            //       child: const Row(
            //         children: [
            //           Icon(Icons.history, size: 40, color: Colors.white),
            //           SizedBox(width: 20),
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   'Transaction History',
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //                 SizedBox(height: 5),
            //                 Text(
            //                   'View all past transactions',
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.white70,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           Icon(Icons.arrow_forward, color: Colors.white),
            //         ],
            //       ),
            //     ),
            //   ),
            //),
            const SizedBox(height: 15),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const CustomerManagerScreen(),
            //       ),
            //     );
            //   },
            //   child: Card(
            //     elevation: 3,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         gradient: const LinearGradient(
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //           colors: [Color(0xFFFF9800), Color(0xFFE68900)],
            //         ),
            //       ),
            //       padding: const EdgeInsets.all(20),
            //       child: const Row(
            //         children: [
            //           Icon(Icons.people, size: 40, color: Colors.white),
            //           SizedBox(width: 20),
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   'Customers',
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //                 SizedBox(height: 5),
            //                 Text(
            //                   'Manage customer information',
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.white70,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           Icon(Icons.arrow_forward, color: Colors.white),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            //const SizedBox(height: 0),
            //const SizedBox(height: 30),
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
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.water_drop_rounded, color: Color(0xFF1E40AF), size: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trx.customer.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              TransactionService.formatDateTime(trx.transactionDate),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            TransactionService.formatRupiah(trx.amount),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${trx.electricPulse} m³',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
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
