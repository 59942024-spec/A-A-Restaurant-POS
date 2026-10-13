import 'package:flutter/material.dart';
import '../models/order_receipt.dart';
import '../theme/app_theme.dart';

class VirtualReceiptDialog extends StatelessWidget {
  final OrderReceipt receipt;
  final VoidCallback onNewOrder;
  final VoidCallback onDone;

  const VirtualReceiptDialog({
    super.key,
    required this.receipt,
    required this.onNewOrder,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Success Banner
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.success,
                  radius: 16,
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDone();
                  },
                ),
              ],
            ),
            const Divider(),

            // Scrollable Thermal Receipt View
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Thermal Receipt Store Header
                      const Center(
                        child: Text(
                          'A & A RESTAURANT POS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Point-of-Sale & Management System',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow('Order ID:', receipt.orderId),
                      _buildReceiptRow(
                        'Date:',
                        '${receipt.timestamp.year}-${receipt.timestamp.month.toString().padLeft(2, '0')}-${receipt.timestamp.day.toString().padLeft(2, '0')} ${receipt.timestamp.hour.toString().padLeft(2, '0')}:${receipt.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      _buildReceiptRow('Cashier:', '${receipt.cashierName} (${receipt.cashierId})'),
                      _buildReceiptRow(
                        'Order Type:',
                        receipt.orderType == 'Dine In'
                            ? '${receipt.orderType} (${receipt.tableNumber})'
                            : receipt.orderType,
                      ),
                      const Divider(thickness: 1, color: Colors.black45),

                      // Item Column Titles
                      const Row(
                        children: [
                          Expanded(flex: 4, child: Text('Item', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      const Divider(thickness: 1, color: Colors.black26),

                      // Items List
                      ...receipt.items.map((cartItem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      '${cartItem.item.name} (${cartItem.selectedSize})',
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${cartItem.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₱${cartItem.unitPrice.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₱${cartItem.totalPrice.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              if (cartItem.specialNotes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, top: 2),
                                  child: Text(
                                    '  * Note: ${cartItem.specialNotes}',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontStyle: FontStyle.italic,
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const Divider(thickness: 1, color: Colors.black45),

                      // Totals & Discounts
                      _buildReceiptRow('Subtotal', '₱${receipt.subtotal.toStringAsFixed(2)}'),
                      if (receipt.hasDiscount) ...[
                        _buildReceiptRow(
                          'Discount (${receipt.discountReason} ${receipt.discountPercent.toInt()}%)',
                          '-₱${receipt.discountAmount.toStringAsFixed(2)}',
                          isDanger: true,
                        ),
                        if (receipt.customerName.isNotEmpty)
                          _buildReceiptRow('Customer:', '${receipt.customerName} (${receipt.discountIdNumber})', isSmall: true),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₱${receipt.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, color: Colors.black45),

                      // Payment Breakdown
                      _buildReceiptRow('Payment Method', receipt.paymentMethod.toUpperCase()),
                      _buildReceiptRow('Amount Received', '₱${receipt.amountPaid.toStringAsFixed(2)}'),
                      _buildReceiptRow('Change', '₱${receipt.changeAmount.toStringAsFixed(2)}'),

                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          '*** THANK YOU FOR DINING WITH US ***',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Please visit again!',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Actions: Print Receipt, New Order, Done
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulated printing: Thermal receipt sent to printer!'),
                          backgroundColor: AppTheme.secondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNewOrder();
                    },
                    child: const Text('New Order'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDone();
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isDanger = false, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: isSmall ? 10 : 12,
              color: isDanger ? AppTheme.danger : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: isDanger ? AppTheme.danger : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
