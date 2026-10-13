import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/order_receipt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/virtual_receipt_dialog.dart';

class CashierOrdersScreen extends StatefulWidget {
  const CashierOrdersScreen({super.key});

  @override
  State<CashierOrdersScreen> createState() => _CashierOrdersScreenState();
}

class _CashierOrdersScreenState extends State<CashierOrdersScreen> {
  final AppState _appState = AppState();
  String _selectedStatus = 'All';

  final List<String> _statusFilters = ['All', 'Completed', 'Pending', 'Cancelled'];

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
    if (_selectedStatus == 'All') return _appState.orders;
    if (_selectedStatus == 'Completed') {
      return _appState.orders.where((o) => o.status == 'Completed' || o.status == 'Paid').toList();
    }
    return _appState.orders.where((o) => o.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders Tracking',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
            const SizedBox(height: 12),

            // Filter Tabs
            Row(
              children: _statusFilters.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatus = status);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Orders List
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        'No $_selectedStatus orders found.',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isPending = order.status == 'Pending';

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Order ID & Type
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.orderId,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.orderType == 'Dine In'
                                          ? '${order.orderType} (${order.tableNumber})'
                                          : order.orderType,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),

                                // Items summary
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.items.map((i) => '${i.quantity}x ${i.item.name}').join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Payment: ${order.paymentMethod} • Cashier: ${order.cashierName}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),

                                // Price & Status Badge
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
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isPending ? Colors.orange.shade50 : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isPending ? Colors.orange.shade300 : Colors.green.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPending ? AppTheme.warning : AppTheme.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),

                                // Action Buttons
                                if (isPending)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    onPressed: () {
                                      _appState.updateOrderStatus(order.orderId, 'Completed');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Order ${order.orderId} marked as completed!')),
                                      );
                                    },
                                    child: const Text('Complete', style: TextStyle(fontSize: 12)),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.receipt_outlined),
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
