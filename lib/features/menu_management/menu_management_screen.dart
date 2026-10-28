import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/utils/currency_formatter.dart';
import '../pos_cashier/providers/pos_provider.dart';
import 'product_form_dialog.dart';

class MenuManagementScreen extends ConsumerWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title & Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Manajemen Produk & HPP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola harga jual, harga pokok penjualan (HPP), dan stok',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => ProductFormDialog.show(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tambah Produk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search & Filter Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cari produk atau SKU...',
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 20, color: AppColors.textMuted),
                      ),
                      onChanged: (val) => notifier.setSearchQuery(val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Products Table or List
              Expanded(
                child: Card(
                  child: state.filteredProducts.isEmpty
                      ? const Center(
                          child: Text('Tidak ada produk yang sesuai kriteria'),
                        )
                      : isMobile
                          ? _buildMobileList(context, state, notifier)
                          : _buildDesktopTable(context, state, notifier),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
      BuildContext context, PosState state, PosNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(AppColors.surfaceSubtle),
          horizontalMargin: 20,
          columnSpacing: 24,
          columns: const [
            DataColumn(
                label: Text('PRODUK',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('SKU',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('HARGA JUAL',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('MODAL (HPP)',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('LABA/UNIT',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('MARGIN (%)',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('STOK',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('AKSI',
                    style: TextStyle(fontWeight: FontWeight.w700))),
          ],
          rows: state.filteredProducts.map((p) {
            final isHealthy = p.marginPercent >= 40;
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: p.imageUrl != null
                            ? Image.network(p.imageUrl!, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                    Icons.coffee,
                                    size: 20,
                                    color: AppColors.textDisabled))
                            : const Icon(Icons.coffee,
                                size: 20, color: AppColors.textDisabled),
                      ),
                      const SizedBox(width: 12),
                      Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                DataCell(Text(p.sku,
                    style: const TextStyle(color: AppColors.textMuted))),
                DataCell(Text(CurrencyFormatter.format(p.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary))),
                DataCell(Text(CurrencyFormatter.format(p.costPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.cogs))),
                DataCell(Text(CurrencyFormatter.format(p.profitPerUnit),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.profit))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHealthy
                          ? AppColors.profitLight
                          : AppColors.cogsLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      CurrencyFormatter.formatPercent(p.marginPercent),
                      style: TextStyle(
                        color: isHealthy ? AppColors.profit : AppColors.cogs,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('${p.stock}')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.primary),
                        onPressed: () =>
                            ProductFormDialog.show(context, product: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.danger),
                        onPressed: () => notifier.deleteProduct(p.id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(
      BuildContext context, PosState state, PosNotifier notifier) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.filteredProducts.length,
      separatorBuilder: (c, i) => const Divider(),
      itemBuilder: (context, index) {
        final p = state.filteredProducts[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(p.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Jual: ${CurrencyFormatter.format(p.price)} | Modal: ${CurrencyFormatter.format(p.costPrice)}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                'Laba: ${CurrencyFormatter.format(p.profitPerUnit)} (${CurrencyFormatter.formatPercent(p.marginPercent)})',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.profit),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => ProductFormDialog.show(context, product: p),
          ),
        );
      },
    );
  }
}
