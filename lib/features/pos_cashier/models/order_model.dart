import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String invoiceNumber;
  final String cashierName;
  final String orderType; // DINE_IN, TAKEAWAY, DELIVERY
  final List<CartItemModel> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;
  final double totalCost;
  final double totalProfit;
  final String paymentMethod; // CASH, QRIS, DEBIT, TRANSFER
  final String status; // COMPLETED, OPEN_BILL, VOID
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.invoiceNumber,
    required this.cashierName,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.grandTotal,
    required this.totalCost,
    required this.totalProfit,
    required this.paymentMethod,
    this.status = 'COMPLETED',
    required this.createdAt,
  });

  int get totalItemCount =>
      items.fold(0, (previousValue, item) => previousValue + item.quantity);

  double get marginPercent =>
      grandTotal > 0 ? (totalProfit / grandTotal) * 100 : 0.0;
}
