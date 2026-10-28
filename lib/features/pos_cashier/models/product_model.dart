class ProductModel {
  final String id;
  final String categoryId;
  final String sku;
  final String name;
  final double price; // Harga Jual
  final double costPrice; // Harga Modal / HPP
  final int stock;
  final bool trackStock;
  final String? imageUrl;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.sku,
    required this.name,
    required this.price,
    required this.costPrice,
    this.stock = 100,
    this.trackStock = true,
    this.imageUrl,
    this.isActive = true,
  });

  /// Profit per unit (Laba per Unit = Harga Jual - Modal)
  double get profitPerUnit => price - costPrice;

  /// Margin % = ((Harga Jual - Modal) / Harga Jual) * 100
  double get marginPercent => price > 0 ? ((price - costPrice) / price) * 100 : 0.0;

  /// COGS % = (Modal / Harga Jual) * 100
  double get cogsPercent => price > 0 ? (costPrice / price) * 100 : 0.0;

  /// Markup % = ((Harga Jual - Modal) / Modal) * 100
  double get markupPercent =>
      costPrice > 0 ? ((price - costPrice) / costPrice) * 100 : 0.0;

  ProductModel copyWith({
    String? id,
    String? categoryId,
    String? sku,
    String? name,
    double? price,
    double? costPrice,
    int? stock,
    bool? trackStock,
    String? imageUrl,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      trackStock: trackStock ?? this.trackStock,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
