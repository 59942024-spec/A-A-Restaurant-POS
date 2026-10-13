import 'cart_item.dart';

class OrderReceipt {
  final String orderId;
  final DateTime timestamp;
  final String cashierId;
  final String cashierName;
  final String orderType; // 'Dine In', 'Takeout', 'Delivery'
  final String tableNumber; // e.g. 'Table 3'
  final List<CartItem> items;
  final double subtotal;
  final bool hasDiscount;
  final String discountReason;
  final String discountIdType;
  final String discountIdNumber;
  final String customerName;
  final String discountNotes;
  final double discountPercent;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod; // 'Cash', 'Card', 'QR Pay'
  final double amountPaid;
  final double changeAmount;
  String status; // 'Paid', 'Completed', 'Pending', 'Cancelled'
  final String shiftInfo;
  final String managerName;

  OrderReceipt({
    required this.orderId,
    required this.timestamp,
    required this.cashierId,
    required this.cashierName,
    required this.orderType,
    required this.tableNumber,
    required this.items,
    required this.subtotal,
    this.hasDiscount = false,
    this.discountReason = '',
    this.discountIdType = '',
    this.discountIdNumber = '',
    this.customerName = '',
    this.discountNotes = '',
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
    this.status = 'Completed',
    this.shiftInfo = '',
    this.managerName = '',
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'timestamp': timestamp.toIso8601String(),
    'cashierId': cashierId,
    'cashierName': cashierName,
    'orderType': orderType,
    'tableNumber': tableNumber,
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'hasDiscount': hasDiscount,
    'discountReason': discountReason,
    'discountIdType': discountIdType,
    'discountIdNumber': discountIdNumber,
    'customerName': customerName,
    'discountNotes': discountNotes,
    'discountPercent': discountPercent,
    'discountAmount': discountAmount,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'amountPaid': amountPaid,
    'changeAmount': changeAmount,
    'status': status,
    'shiftInfo': shiftInfo,
    'managerName': managerName,
  };

  factory OrderReceipt.fromJson(Map<String, dynamic> json) => OrderReceipt(
    orderId: json['orderId'] as String? ?? '',
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
        : DateTime.now(),
    cashierId: json['cashierId'] as String? ?? '',
    cashierName: json['cashierName'] as String? ?? '',
    orderType: json['orderType'] as String? ?? 'Dine In',
    tableNumber: json['tableNumber'] as String? ?? 'N/A',
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    hasDiscount: json['hasDiscount'] as bool? ?? false,
    discountReason: json['discountReason'] as String? ?? '',
    discountIdType: json['discountIdType'] as String? ?? '',
    discountIdNumber: json['discountIdNumber'] as String? ?? '',
    customerName: json['customerName'] as String? ?? '',
    discountNotes: json['discountNotes'] as String? ?? '',
    discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
    discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
    amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
    changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
    status: json['status'] as String? ?? 'Completed',
    shiftInfo: json['shiftInfo'] as String? ?? '',
    managerName: json['managerName'] as String? ?? '',
  );
}
