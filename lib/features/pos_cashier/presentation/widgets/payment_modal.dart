import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/micro_animations.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/pos_provider.dart';

class PaymentModal extends ConsumerStatefulWidget {
  const PaymentModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaymentModal(),
    );
  }

  @override
  ConsumerState<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends ConsumerState<PaymentModal> {
  String _selectedMethod = 'CASH'; // CASH, QRIS, DEBIT, TRANSFER
  double _paidAmount = 0;
  final TextEditingController _cashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final grandTotal = ref.read(posProvider).cartGrandTotal;
    _paidAmount = grandTotal;
    _cashController.text = grandTotal.toInt().toString();
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _onQuickCash(double amount) {
    setState(() {
      _paidAmount = amount;
      _cashController.text = amount.toInt().toString();
    });
  }

  void _processPayment() {
    final notifier = ref.read(posProvider.notifier);
    final order = notifier.completeOrder(paymentMethod: _selectedMethod);
    Navigator.pop(context); // Close payment modal
    _showReceiptDialog(context, order, _paidAmount);
  }

  void _showReceiptDialog(
      BuildContext context, OrderModel order, double paidAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ReceiptDialog(
        order: order,
        paidAmount: paidAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posProvider);
    final grandTotal = state.cartGrandTotal;
    final change = (_paidAmount - grandTotal).clamp(0.0, double.infinity);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Amount Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL YANG HARUS DIBAYAR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(grandTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Method Selectors
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MethodButton(
                    label: 'Tunai',
                    icon: Icons.payments_rounded,
                    isSelected: _selectedMethod == 'CASH',
                    onTap: () => setState(() => _selectedMethod = 'CASH'),
                  ),
                  const SizedBox(width: 8),
                  _MethodButton(
                    label: 'QRIS',
                    icon: Icons.qr_code_2_rounded,
                    isSelected: _selectedMethod == 'QRIS',
                    onTap: () => setState(() {
                      _selectedMethod = 'QRIS';
                      _paidAmount = grandTotal;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _MethodButton(
                    label: 'Debit',
                    icon: Icons.credit_card_rounded,
                    isSelected: _selectedMethod == 'DEBIT',
                    onTap: () => setState(() {
                      _selectedMethod = 'DEBIT';
                      _paidAmount = grandTotal;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _MethodButton(
                    label: 'Transfer',
                    icon: Icons.account_balance_rounded,
                    isSelected: _selectedMethod == 'TRANSFER',
                    onTap: () => setState(() {
                      _selectedMethod = 'TRANSFER';
                      _paidAmount = grandTotal;
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Specific UI per Payment Method
              if (_selectedMethod == 'CASH') ...[
                const Text(
                  'Uang Tunai Diterima',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '0',
                  ),
                  onChanged: (val) {
                    setState(() {
                      _paidAmount = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Quick Cash Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickCashChip(
                      label: 'Uang Pas',
                      onTap: () => _onQuickCash(grandTotal),
                    ),
                    _QuickCashChip(
                      label: 'Rp 50.000',
                      onTap: () => _onQuickCash(50000),
                    ),
                    _QuickCashChip(
                      label: 'Rp 100.000',
                      onTap: () => _onQuickCash(100000),
                    ),
                    _QuickCashChip(
                      label: 'Rp 200.000',
                      onTap: () => _onQuickCash(200000),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kembalian:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(change),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: change >= 0
                              ? AppColors.profit
                              : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_selectedMethod == 'QRIS') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          size: 140,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'QRIS Dinamis (GOPAY, OVO, DANA, BCA, Livin)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Status: Menunggu Pembayaran Pelanggan...',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.profit,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Silakan masukkan kartu pada mesin EDC / konfirmasi transfer sebesar ${CurrencyFormatter.format(grandTotal)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Confirm Button
              ElevatedButton(
                onPressed: (_selectedMethod == 'CASH' && _paidAmount < grandTotal)
                    ? null
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Selesaikan Transaksi & Cetak Struk',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodButton({
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
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
    );
  }
}

class _QuickCashChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickCashChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactileScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ReceiptDialog extends StatelessWidget {
  final OrderModel order;
  final double paidAmount;

  const _ReceiptDialog({
    required this.order,
    required this.paidAmount,
  });

  @override
  Widget build(BuildContext context) {
    final change = (paidAmount - order.grandTotal).clamp(0.0, double.infinity);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.profitLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.profit,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              order.invoiceNumber,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Struk Thermal Style Preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'KOPI KASIR MODERN',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Text(
                    'Jl. Boulevard Barat No. 88, Jakarta',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kasir: ${order.cashierName}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        order.orderType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x${item.quantity}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.totalPrice),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyFormatter.format(order.grandTotal),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bayar (${order.paymentMethod}):',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text(CurrencyFormatter.format(paidAmount),
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  if (change > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kembalian:',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(CurrencyFormatter.format(change),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Print & Close Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mengirim perintah cetak ke Thermal Printer Bluetooth...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Cetak Struk'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Selesai'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
