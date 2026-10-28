import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/micro_animations.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../models/cart_item_model.dart';
import '../../providers/pos_provider.dart';

class CartPanel extends ConsumerWidget {
  final VoidCallback onCheckout;
  final bool isBottomSheet;

  const CartPanel({
    super.key,
    required this.onCheckout,
    this.isBottomSheet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);
    final isOwner = state.userRole == 'OWNER';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isBottomSheet
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : BorderRadius.circular(16),
        border: isBottomSheet
            ? null
            : Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header & Order Type Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pesanan Aktif',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (state.cart.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.cartTotalQuantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (state.cart.isNotEmpty)
                      TactileScaleTap(
                        onTap: () => notifier.clearCart(),
                        child: const Text(
                          'Hapus Semua',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Order Type Segmented Control
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _OrderTypeButton(
                        label: 'Dine In',
                        icon: Icons.restaurant_rounded,
                        isSelected: state.orderType == 'DINE_IN',
                        onTap: () => notifier.setOrderType('DINE_IN'),
                      ),
                      _OrderTypeButton(
                        label: 'Takeaway',
                        icon: Icons.takeout_dining_rounded,
                        isSelected: state.orderType == 'TAKEAWAY',
                        onTap: () => notifier.setOrderType('TAKEAWAY'),
                      ),
                      _OrderTypeButton(
                        label: 'Delivery',
                        icon: Icons.delivery_dining_rounded,
                        isSelected: state.orderType == 'DELIVERY',
                        onTap: () => notifier.setOrderType('DELIVERY'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Cart Items List
          Expanded(
            child: state.cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 48,
                          color: AppColors.textDisabled,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Keranjang Masih Kosong',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ketuk menu di katalog untuk menambahkan item',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: state.cart.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.cart[index];
                      return _CartItemTile(
                        item: item,
                        showProfit: isOwner,
                        onIncrement: () => notifier.addToCart(item.product),
                        onDecrement: () =>
                            notifier.decrementCartItem(item.product.id),
                        onDelete: () =>
                            notifier.removeFromCart(item.product.id),
                        onAddNote: () =>
                            _showNoteDialog(context, item, notifier),
                      );
                    },
                  ),
          ),

          const Divider(),

          // Calculation Summary & Checkout Action
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(state.cartSubtotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (state.discountAmount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Diskon Promo',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.discount,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '-${CurrencyFormatter.format(state.discountAmount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.discount,
                        ),
                      ),
                    ],
                  ),
                ],

                // Live Profit & Margin Indicator (Blueprint Feature)
                if (isOwner && state.cart.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.profitLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.profit.withValues(alpha: 0.3)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.trending_up_rounded,
                                  size: 16, color: AppColors.profit),
                              SizedBox(width: 6),
                              Text(
                                'Estimasi Laba Bersih: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.profit,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${CurrencyFormatter.format(state.cartTotalProfit)} (${CurrencyFormatter.formatPercent(state.cartMarginPercent)})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.profit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: MicroAnimations.fast,
                      child: Text(
                        CurrencyFormatter.format(state.cartGrandTotal),
                        key: ValueKey(state.cartGrandTotal),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Save Bill button
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: state.cart.isEmpty
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pesanan berhasil disimpan ke antrean Open Bill'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderStrong),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Simpan Bill',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Pay Now button
                    Expanded(
                      flex: 6,
                      child: ElevatedButton(
                        onPressed: state.cart.isEmpty ? null : onCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments_rounded, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Bayar Sekarang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(
      BuildContext context, CartItemModel item, PosNotifier notifier) {
    final controller = TextEditingController(text: item.notes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Catatan untuk ${item.product.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Less sugar, extra ice, tidak pedas...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.updateItemNotes(item.product.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TactileScaleTap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: MicroAnimations.fast,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool showProfit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback onAddNote;

  const _CartItemTile({
    required this.item,
    required this.showProfit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(item.unitPrice),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Total Item Price
              Text(
                CurrencyFormatter.format(item.totalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                'Catatan: ${item.notes}',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Actions bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Add note button
              TactileScaleTap(
                onTap: onAddNote,
                child: Row(
                  children: [
                    Icon(
                      item.notes?.isNotEmpty == true
                          ? Icons.edit_note_rounded
                          : Icons.add_comment_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.notes?.isNotEmpty == true ? 'Ubah Catatan' : 'Catatan',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Stepper
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _StepButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _StepButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactileScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }
}
