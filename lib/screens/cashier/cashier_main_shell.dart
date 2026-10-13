import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'cashier_dashboard_screen.dart';
import 'pos_menu_screen.dart';
import 'cashier_orders_screen.dart';
import 'receipt_history_screen.dart';
import 'cashier_profile_screen.dart';

class CashierMainShell extends StatefulWidget {
  final int initialIndex;
  const CashierMainShell({super.key, this.initialIndex = 0});

  @override
  State<CashierMainShell> createState() => _CashierMainShellState();
}

class _CashierMainShellState extends State<CashierMainShell> {
  void _showShiftSummary() {
  final summary = _appState.generateShiftSummary();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('End-of-Shift Summary'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cashier: ${summary.cashierName}'),
              Text('Employee ID: ${summary.cashierId}'),
              Text('Date: ${summary.date.toString().split(' ').first}'),
              const Divider(),
              _summaryRow('Total Orders', '${summary.totalOrders}'),
              _summaryRow(
                'Unique Customers',
                '${summary.uniqueCustomers}',
              ),
              _summaryRow('Gross Sales', '₱${summary.grossSales.toStringAsFixed(2)}'),
              _summaryRow('Total Discounts', '₱${summary.totalDiscounts.toStringAsFixed(2)}'),
              _summaryRow('Net Sales', '₱${summary.netSales.toStringAsFixed(2)}'),
              const Divider(),
              const Text(
                'Payment Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _summaryRow('Cash', '₱${summary.cashPayments.toStringAsFixed(2)}'),
              _summaryRow('QR Pay', '₱${summary.qrPayments.toStringAsFixed(2)}'),
              _summaryRow('Card / Debit', '₱${summary.debitPayments.toStringAsFixed(2)}'),
              const Divider(),
              const Text(
                'Orders by Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...summary.ordersPerType.entries.map(
                (entry) => _summaryRow(entry.key, '${entry.value}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _summaryRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
  late int _currentIndex;
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CashierDashboardScreen(onNavigateToPos: () => _navigateToTab(1)),
      const PosMenuScreen(),
      const CashierOrdersScreen(),
      const ReceiptHistoryScreen(),
      const CashierProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              _appState.restaurantName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Cashier POS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Order Type badge in AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _appState.currentOrderType == 'Dine In'
                      ? Icons.restaurant
                      : Icons.shopping_bag_outlined,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _appState.currentOrderType == 'Dine In'
                      ? '${_appState.currentOrderType} (${_appState.currentTableNumber})'
                      : _appState.currentOrderType,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Cashier Profile Chip
          InkWell(
            onTap: () => _navigateToTab(4),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.secondary,
                    child: Text(
                      _appState.activeCashierName[0],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _appState.activeCashierName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.secondary),
              accountName: Text(
                _appState.activeCashierName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('Cashier ID: ${_appState.activeCashierId}'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.person, color: Colors.white, size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: _currentIndex == 0,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale_outlined),
              title: const Text('POS System'),
              selected: _currentIndex == 1,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Orders'),
              selected: _currentIndex == 2,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Receipt History'),
              selected: _currentIndex == 3,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profile'),
              selected: _currentIndex == 4,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(4);
              },
            ),
            const Spacer(),
            const Divider(),
           
ListTile(
  leading: const Icon(Icons.assignment_outlined),
  title: const Text('End-of-Shift Summary'),
  onTap: () {
    Navigator.of(context).pop();

    // Generate and save the shift summary.
    final summary = _appState.generateShiftSummary();
    _appState.addShiftSummary(summary);

    // Open the actual summary dialog after closing the drawer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showShiftSummary();
    });
  },
),

            const SizedBox(height: 12),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Receipt History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
