class MenuItem {
  final String id;
  String name;
  String category;
  double basePrice;
  Map<String, double> sizePrices; // e.g. {"Small": 90, "Medium": 100, "Large": 120}
  bool isAvailable;
  String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.sizePrices,
    this.isAvailable = true,
    required this.imageUrl,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    double? basePrice,
    Map<String, double>? sizePrices,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      sizePrices: sizePrices ?? Map<String, double>.from(this.sizePrices),
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'basePrice': basePrice,
    'sizePrices': sizePrices,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final rawSizePrices = json['sizePrices'] as Map<String, dynamic>? ?? {};
    final parsedSizePrices = <String, double>{};
    rawSizePrices.forEach((k, v) {
      parsedSizePrices[k] = (v as num).toDouble();
    });

    return MenuItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      sizePrices: parsedSizePrices,
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
