import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../models/order_receipt.dart';
import '../models/employee.dart';
import '../models/cashier_session.dart';
import '../services/storage_service.dart';
import '../models/shift_summary.dart';
import '../models/owner_account.dart';
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal() {
    _initializeData();
  }
// Calculate today's sales using existing today's orders.
double get todaySales {
  return todayOrders.fold(
    0.0,
    (total, order) => total + order.totalAmount,
  );
}

// Update an existing order's status.
void updateOrderStatus(String orderId, String newStatus) {
  for (final order in orders) {
    if (order.orderId == orderId) {
      order.status = newStatus;
      _persist();
      notifyListeners();
      return;
    }
  }
}

  // --- Owner & Cashier Accounts ---
  OwnerAccount? ownerAccount;

  bool get hasOwnerAccount => ownerAccount != null;

  void registerOwner(OwnerAccount acct) {
    ownerAccount = acct;
    _persist();
    notifyListeners();
  }

  bool authenticateOwner(String username, String password) {
    final acct = ownerAccount;
    if (acct != null) {
      return acct.username == username.trim() && acct.password == password;
    }
    // Legacy fallback, kept so a fresh install can never lock the owner out.
    return username.trim() == 'enchang' && password == 'enchang';
  }

  String get activeOwnerName => ownerAccount?.fullName.isNotEmpty == true
      ? ownerAccount!.fullName
      : 'enchang (Owner)';

  /// Returns the matching active cashier, or null on bad credentials.
  Employee? authenticateCashier(String username, String password) {
    for (final e in employees) {
      if (e.username == username.trim() &&
          e.password == password &&
          e.isActive) {
        return e;
      }
    }
    return null;
  }

  /// Returns an error message, or null on success.
  String? registerCashier(Employee emp) {
    if (emp.username.trim().isEmpty) return 'Username is required';
    if (emp.password.isEmpty) return 'Password is required';
    if (employees.any((e) => e.username == emp.username.trim())) {
      return 'That username is already taken';
    }
    if (employees.any((e) => e.id == emp.id)) {
      return 'That employee ID is already taken';
    }
    addEmployee(emp); // already persists + notifies
    return null;
  }

  // --- Theme State ---
  bool isDarkMode = false;
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    _persist();
    notifyListeners();
  }

  // --- Restaurant Info ---
  String restaurantName = 'ELEVTIVE A & A';
  String contactNumber = '00002024';
  String address = 'Concepcion Holy Cross College INC.';

  void updateRestaurantInfo(String name, String contact, String addr) {
    restaurantName = name;
    contactNumber = contact;
    address = addr;
    _persist();
    notifyListeners();
  }

  // --- Cashier Session State ---
  CashierSession? activeSession;

  bool get hasActiveCashierSession => activeSession != null;
  String get activeCashierName =>
      activeSession?.fullName.isNotEmpty == true ? activeSession!.fullName : 'Juan Dela Cruz';
  String get activeCashierId =>
      activeSession?.employeeId.isNotEmpty == true ? activeSession!.employeeId : 'CSH001';
  String get activeManager =>
      activeSession?.managerToday.isNotEmpty == true ? activeSession!.managerToday : 'Enchang (General Manager)';
  String get activeShift => activeSession != null
      ? '${activeSession!.shiftStart} - ${activeSession!.shiftEnd}'
      : '08:00 AM - 04:00 PM';

  void loginCashier(CashierSession session) {
    activeSession = session;
    _persist();
    notifyListeners();
  }

  void logoutCashier() {
    activeSession = null;
    _persist();
    notifyListeners();
  }

  // --- Current POS Ordering State ---
  int _orderCounter = 1;
  String get nextOrderNumber => '#${_orderCounter.toString().padLeft(3, '0')}';
  String currentOrderType = 'Dine In'; // 'Dine In', 'Takeout', 'Delivery'
  String currentTableNumber = 'Table 3';

  void setOrderType(String type, {String table = 'Table 1'}) {
    currentOrderType = type;
    if (type == 'Dine In') {
      currentTableNumber = table;
    } else {
      currentTableNumber = 'N/A';
    }
    notifyListeners();
  }

  // --- Cart Management ---
  final List<CartItem> currentCart = [];

  double get cartSubtotal {
    return currentCart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(MenuItem item, String size, int qty, String notes) {
    double price = item.sizePrices[size] ?? item.basePrice;

    int existingIndex = currentCart.indexWhere((c) =>
        c.item.id == item.id &&
        c.selectedSize == size &&
        c.specialNotes.trim() == notes.trim());

    if (existingIndex != -1) {
      currentCart[existingIndex].quantity += qty;
    } else {
      currentCart.add(CartItem(
        item: item,
        selectedSize: size,
        unitPrice: price,
        quantity: qty,
        specialNotes: notes,
      ));
    }
    notifyListeners();
  }

  void updateCartQuantity(int index, int delta) {
    if (index >= 0 && index < currentCart.length) {
      currentCart[index].quantity += delta;
      if (currentCart[index].quantity <= 0) {
        currentCart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < currentCart.length) {
      currentCart.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    currentCart.clear();
    notifyListeners();
  }

  // --- Menu Management (CRUD) ---
  final List<MenuItem> menuItems = [];

  void toggleItemAvailability(String id) {
    final index = menuItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      menuItems[index].isAvailable = !menuItems[index].isAvailable;
      _persist();
      notifyListeners();
    }
  }

  void addMenuItem(MenuItem item) {
    menuItems.add(item);
    _persist();
    notifyListeners();
  }

  void updateMenuItem(MenuItem updated) {
    final index = menuItems.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      menuItems[index] = updated;
      _persist();
      notifyListeners();
    }
  }

  void deleteMenuItem(String id) {
    menuItems.removeWhere((item) => item.id == id);
    _persist();
    notifyListeners();
  }

  // --- Orders & Transactions ---
  final List<OrderReceipt> orders = [];
final List<ShiftSummary> shiftSummaries = [];

  OrderReceipt completeCurrentOrder({
    required bool hasDiscount,
    required String discountReason,
    required String discountIdType,
    required String discountIdNumber,
    required String customerName,
    required String discountNotes,
    required double discountPercent,
    required double discountAmount,
    required double totalAmount,
    required String paymentMethod,
    required double amountPaid,
    required double changeAmount,
  }) {
    final receipt = OrderReceipt(
      orderId: nextOrderNumber,
      timestamp: DateTime.now(),
      cashierId: activeCashierId,
      cashierName: activeCashierName,
      orderType: currentOrderType,
      tableNumber: currentTableNumber,
      items: List<CartItem>.from(currentCart),
      subtotal: cartSubtotal,
      hasDiscount: hasDiscount,
      discountReason: discountReason,
      discountIdType: discountIdType,
      discountIdNumber: discountIdNumber,
      customerName: customerName,
      discountNotes: discountNotes,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      status: 'Paid',
      shiftInfo: activeShift,
      managerName: activeManager,
    );

    orders.insert(0, receipt);
    _orderCounter++;
    currentCart.clear();
    _persist();
    notifyListeners();
    return receipt;
  }

  /// Saves a generated shift summary
  void addShiftSummary(ShiftSummary summary) {
    shiftSummaries.add(summary);
    _persist();
    notifyListeners();
  }


  // --- DATE-AWARE CALCULATION HELPERS ---

  /// Checks if two DateTimes fall on the exact same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a DateTime belongs to the current calendar week (Monday 00:00 to Sunday 23:59:59)
  static bool isCurrentWeek(DateTime dt) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monday = todayStart.subtract(Duration(days: now.weekday - 1));
    final sundayEnd = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    return dt.isAfter(monday.subtract(const Duration(milliseconds: 1))) &&
           dt.isBefore(sundayEnd.add(const Duration(milliseconds: 1)));
  }

  // --- TODAY'S OVERVIEW (Strictly Today Only, No Fake Numbers) ---

  List<OrderReceipt> get todayOrders {
    final now = DateTime.now();
    return orders.where((o) => isSameDay(o.timestamp, now)).toList();
  }

  /// Generates a ShiftSummary for the active cashier for the current day
  ShiftSummary generateShiftSummary() {
  final now = DateTime.now();

  // Get today's orders for the currently logged-in cashier.
  final cashierOrders = orders.where((order) {
    return order.cashierId == activeCashierId &&
        isSameDay(order.timestamp, now) &&
        order.status != 'Cancelled';
  }).toList();

  final totalOrders = cashierOrders.length;

  // Count named customers only; blank names are not unique customers.
  final uniqueCustomers = cashierOrders
      .map((order) => order.customerName.trim())
      .where((name) => name.isNotEmpty)
      .toSet()
      .length;

  // Sales and discounts.
  final grossSales = cashierOrders.fold<double>(
    0.0,
    (sum, order) => sum + order.subtotal,
  );

  final totalDiscounts = cashierOrders.fold<double>(
    0.0,
    (sum, order) =>
        sum + (order.hasDiscount ? order.discountAmount : 0.0),
  );

  final netSales = cashierOrders.fold<double>(
    0.0,
    (sum, order) => sum + order.totalAmount,
  );

  // Payment breakdown.
  double cash = 0.0;
  double qr = 0.0;
  double card = 0.0;

  for (final order in cashierOrders) {
    switch (order.paymentMethod.trim().toLowerCase()) {
      case 'cash':
        cash += order.totalAmount;
        break;
      case 'qr':
      case 'qr pay':
        qr += order.totalAmount;
        break;
      case 'card':
      case 'debit':
        card += order.totalAmount;
        break;
    }
  }

  // Count items by category and orders by type.
  final Map<String, int> perCategory = {};
  final Map<String, int> perType = {
    'Dine In': 0,
    'Takeout': 0,
    'Delivery': 0,
  };

  final Set<String> tables = {};

  for (final order in cashierOrders) {
    for (final cartItem in order.items) {
      final category = cartItem.item.category;
      perCategory[category] = (perCategory[category] ?? 0) +
          cartItem.quantity;
    }

    perType[order.orderType] = (perType[order.orderType] ?? 0) + 1;

    if (order.tableNumber.isNotEmpty &&
        order.tableNumber != 'N/A') {
      tables.add(order.tableNumber);
    }
  }

  return ShiftSummary(
    date: DateTime(now.year, now.month, now.day),
    cashierId: activeCashierId,
    cashierName: activeCashierName,
    shiftStart: activeSession?.shiftStart ?? '',
    shiftEnd: activeSession?.shiftEnd ?? '',
    totalOrders: totalOrders,
    uniqueCustomers: uniqueCustomers,
    grossSales: grossSales,
    netSales: netSales,
    totalDiscounts: totalDiscounts,
    cashPayments: cash,
    qrPayments: qr,
    debitPayments: card,
    ordersPerCategory: perCategory,
    ordersPerType: perType,
    uniqueTables: tables.length,
  );
}


  int get todayOrdersCount => todayOrders.length;

  int get todayCompletedCount =>
      todayOrders.where((o) => o.status == 'Completed' || o.status == 'Paid').length;

  int get todayPendingCount =>
      todayOrders.where((o) => o.status == 'Pending').length;

  // --- SALES THIS WEEK (Dynamic & Real) ---

  List<OrderReceipt> get thisWeekOrders =>
      orders.where((o) => isCurrentWeek(o.timestamp)).toList();

  double get thisWeekSales =>
      thisWeekOrders.fold(0.0, (sum, o) => sum + (o.status != 'Cancelled' ? o.totalAmount : 0.0));

  /// Calculates actual daily sales for Monday through Sunday of the current week
  Map<String, double> get weeklySalesByDay {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monday = todayStart.subtract(Duration(days: now.weekday - 1));

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> result = {};

    for (int i = 0; i < 7; i++) {
      final targetDate = monday.add(Duration(days: i));
      final dayOrders = orders.where((o) => isSameDay(o.timestamp, targetDate));
      final dayTotal = dayOrders.fold(
          0.0, (sum, o) => sum + (o.status != 'Cancelled' ? o.totalAmount : 0.0));
      result[dayLabels[i]] = dayTotal;
    }
    return result;
  }

  // --- INVENTORY COUNTS ---
  int get availableItemsCount => menuItems.where((i) => i.isAvailable).length;
  int get outOfStockCount => menuItems.where((i) => !i.isAvailable).length;

  // --- ALL-TIME AGGREGATES ---
  double get totalSales =>
      orders.fold(0.0, (sum, o) => sum + (o.status != 'Cancelled' ? o.totalAmount : 0.0));
  int get totalOrdersCount => orders.length;
  int get completedOrdersCount =>
      orders.where((o) => o.status == 'Completed' || o.status == 'Paid').length;
  int get pendingOrdersCount =>
      orders.where((o) => o.status == 'Pending').length;

  // --- Employees Management ---
  final List<Employee> employees = [];

  void toggleEmployeeActive(String id) {
    final idx = employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      employees[idx].isActive = !employees[idx].isActive;
      _persist();
      notifyListeners();
    }
  }

  void addEmployee(Employee emp) {
    employees.add(emp);
    _persist();
    notifyListeners();
  }

  void updateEmployee(Employee emp) {
    final idx = employees.indexWhere((e) => e.id == emp.id);
    if (idx != -1) {
      employees[idx] = emp;
      _persist();
      notifyListeners();
    }
  }

  void deleteEmployee(String id) {
    employees.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  // --- PERSISTENCE AND DATA INITIALIZATION ---

  void _persist() {
    // ponytail: whole-file JSON rewrite on every save. Fine up to a few
    // thousand orders; move to SQLite (sqflite) if a busy day makes saves
    // noticeable.
    final data = {
      'restaurantName': restaurantName,
      'contactNumber': contactNumber,
      'address': address,
      'isDarkMode': isDarkMode,
      'orderCounter': _orderCounter,
      'activeSession': activeSession?.toJson(),
      'ownerAccount': ownerAccount?.toJson(),
      'menuItems': menuItems.map((m) => m.toJson()).toList(),
      'employees': employees.map((e) => e.toJson()).toList(),
      'shiftSummaries': shiftSummaries.map((s) => s.toJson()).toList(),
      'orders': orders.map((o) => o.toJson()).toList(),
    };
    StorageService.saveData(data);
  }

  Future<void> _initializeData() async {
    final savedData = await StorageService.loadData();
    if (savedData != null) {
      try {
        restaurantName = savedData['restaurantName'] as String? ?? restaurantName;
        contactNumber = savedData['contactNumber'] as String? ?? contactNumber;
        address = savedData['address'] as String? ?? address;
        isDarkMode = savedData['isDarkMode'] as bool? ?? isDarkMode;
        _orderCounter = savedData['orderCounter'] as int? ?? 1;

        if (savedData['activeSession'] != null) {
          activeSession = CashierSession.fromJson(
              savedData['activeSession'] as Map<String, dynamic>);
        }

        if (savedData['ownerAccount'] != null) {
          ownerAccount = OwnerAccount.fromJson(
              savedData['ownerAccount'] as Map<String, dynamic>);
        }

        _restoreList(savedData['menuItems'], menuItems, MenuItem.fromJson);
        _restoreList(savedData['employees'], employees, Employee.fromJson);
        _restoreList(
            savedData['shiftSummaries'], shiftSummaries, ShiftSummary.fromJson);
        _restoreList(savedData['orders'], orders, OrderReceipt.fromJson);

        notifyListeners();
        return; // the file parsed cleanly, trust it
      } catch (e) {
        debugPrint('Error restoring saved data: $e');
      }
    }

    // Default initialization if no saved data was found
    _initializeDefaultCatalog();
  }

  void _restoreList<T>(
    dynamic raw,
    List<T> target,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return;
    target.clear();
    for (final e in raw) {
      target.add(fromJson(e as Map<String, dynamic>));
    }
  }

  void _initializeDefaultCatalog() {
    _persist();
    notifyListeners();
  }
}
