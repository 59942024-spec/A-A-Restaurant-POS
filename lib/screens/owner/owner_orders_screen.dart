import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/order_receipt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/virtual_receipt_dialog.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final AppState _appState = AppState();
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Completed', 'Pending', 'Cancelled'];

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

  List<OrderReceipt> get _filteredOrders {
    if (_selectedFilter == 'All') return _appState.orders;
    if (_selectedFilter == 'Completed') {
      return _appState.orders.where((o) => o.status == 'Completed' || o.status == 'Paid').toList();
    }
    return _appState.orders.where((o) => o.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant Orders Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
            const SizedBox(height: 12),

            // Filter Chips
            Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Orders Table / List
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Text('No $_selectedFilter orders found.',
                          style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    )
                  : ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.orderId,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${order.orderType} (${order.tableNumber})',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.items.map((i) => '${i.quantity}x ${i.item.name} (${i.selectedSize})').join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cashier: ${order.cashierName} • Payment: ${order.paymentMethod}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₱${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: order.status == 'Pending' ? AppTheme.warning : AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.receipt_long),
                                  tooltip: 'View Receipt',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => VirtualReceiptDialog(
                                        receipt: order,
                                        onNewOrder: () {},
                                        onDone: () {},
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
