import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'owner_dashboard_screen.dart';
import 'menu_management_screen.dart';
import 'owner_orders_screen.dart';
import 'employees_screen.dart';
import '../cashier/receipt_history_screen.dart';
import 'owner_settings_screen.dart';

class OwnerMainShell extends StatefulWidget {
  const OwnerMainShell({super.key});

  @override
  State<OwnerMainShell> createState() => _OwnerMainShellState();
}

class _OwnerMainShellState extends State<OwnerMainShell> {
  int _currentIndex = 0;
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
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
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      OwnerDashboardScreen(onNavigateToMenu: () => _navigateToTab(1)),
      const MenuManagementScreen(),
      const OwnerOrdersScreen(),
      const EmployeesScreen(),
      const ReceiptHistoryScreen(),
      const OwnerSettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.storefront, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              _appState.restaurantName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Admin Portal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _appState.isDarkMode ? 'Light Mode' : 'Dark Mode',
            icon: Icon(_appState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => _appState.toggleTheme(),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.secondary,
                  child: Text(
                    _appState.activeOwnerName[0],
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  _appState.activeOwnerName,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.secondary),
              accountName: const Text(
                'Owner / Administrator',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                  'Username: ${_appState.ownerAccount?.username ?? 'enchang'}'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
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
              leading: const Icon(Icons.restaurant_menu_outlined),
              title: const Text('Menu Management'),
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
              leading: const Icon(Icons.people_outline),
              title: const Text('Employees'),
              selected: _currentIndex == 3,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Receipt History'),
              selected: _currentIndex == 4,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              selected: _currentIndex == 5,
              selectedColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTab(5);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.danger),
              title: const Text('Sign Out', style: TextStyle(color: AppTheme.danger)),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                Navigator.of(context).pop(); // Return to Access Screen
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
    );
  }
}
