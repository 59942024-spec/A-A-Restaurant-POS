

class ShiftSummary {
  final DateTime date; // date of shift (start of day)
  final String cashierId;
  final String cashierName;
  final String shiftStart;
  final String shiftEnd;
  final int totalOrders;
  final int uniqueCustomers;
  final double grossSales; // before discounts
  final double netSales; // after discounts
  final double totalDiscounts;
  final double cashPayments;
  final double qrPayments;
  final double debitPayments;
  final Map<String, int> ordersPerCategory; // category -> count
  final Map<String, int> ordersPerType; // Dine In, Takeout, Delivery
  final int uniqueTables;

  ShiftSummary({
    required this.date,
    required this.cashierId,
    required this.cashierName,
    required this.shiftStart,
    required this.shiftEnd,
    required this.totalOrders,
    required this.uniqueCustomers,
    required this.grossSales,
    required this.netSales,
    required this.totalDiscounts,
    required this.cashPayments,
    required this.qrPayments,
    required this.debitPayments,
    required this.ordersPerCategory,
    required this.ordersPerType,
    required this.uniqueTables,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'cashierId': cashierId,
        'cashierName': cashierName,
        'shiftStart': shiftStart,
        'shiftEnd': shiftEnd,
        'totalOrders': totalOrders,
        'uniqueCustomers': uniqueCustomers,
        'grossSales': grossSales,
        'netSales': netSales,
        'totalDiscounts': totalDiscounts,
        'cashPayments': cashPayments,
        'qrPayments': qrPayments,
        'debitPayments': debitPayments,
        'ordersPerCategory': ordersPerCategory,
        'ordersPerType': ordersPerType,
        'uniqueTables': uniqueTables,
      };

  factory ShiftSummary.fromJson(Map<String, dynamic> json) => ShiftSummary(
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        cashierId: json['cashierId'] as String? ?? '',
        cashierName: json['cashierName'] as String? ?? '',
        shiftStart: json['shiftStart'] as String? ?? '',
        shiftEnd: json['shiftEnd'] as String? ?? '',
        totalOrders: json['totalOrders'] as int? ?? 0,
        uniqueCustomers: json['uniqueCustomers'] as int? ?? 0,
        grossSales: (json['grossSales'] as num?)?.toDouble() ?? 0.0,
        netSales: (json['netSales'] as num?)?.toDouble() ?? 0.0,
        totalDiscounts: (json['totalDiscounts'] as num?)?.toDouble() ?? 0.0,
        cashPayments: (json['cashPayments'] as num?)?.toDouble() ?? 0.0,
        qrPayments: (json['qrPayments'] as num?)?.toDouble() ?? 0.0,
        debitPayments: (json['debitPayments'] as num?)?.toDouble() ?? 0.0,
        ordersPerCategory:
            Map<String, int>.from(json['ordersPerCategory'] as Map? ?? {}),
        ordersPerType: Map<String, int>.from(json['ordersPerType'] as Map? ?? {}),
        uniqueTables: json['uniqueTables'] as int? ?? 0,
      );
}
