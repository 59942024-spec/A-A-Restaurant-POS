import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CashierProfileScreen extends StatefulWidget {
  const CashierProfileScreen({super.key});

  @override
  State<CashierProfileScreen> createState() => _CashierProfileScreenState();
}

class _CashierProfileScreenState extends State<CashierProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    final session = _appState.activeSession;
    final cashierName = _appState.activeCashierName;
    final cashierId = _appState.activeCashierId;
    final cashierOrders =
        _appState.orders.where((o) => o.cashierId == cashierId).toList();
    final cashierSales =
        cashierOrders.fold(0.0, (sum, o) => sum + (o.status != 'Cancelled' ? o.totalAmount : 0.0));

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        cashierName.isNotEmpty ? cashierName[0] : 'C',
                        style: const TextStyle(
                            fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      cashierName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cashier Operator • ID: $cashierId',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),

                    // Profile & Shift Details
                    _buildInfoTile('Username', session?.username ?? 'juan_cashier'),
                    _buildInfoTile('Assigned Shift', _appState.activeShift),
                    _buildInfoTile('Manager for Today', _appState.activeManager),
                    _buildInfoTile(
                      'Shift Login Time',
                      session != null
                          ? '${session.loginTime.hour.toString().padLeft(2, '0')}:${session.loginTime.minute.toString().padLeft(2, '0')} (Today)'
                          : 'Active',
                    ),
                    _buildInfoTile('Station / Terminal', 'Tablet POS Terminal 1'),
                    const Divider(height: 20),
                    _buildInfoTile('Orders Processed', '${cashierOrders.length} Orders'),
                    _buildInfoTile('Total Sales Logged', '₱${cashierSales.toStringAsFixed(2)}'),
                    const SizedBox(height: 24),

                    // End Shift Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.danger,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'End Shift & Switch Cashier',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('End Cashier Shift?'),
                              content: Text(
                                'Are you sure you want to end shift for $cashierName? This will close the cashier session.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(); // Close dialog
                                    _appState.logoutCashier();
                                    Navigator.of(context).pop(); // Return to Access Screen
                                  },
                                  child: const Text('End Shift'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
