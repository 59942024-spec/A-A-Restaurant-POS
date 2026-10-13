import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CheckoutResult {
  final bool hasDiscount;
  final String reason;
  final String idType;
  final String idNumber;
  final String customerName;
  final String notes;
  final double discountPercent;
  final double discountAmount;
  final double grandTotal;

  CheckoutResult({
    required this.hasDiscount,
    required this.reason,
    required this.idType,
    required this.idNumber,
    required this.customerName,
    required this.notes,
    required this.discountPercent,
    required this.discountAmount,
    required this.grandTotal,
  });
}

class CheckoutDiscountDialog extends StatefulWidget {
  final double subtotal;

  const CheckoutDiscountDialog({
    super.key,
    required this.subtotal,
  });

  @override
  State<CheckoutDiscountDialog> createState() => _CheckoutDiscountDialogState();
}

class _CheckoutDiscountDialogState extends State<CheckoutDiscountDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _applyDiscount = false;
  String _discountReason = 'Senior Citizen';
  double _discountPercent = 20.0;

 final TextEditingController _customerNameController =
    TextEditingController();
final TextEditingController _idTypeController =
    TextEditingController();
final TextEditingController _idNumberController =
    TextEditingController();
final TextEditingController _notesController =
    TextEditingController();
  final Map<String, double> _reasonPercentages = {
    'Senior Citizen': 20.0,
    'PWD': 20.0,
    'Solo Parent': 10.0,
    'Employee': 15.0,
    'Promotional Discount': 10.0,
  };

  @override
  void dispose() {
    _customerNameController.dispose();
    _idTypeController.dispose();
    _idNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _discountAmount {
    if (!_applyDiscount) return 0.0;
    return (widget.subtotal * (_discountPercent / 100));
  }

  double get _grandTotal {
    return widget.subtotal - _discountAmount;
  }

  void _proceedToPayment() {
    if (_applyDiscount && !_formKey.currentState!.validate()) {
      return;
    }

    final result = CheckoutResult(
      hasDiscount: _applyDiscount,
      reason: _applyDiscount ? _discountReason : '',
      idType: _applyDiscount ? _idTypeController.text.trim() : '',
      idNumber: _applyDiscount ? _idNumberController.text.trim() : '',
      customerName: _customerNameController.text.trim(),
      notes: _notesController.text.trim(),
      discountPercent: _applyDiscount ? _discountPercent : 0.0,
      discountAmount: _discountAmount,
      grandTotal: _grandTotal,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Checkout & Discount',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customer Name (always accessible)
                const Text('Customer Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _customerNameController,
                  validator: (val) {
                    if (_applyDiscount && (val == null || val.trim().isEmpty)) {
                      return 'Customer name is required for discounts';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. Juan Dela Cruz',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    Text(
                      '₱${widget.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Apply Discount Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Apply Discount',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _applyDiscount,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _applyDiscount = val;
                        });
                      },
                    ),
                  ],
                ),

                if (_applyDiscount) ...[
                  const SizedBox(height: 12),
                  // Discount Reason Dropdown
                  const Text('Discount Reason',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _discountReason,
                        items: _reasonPercentages.keys.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text('$r (${_reasonPercentages[r]!.toInt()}%)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _discountReason = val;
                              _discountPercent = _reasonPercentages[val] ?? 20.0;
                              if (val == 'Senior Citizen') {
                                _idTypeController.text = 'Senior Citizen ID';
                              } else if (val == 'PWD') {
                                _idTypeController.text = 'PWD ID Card';
                              } else if (val == 'Employee') {
                                _idTypeController.text = 'Employee Badge';
                              } else {
                                _idTypeController.text = 'Government ID';
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ID Type
                  const Text('ID Type',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _idTypeController,
                    validator: (val) =>
                        _applyDiscount && (val == null || val.trim().isEmpty)
                            ? 'Please specify ID type'
                            : null,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ID Number
                  const Text('ID Number',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _idNumberController,
                    validator: (val) =>
                        _applyDiscount && (val == null || val.trim().isEmpty)
                            ? 'Please enter customer ID number'
                            : null,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Discount Notes
                  const Text('Discount Notes (Optional)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Valid ID presented',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],

                const Divider(height: 28),

                // Financial Breakdown (Subtotal - Discount = Final Total)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('₱${widget.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                if (_applyDiscount) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount (${_discountPercent.toInt()}%)',
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                      Text(
                        '-₱${_discountAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₱${_grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
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
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _proceedToPayment,
                        child: const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
