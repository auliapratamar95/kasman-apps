import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String? notes;
  
  // Historical snapshot at time of addition
  final double unitPrice;
  final double unitCost;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.notes,
    double? unitPrice,
    double? unitCost,
  })  : unitPrice = unitPrice ?? product.price,
        unitCost = unitCost ?? product.costPrice;

  double get totalPrice => unitPrice * quantity;
  double get totalCost => unitCost * quantity;
  double get totalProfit => totalPrice - totalCost;
  double get marginPercent =>
      totalPrice > 0 ? (totalProfit / totalPrice) * 100 : 0.0;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? notes,
    double? unitPrice,
    double? unitCost,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      unitPrice: unitPrice ?? this.unitPrice,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}
