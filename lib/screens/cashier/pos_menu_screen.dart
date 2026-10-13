import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/item_options_dialog.dart';
import '../../widgets/order_type_dialog.dart';
import '../../widgets/checkout_discount_dialog.dart';
import '../../widgets/payment_method_dialog.dart';
import '../../widgets/virtual_receipt_dialog.dart';

class PosMenuScreen extends StatefulWidget {
  const PosMenuScreen({super.key});

  @override
  State<PosMenuScreen> createState() => _PosMenuScreenState();
}

class _PosMenuScreenState extends State<PosMenuScreen> {
  final AppState _appState = AppState();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isCompletingOrder = false;

  final List<String> _categories = [
    'All',
    'Burgers',
    'Pizza',
    'Pasta',
    'Chicken',
    'Rice Meals',
    'Snacks',
    'Desserts',
    'Coffee',
    'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  List<MenuItem> get _filteredItems {
    return _appState.menuItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openItemOptions(MenuItem item) {
    if (!item.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} is currently out of stock!'),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => ItemOptionsDialog(
        item: item,
        onAdd: (size, qty, notes) {
          _appState.addToCart(item, size, qty, notes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $qty ${item.name} ($size) to order'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _openOrderTypeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => OrderTypeDialog(
        currentType: _appState.currentOrderType,
        currentTable: _appState.currentTableNumber,
        onSave: (type, table) {
          _appState.setOrderType(type, table: table);
        },
      ),
    );
  }

  Future<void> _startCheckoutFlow() async {
    // Validation: Empty Cart
    if (_appState.currentCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item before proceeding to checkout.'),
          backgroundColor: AppTheme.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Step 1: Open Checkout & Discount Modal
    final checkoutResult = await showDialog<CheckoutResult>(
      context: context,
      builder: (ctx) => CheckoutDiscountDialog(subtotal: _appState.cartSubtotal),
    );

    if (checkoutResult == null) return; // User cancelled

    // Step 2: Open Payment Method Modal
    if (!mounted) return;
    final paymentResult = await showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentMethodDialog(totalAmount: checkoutResult.grandTotal),
    );

    if (paymentResult == null) return; // User cancelled

    // Step 3: Complete Order (Guard against duplicate click)
    if (_isCompletingOrder) return;
    _isCompletingOrder = true;

    try {
      final receipt = _appState.completeCurrentOrder(
        hasDiscount: checkoutResult.hasDiscount,
        discountReason: checkoutResult.reason,
        discountIdType: checkoutResult.idType,
        discountIdNumber: checkoutResult.idNumber,
        customerName: checkoutResult.customerName,
        discountNotes: checkoutResult.notes,
        discountPercent: checkoutResult.discountPercent,
        discountAmount: checkoutResult.discountAmount,
        totalAmount: checkoutResult.grandTotal,
        paymentMethod: paymentResult.paymentMethod,
        amountPaid: paymentResult.amountPaid,
        changeAmount: paymentResult.changeAmount,
      );

      // Step 4: Show Virtual Thermal Receipt Modal
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => VirtualReceiptDialog(
          receipt: receipt,
          onNewOrder: () {},
          onDone: () {},
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDualPane = constraints.maxWidth >= 780;

        return isDualPane
            ? Row(
                children: [
                  // Left Pane: Menu Catalog
                  Expanded(
                    flex: 6,
                    child: _buildMenuPane(),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  // Right Pane: Active Order Panel
                  Expanded(
                    flex: 4,
                    child: _buildOrderCartPanel(),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(child: _buildMenuPane()),
                  _buildMobileCartSummaryBar(),
                ],
              );
      },
    );
  }

  // --- LEFT PANE: MENU BROWSER ---
  Widget _buildMenuPane() {
    final items = _filteredItems;

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search menu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),

          // Category Filter Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Menu Grid
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No items found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildFoodCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(MenuItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: () => _openItemOptions(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Availability Tag
            Stack(
              children: [
                Image.network(
                  item.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.orange.shade50,
                    child: const Center(
                      child: Icon(Icons.fastfood, size: 36, color: AppTheme.primary),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isAvailable
                          ? AppTheme.success.withValues(alpha: 0.9)
                          : AppTheme.danger.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.isAvailable ? 'Available' : 'Not Available',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${item.basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- RIGHT PANE: CURRENT ORDER CART PANEL ---
  Widget _buildOrderCartPanel() {
    final cart = _appState.currentCart;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order #, Order Type, Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Order',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    'Order ${_appState.nextOrderNumber}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              InkWell(
                onTap: _openOrderTypeDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
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
                      const SizedBox(width: 4),
                      Text(
                        _appState.currentOrderType == 'Dine In'
                            ? '${_appState.currentOrderType} (${_appState.currentTableNumber})'
                            : _appState.currentOrderType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Cart Items List
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'No items in order yet.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select items from the menu to start.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (context, index) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final cartItem = cart[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        cartItem.selectedSize,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₱${cartItem.unitPrice.toStringAsFixed(0)} each',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                if (cartItem.specialNotes.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Note: ${cartItem.specialNotes}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 11,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Quantity Controls
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                color: Colors.grey.shade600,
                                onPressed: () => _appState.updateCartQuantity(index, -1),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                color: AppTheme.primary,
                                onPressed: () => _appState.updateCartQuantity(index, 1),
                              ),
                            ],
                          ),
                          // Line Total & Remove
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₱${cartItem.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _appState.removeFromCart(index),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Divider(height: 20),

          // Subtotal & Total Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text('₱${_appState.cartSubtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Due',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '₱${_appState.cartSubtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions: Clear Order & Checkout
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: cart.isNotEmpty
                      ? () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear Order?'),
                              content: const Text('Are you sure you want to remove all items from the cart?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                  onPressed: () {
                                    _appState.clearCart();
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  child: const Text('Clear Order'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _startCheckoutFlow,
                  child: Text(
                    _isCompletingOrder ? 'Processing...' : 'Checkout',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Mobile Bottom Bar for Small Screens ---
  Widget _buildMobileCartSummaryBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_appState.currentCart.length} Items',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '₱${_appState.cartSubtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _startCheckoutFlow,
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
