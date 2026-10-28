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

// Initial Products from Blueprint
final defaultProducts = [
  const ProductModel(
    id: 'prod-1',
    categoryId: 'coffee',
    sku: 'CF-001',
    name: 'Es Kopi Susu Aren',
    price: 18000,
    costPrice: 7500,
    stock: 145,
    imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-2',
    categoryId: 'coffee',
    sku: 'CF-002',
    name: 'Americano Dingin',
    price: 15000,
    costPrice: 3500,
    stock: 98,
    imageUrl: 'https://images.unsplash.com/photo-1551030173-122aabc4489c?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-3',
    categoryId: 'non_coffee',
    sku: 'NC-001',
    name: 'Matcha Latte Oat',
    price: 24000,
    costPrice: 12000,
    stock: 75,
    imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-4',
    categoryId: 'snack',
    sku: 'SN-001',
    name: 'French Fries Large',
    price: 20000,
    costPrice: 8000,
    stock: 60,
    imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-5',
    categoryId: 'snack',
    sku: 'SN-002',
    name: 'Croissant Butter',
    price: 18000,
    costPrice: 14000,
    stock: 25,
    imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-6',
    categoryId: 'coffee',
    sku: 'CF-003',
    name: 'Caramel Macchiato',
    price: 26000,
    costPrice: 11000,
    stock: 50,
    imageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-7',
    categoryId: 'non_coffee',
    sku: 'NC-002',
    name: 'Red Velvet Latte',
    price: 22000,
    costPrice: 9500,
    stock: 45,
    imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=500&auto=format&fit=crop&q=60',
  ),
  const ProductModel(
    id: 'prod-8',
    categoryId: 'espresso',
    sku: 'ES-001',
    name: 'Double Espresso',
    price: 16000,
    costPrice: 4000,
    stock: 120,
    imageUrl: 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=500&auto=format&fit=crop&q=60',
  ),
];

// Seed Historical Orders to mirror Blueprint Laporan Bulanan exactly
List<OrderModel> generateSeedOrders() {
  final now = DateTime.now();
  final list = <OrderModel>[];

  // Helper to create aggregated completed order
  list.add(
    OrderModel(
      id: 'ord-seed-1',
      invoiceNumber: 'INV/20261027/001',
      cashierName: 'Budi Pratama',
      orderType: 'DINE_IN',
      items: [
        CartItemModel(
          product: defaultProducts[0], // Es Kopi Susu Aren
          quantity: 850,
          unitPrice: 18000,
          unitCost: 7500,
        ),
      ],
      subtotal: 15300000,
      discountAmount: 0,
      taxAmount: 0,
      grandTotal: 15300000,
      totalCost: 6375000,
      totalProfit: 8925000,
      paymentMethod: 'QRIS',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  );

  list.add(
    OrderModel(
      id: 'ord-seed-2',
      invoiceNumber: 'INV/20261027/002',
      cashierName: 'Siti Rahma',
      orderType: 'TAKEAWAY',
      items: [
        CartItemModel(
          product: defaultProducts[1], // Americano Dingin
          quantity: 420,
          unitPrice: 15000,
          unitCost: 3500,
        ),
      ],
      subtotal: 6300000,
      discountAmount: 0,
      taxAmount: 0,
      grandTotal: 6300000,
      totalCost: 1470000,
      totalProfit: 4830000,
      paymentMethod: 'CASH',
      createdAt: now.subtract(const Duration(days: 4)),
    ),
  );

  list.add(
    OrderModel(
      id: 'ord-seed-3',
      invoiceNumber: 'INV/20261027/003',
      cashierName: 'Budi Pratama',
      orderType: 'DINE_IN',
      items: [
        CartItemModel(
          product: defaultProducts[2], // Matcha Latte Oat
          quantity: 310,
          unitPrice: 24000,
          unitCost: 12000,
        ),
      ],
      subtotal: 7440000,
      discountAmount: 0,
      taxAmount: 0,
      grandTotal: 7440000,
      totalCost: 3720000,
      totalProfit: 3720000,
      paymentMethod: 'DEBIT',
      createdAt: now.subtract(const Duration(days: 7)),
    ),
  );

  list.add(
    OrderModel(
      id: 'ord-seed-4',
      invoiceNumber: 'INV/20261027/004',
      cashierName: 'Ahmad Faiz',
      orderType: 'DELIVERY',
      items: [
        CartItemModel(
          product: defaultProducts[3], // French Fries
          quantity: 290,
          unitPrice: 20000,
          unitCost: 8000,
        ),
      ],
      subtotal: 5800000,
      discountAmount: 0,
      taxAmount: 0,
      grandTotal: 5800000,
      totalCost: 2320000,
      totalProfit: 3480000,
      paymentMethod: 'QRIS',
      createdAt: now.subtract(const Duration(days: 12)),
    ),
  );

  list.add(
    OrderModel(
      id: 'ord-seed-5',
      invoiceNumber: 'INV/20261027/005',
      cashierName: 'Siti Rahma',
      orderType: 'TAKEAWAY',
      items: [
        CartItemModel(
          product: defaultProducts[4], // Croissant Butter
          quantity: 180,
          unitPrice: 18000,
          unitCost: 14000,
        ),
      ],
      subtotal: 3240000,
      discountAmount: 0,
      taxAmount: 0,
      grandTotal: 3240000,
      totalCost: 2520000,
      totalProfit: 720000,
      paymentMethod: 'CASH',
      createdAt: now.subtract(const Duration(days: 15)),
    ),
  );

  return list;
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
