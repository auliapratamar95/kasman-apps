import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/utils/currency_formatter.dart';
import '../pos_cashier/models/product_model.dart';
import '../pos_cashier/providers/pos_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final ProductModel? product;

  const ProductFormDialog({super.key, this.product});

  static Future<void> show(BuildContext context, {ProductModel? product}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  String _selectedCategoryId = 'coffee';

  double _sellingPrice = 0.0;
  double _costPrice = 0.0;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _priceController = TextEditingController(
        text: p != null ? p.price.toInt().toString() : '18000');
    _costPriceController = TextEditingController(
        text: p != null ? p.costPrice.toInt().toString() : '7500');
    _stockController = TextEditingController(
        text: p != null ? p.stock.toString() : '100');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategoryId = p?.categoryId ?? 'coffee';

    _sellingPrice = double.tryParse(_priceController.text) ?? 18000;
    _costPrice = double.tryParse(_costPriceController.text) ?? 7500;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _recalc() {
    setState(() {
      _sellingPrice = double.tryParse(_priceController.text) ?? 0.0;
      _costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final id = widget.product?.id ??
          'prod-${DateTime.now().millisecondsSinceEpoch}';
      final sku = _skuController.text.trim().isEmpty
          ? 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
          : _skuController.text.trim();

      final newProduct = ProductModel(
        id: id,
        categoryId: _selectedCategoryId,
        sku: sku,
        name: _nameController.text.trim(),
        price: _sellingPrice,
        costPrice: _costPrice,
        stock: int.tryParse(_stockController.text) ?? 100,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
      );

      ref.read(posProvider.notifier).saveProduct(newProduct);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Produk "${newProduct.name}" berhasil disimpan dengan HPP ${CurrencyFormatter.format(newProduct.costPrice)}!'),
          backgroundColor: AppColors.profit,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profit = _sellingPrice - _costPrice;
    final marginPercent =
        _sellingPrice > 0 ? (profit / _sellingPrice) * 100 : 0.0;
    final cogsPercent =
        _sellingPrice > 0 ? (_costPrice / _sellingPrice) * 100 : 0.0;

    final isHealthyMargin = marginPercent >= 40.0;
    final isModerateMargin = marginPercent >= 20.0 && marginPercent < 40.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.product == null
                          ? 'Tambah Produk & HPP'
                          : 'Edit Produk & HPP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Masukkan harga jual dan harga modal (HPP) untuk kalkulasi laba otomatis.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Name & SKU
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama Produk',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: Es Kopi Susu Aren',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nama produk wajib diisi'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SKU / Barcode',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              hintText: 'CF-001',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category & Stock
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kategori',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'coffee',
                                  child: Text('Signature Coffee')),
                              DropdownMenuItem(
                                  value: 'espresso',
                                  child: Text('Espresso & Manual')),
                              DropdownMenuItem(
                                  value: 'non_coffee', child: Text('Non-Coffee')),
                              DropdownMenuItem(
                                  value: 'snack', child: Text('Snack & Pastry')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategoryId = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jumlah Stok',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '100',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 14),

                // Pricing Inputs: Harga Jual & Harga Modal (HPP)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.sell_rounded,
                                  size: 15, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text('Harga Jual (Selling Price)',
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: 'Rp ',
                              hintText: '18000',
                            ),
                            onChanged: (_) => _recalc(),
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Harga harus angka valid'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.inventory_rounded,
                                  size: 15, color: AppColors.cogs),
                              SizedBox(width: 6),
                              Text('Harga Modal / HPP (Cost)',
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _costPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: 'Rp ',
                              hintText: '7500',
                            ),
                            onChanged: (_) => _recalc(),
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'HPP harus angka valid'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Live Auto Margin Calculator Card (From Blueprint Section 4)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHealthyMargin
                        ? AppColors.profitLight.withOpacity(0.4)
                        : (isModerateMargin
                            ? AppColors.cogsLight.withOpacity(0.4)
                            : AppColors.dangerLight.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isHealthyMargin
                          ? AppColors.profit.withOpacity(0.3)
                          : (isModerateMargin
                              ? AppColors.cogs.withOpacity(0.3)
                              : AppColors.danger.withOpacity(0.3)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isHealthyMargin
                                    ? Icons.check_circle_rounded
                                    : (isModerateMargin
                                        ? Icons.info_rounded
                                        : Icons.warning_amber_rounded),
                                size: 18,
                                color: isHealthyMargin
                                    ? AppColors.profit
                                    : (isModerateMargin
                                        ? AppColors.cogs
                                        : AppColors.danger),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Kalkulator Margin Real-Time',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isHealthyMargin
                                  ? AppColors.profit
                                  : (isModerateMargin
                                      ? AppColors.cogs
                                      : AppColors.danger),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isHealthyMargin
                                  ? 'Margin Sehat (>40%)'
                                  : (isModerateMargin
                                      ? 'Margin Cukup'
                                      : 'Margin Tipis (<20%)'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Keuntungan per Cup/Unit',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(profit),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: profit >= 0
                                        ? AppColors.profit
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Persentase Margin',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatPercent(marginPercent),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isHealthyMargin
                                        ? AppColors.profit
                                        : (isModerateMargin
                                            ? AppColors.cogs
                                            : AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Porsi Modal (COGS %)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatPercent(cogsPercent),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.cogs,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal',
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: Text(
                        widget.product == null
                            ? 'Simpan Produk'
                            : 'Perbarui Produk',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
