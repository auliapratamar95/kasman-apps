import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

// Initial Categories
final defaultCategories = [
  const CategoryModel(id: 'all', name: 'Semua Menu', icon: Icons.grid_view_rounded),
  const CategoryModel(id: 'coffee', name: 'Signature Coffee', icon: Icons.coffee_rounded),
  const CategoryModel(id: 'espresso', name: 'Espresso & Manual', icon: Icons.local_cafe_rounded),
  const CategoryModel(id: 'non_coffee', name: 'Non-Coffee', icon: Icons.local_drink_rounded),
  const CategoryModel(id: 'snack', name: 'Snack & Pastry', icon: Icons.bakery_dining_rounded),
];

// Initial Products (Kosong - Siap input manual oleh tim)
final List<ProductModel> defaultProducts = [];

// Initial Orders (Kosong)
List<OrderModel> generateSeedOrders() {
  return [];
}


// POS State Class
class PosState {
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final String searchQuery;
  final List<ProductModel> products;
  final List<CartItemModel> cart;
  final double discountAmount;
  final String orderType; // DINE_IN, TAKEAWAY, DELIVERY
  final String customerName;
  final String tableNumber;
  final List<OrderModel> orders;
  final String activeCashier;
  final String userRole; // OWNER or CASHIER
  final bool isOwnerLocked;
  final String reportPeriod; // 'today', 'week', 'month', 'year'

  const PosState({
    required this.categories,
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    required this.products,
    this.cart = const [],
    this.discountAmount = 0,
    this.orderType = 'DINE_IN',
    this.customerName = '',
    this.tableNumber = '',
    required this.orders,
    this.activeCashier = 'Budi Pratama (Kasir 1)',
    this.userRole = 'OWNER',
    this.isOwnerLocked = false,
    this.reportPeriod = 'month',
  });

  // Filtered Products
  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchesCategory =
          selectedCategoryId == 'all' || p.categoryId == selectedCategoryId;
      final matchesSearch =
          searchQuery.isEmpty || p.name.toLowerCase().contains(searchQuery.toLowerCase()) || p.sku.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch && p.isActive;
    }).toList();
  }

  // Cart Calculations
  double get cartSubtotal =>
      cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get cartTotalCost =>
      cart.fold(0.0, (sum, item) => sum + item.totalCost);

  double get cartGrandTotal =>
      (cartSubtotal - discountAmount) > 0 ? (cartSubtotal - discountAmount) : 0.0;

  double get cartTotalProfit =>
      (cartGrandTotal - cartTotalCost);

  double get cartMarginPercent =>
      cartGrandTotal > 0 ? (cartTotalProfit / cartGrandTotal) * 100 : 0.0;

  int get cartTotalQuantity =>
      cart.fold(0, (sum, item) => sum + item.quantity);

  PosState copyWith({
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    List<ProductModel>? products,
    List<CartItemModel>? cart,
    double? discountAmount,
    String? orderType,
    String? customerName,
    String? tableNumber,
    List<OrderModel>? orders,
    String? activeCashier,
    String? userRole,
    bool? isOwnerLocked,
    String? reportPeriod,
  }) {
    return PosState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      products: products ?? this.products,
      cart: cart ?? this.cart,
      discountAmount: discountAmount ?? this.discountAmount,
      orderType: orderType ?? this.orderType,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      orders: orders ?? this.orders,
      activeCashier: activeCashier ?? this.activeCashier,
      userRole: userRole ?? this.userRole,
      isOwnerLocked: isOwnerLocked ?? this.isOwnerLocked,
      reportPeriod: reportPeriod ?? this.reportPeriod,
    );
  }
}

// Riverpod 3 Notifier
class PosNotifier extends Notifier<PosState> {
  @override
  PosState build() {
    return PosState(
      categories: defaultCategories,
      products: defaultProducts,
      orders: generateSeedOrders(),
    );
  }

  void selectCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setOrderType(String type) {
    state = state.copyWith(orderType: type);
  }

  void setCustomerInfo({String? name, String? table}) {
    state = state.copyWith(
      customerName: name ?? state.customerName,
      tableNumber: table ?? state.tableNumber,
    );
  }

  void setReportPeriod(String period) {
    state = state.copyWith(reportPeriod: period);
  }

  void addToCart(ProductModel product) {
    final existingIndex =
        state.cart.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final currentItem = state.cart[existingIndex];
      final updatedList = List<CartItemModel>.from(state.cart);
      updatedList[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
      state = state.copyWith(cart: updatedList);
    } else {
      state = state.copyWith(
        cart: [
          ...state.cart,
          CartItemModel(
            product: product,
            quantity: 1,
            unitPrice: product.price,
            unitCost: product.costPrice,
          ),
        ],
      );
    }
  }

  void decrementCartItem(String productId) {
    final existingIndex =
        state.cart.indexWhere((item) => item.product.id == productId);
    if (existingIndex >= 0) {
      final currentItem = state.cart[existingIndex];
      if (currentItem.quantity > 1) {
        final updatedList = List<CartItemModel>.from(state.cart);
        updatedList[existingIndex] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
        state = state.copyWith(cart: updatedList);
      } else {
        removeFromCart(productId);
      }
    }
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cart: state.cart.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateItemNotes(String productId, String notes) {
    final updatedList = state.cart.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(notes: notes);
      }
      return item;
    }).toList();
    state = state.copyWith(cart: updatedList);
  }

  void setDiscount(double amount) {
    state = state.copyWith(discountAmount: amount);
  }

  void clearCart() {
    state = state.copyWith(
      cart: [],
      discountAmount: 0,
      customerName: '',
      tableNumber: '',
    );
  }

  // Complete Order
  OrderModel completeOrder({required String paymentMethod}) {
    final invoice = 'INV/${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}/${(state.orders.length + 1).toString().padLeft(3, '0')}';

    final order = OrderModel(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: invoice,
      cashierName: state.activeCashier,
      orderType: state.orderType,
      items: List.from(state.cart),
      subtotal: state.cartSubtotal,
      discountAmount: state.discountAmount,
      taxAmount: 0,
      grandTotal: state.cartGrandTotal,
      totalCost: state.cartTotalCost,
      totalProfit: state.cartTotalProfit,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    // Update product stocks
    final updatedProducts = state.products.map((p) {
      final inCart = state.cart.firstWhere(
        (ci) => ci.product.id == p.id,
        orElse: () => CartItemModel(product: p, quantity: 0),
      );
      if (inCart.quantity > 0) {
        return p.copyWith(stock: (p.stock - inCart.quantity).clamp(0, 9999));
      }
      return p;
    }).toList();

    state = state.copyWith(
      orders: [order, ...state.orders],
      products: updatedProducts,
      cart: [],
      discountAmount: 0,
      customerName: '',
      tableNumber: '',
    );

    return order;
  }

  // Product Management (Add or Edit)
  void saveProduct(ProductModel product) {
    final index = state.products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final list = List<ProductModel>.from(state.products);
      list[index] = product;
      state = state.copyWith(products: list);
    } else {
      state = state.copyWith(
        products: [product, ...state.products],
      );
    }
  }

  void deleteProduct(String productId) {
    state = state.copyWith(
      products: state.products.where((p) => p.id != productId).toList(),
    );
  }

  // Role & Shift Switcher
  void setUserRole(String role) {
    state = state.copyWith(userRole: role);
  }

  void setOwnerLocked(bool locked) {
    state = state.copyWith(isOwnerLocked: locked);
  }

  void setActiveCashier(String cashier) {
    state = state.copyWith(activeCashier: cashier);
  }
}

final posProvider = NotifierProvider<PosNotifier, PosState>(PosNotifier.new);
