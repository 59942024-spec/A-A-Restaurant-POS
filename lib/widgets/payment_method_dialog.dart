import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentResult {
  final String paymentMethod;
  final double amountPaid;
  final double changeAmount;

  PaymentResult({
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
  });
}

class PaymentMethodDialog extends StatefulWidget {
  final double totalAmount;

  const PaymentMethodDialog({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Cash state
  final TextEditingController _cashReceivedController = TextEditingController();
  double _cashReceived = 0.0;

  // Card state
  bool _isCardProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Pre-fill cash with total or rounded amount
    _cashReceived = widget.totalAmount >= 500 ? (widget.totalAmount + 50) : 500.0;
    if (_cashReceived < widget.totalAmount) {
      _cashReceived = widget.totalAmount;
    }
    _cashReceivedController.text = _cashReceived.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  double get _cashChange {
    final diff = _cashReceived - widget.totalAmount;
    return diff > 0 ? diff : 0.0;
  }

  bool get _isCashValid => _cashReceived >= widget.totalAmount;

  void _confirmCashPayment() {
    if (!_isCashValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment amount is insufficient! Enter at least ₱${widget.totalAmount.toStringAsFixed(2)}',
          ),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    Navigator.of(context).pop(PaymentResult(
      paymentMethod: 'Cash',
      amountPaid: _cashReceived,
      changeAmount: _cashChange,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Bar: Cash, Card, QR Pay
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                tabs: const [
                  Tab(icon: Icon(Icons.payments_outlined), text: 'Cash'),
                  Tab(icon: Icon(Icons.credit_card_outlined), text: 'Card'),
                  Tab(icon: Icon(Icons.qr_code_2_outlined), text: 'QR Pay'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab Views
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCashView(),
                  _buildCardView(),
                  _buildQrView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. CASH VIEW ---
  Widget _buildCashView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Amount Due', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(
              '₱${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Amount Received from Customer',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: _cashReceivedController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '₱ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (val) {
            setState(() {
              _cashReceived = double.tryParse(val) ?? 0.0;
            });
          },
        ),
        const SizedBox(height: 8),

        // Quick Preset Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip('Exact (₱${widget.totalAmount.toInt()})', widget.totalAmount),
              _buildPresetChip('₱500', 500.0),
              _buildPresetChip('₱1,000', 1000.0),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Change Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isCashValid ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isCashValid ? Colors.green.shade300 : Colors.red.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isCashValid ? 'Change Due' : 'Insufficient Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isCashValid ? AppTheme.success : AppTheme.danger,
                ),
              ),
              Text(
                '₱${_cashChange.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isCashValid ? AppTheme.success : AppTheme.danger,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Bottom Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isCashValid ? _confirmCashPayment : null,
                child: const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, double val) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () {
          setState(() {
            _cashReceived = val;
            _cashReceivedController.text = val.toStringAsFixed(0);
          });
        },
      ),
    );
  }

  // --- 2. CARD VIEW ---
  Widget _buildCardView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.point_of_sale_rounded, size: 64, color: Colors.blue.shade700),
        const SizedBox(height: 12),
        const Text(
          'Please tap, insert, or swipe the customer\'s card on the terminal.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'Total to Charge: ₱${widget.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        const SizedBox(height: 20),
        if (_isCardProcessing) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          const Text('Connecting to POS terminal...'),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Simulate Approval'),
                  onPressed: () {
                    setState(() => _isCardProcessing = true);
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (mounted) {
                        Navigator.of(context).pop(PaymentResult(
                          paymentMethod: 'Card',
                          amountPaid: widget.totalAmount,
                          changeAmount: 0.0,
                        ));
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // --- 3. QR VIEW ---
  Widget _buildQrView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Simulated QR pattern
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner_rounded, size: 70, color: Colors.black87),
                Text(
                  '₱${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scan this QR code using GCash / Maya',
          style: TextStyle(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment simulated failed or rejected. Please retry or choose another method.'),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                },
                child: const Text('Simulate Failed'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                onPressed: () {
                  Navigator.of(context).pop(PaymentResult(
                    paymentMethod: 'QR Pay',
                    amountPaid: widget.totalAmount,
                    changeAmount: 0.0,
                  ));
                },
                child: const Text('Simulate Success'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel Payment', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
