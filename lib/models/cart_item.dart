import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  String selectedSize;
  double unitPrice;
  int quantity;
  String specialNotes;

  CartItem({
    required this.item,
    this.selectedSize = 'Medium',
    required this.unitPrice,
    this.quantity = 1,
    this.specialNotes = '',
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'selectedSize': selectedSize,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'specialNotes': specialNotes,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    item: MenuItem.fromJson(json['item'] as Map<String, dynamic>),
    selectedSize: json['selectedSize'] as String? ?? 'Medium',
    unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    quantity: json['quantity'] as int? ?? 1,
    specialNotes: json['specialNotes'] as String? ?? '',
  );
}
