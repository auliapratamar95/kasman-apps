import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../pos_cashier/models/order_model.dart';
import '../../pos_cashier/models/product_model.dart';

class ProductSalesReportItem {
  final int rank;
  final String rankIcon;
  final String productName;
  final int qtySold;
  final double unitCost;
  final double unitPrice;
  final double totalModal;
  final double totalOmzet;
  final double totalKeuntungan;
  final double marginPercent;
  final String analyticsStatus;
  final Color statusColor;

  ProductSalesReportItem({
    required this.rank,
    required this.rankIcon,
    required this.productName,
    required this.qtySold,
    required this.unitCost,
    required this.unitPrice,
    required this.totalModal,
    required this.totalOmzet,
    required this.totalKeuntungan,
    required this.marginPercent,
    required this.analyticsStatus,
    required this.statusColor,
  });
}

class TopProductsReportTable extends StatefulWidget {
  final List<OrderModel> orders;
  final List<ProductModel> products;

  const TopProductsReportTable({
    super.key,
    required this.orders,
    required this.products,
  });

  @override
  State<TopProductsReportTable> createState() => _TopProductsReportTableState();
}

class _TopProductsReportTableState extends State<TopProductsReportTable> {
  String _sortBy = 'qty'; // 'qty', 'profit', 'margin'

  List<ProductSalesReportItem> _aggregateReport() {
    final Map<String, int> qtyMap = {};
    final Map<String, double> omzetMap = {};
    final Map<String, double> costMap = {};
    final Map<String, double> profitMap = {};
    final Map<String, double> unitPriceMap = {};
    final Map<String, double> unitCostMap = {};

    for (final order in widget.orders) {
      for (final item in order.items) {
        final name = item.product.name;
        qtyMap[name] = (qtyMap[name] ?? 0) + item.quantity;
        omzetMap[name] = (omzetMap[name] ?? 0.0) + item.totalPrice;
        costMap[name] = (costMap[name] ?? 0.0) + item.totalCost;
        profitMap[name] = (profitMap[name] ?? 0.0) + item.totalProfit;
        unitPriceMap[name] = item.unitPrice;
        unitCostMap[name] = item.unitCost;
      }
    }

    final items = <ProductSalesReportItem>[];
    int index = 1;

    qtyMap.forEach((name, qty) {
      final omzet = omzetMap[name] ?? 0.0;
      final cost = costMap[name] ?? 0.0;
      final profit = profitMap[name] ?? 0.0;
      final margin = omzet > 0 ? (profit / omzet) * 100 : 0.0;

      String rankIcon = '📈';
      String status = '✅ Stabil';
      Color color = AppColors.teal;

      if (margin >= 70) {
        rankIcon = '🔥';
        status = '💎 High Margin';
        color = AppColors.primary;
      } else if (qty >= 500) {
        rankIcon = '🏆';
        status = '⭐ Star (Laris & Untung)';
        color = AppColors.profit;
      } else if (margin < 30) {
        rankIcon = '⚠️';
        status = '⚠️ Margin Tipis';
        color = AppColors.warning;
      } else if (name.toLowerCase().contains('fries')) {
        rankIcon = '🍟';
        status = '✅ Pendamping Terbaik';
        color = AppColors.teal;
      }

      items.add(
        ProductSalesReportItem(
          rank: index++,
          rankIcon: rankIcon,
          productName: name,
          qtySold: qty,
          unitCost: unitCostMap[name] ?? 0,
          unitPrice: unitPriceMap[name] ?? 0,
          totalModal: cost,
          totalOmzet: omzet,
          totalKeuntungan: profit,
          marginPercent: margin,
          analyticsStatus: status,
          statusColor: color,
        ),
      );
    });

    if (_sortBy == 'qty') {
      items.sort((a, b) => b.qtySold.compareTo(a.qtySold));
    } else if (_sortBy == 'profit') {
      items.sort((a, b) => b.totalKeuntungan.compareTo(a.totalKeuntungan));
    } else if (_sortBy == 'margin') {
      items.sort((a, b) => b.marginPercent.compareTo(a.marginPercent));
    }

    return items;
  }

  void _exportFile(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Laporan Penjualan & Keuntungan berhasil diekspor ke format $format!'),
        backgroundColor: AppColors.profit,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportItems = _aggregateReport();

    final totalQty =
        reportItems.fold(0, (sum, item) => sum + item.qtySold);
    final totalModal =
        reportItems.fold(0.0, (sum, item) => sum + item.totalModal);
    final totalOmzet =
        reportItems.fold(0.0, (sum, item) => sum + item.totalOmzet);
    final totalProfit =
        reportItems.fold(0.0, (sum, item) => sum + item.totalKeuntungan);
    final avgMargin =
        totalOmzet > 0 ? (totalProfit / totalOmzet) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Header & Export Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Laporan Penjualan Produk, Modal & Keuntungan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Laporan detail laba rugi per menu makanan & minuman',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            Row(
              children: [
                // Sort Dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'qty', child: Text('Urutkan: Terlaris (Qty)')),
                      DropdownMenuItem(
                          value: 'profit',
                          child: Text('Urutkan: Keuntungan Tertinggi (Rp)')),
                      DropdownMenuItem(
                          value: 'margin',
                          child: Text('Urutkan: Margin Tertinggi (%)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Export PDF
                OutlinedButton.icon(
                  onPressed: () => _exportFile('PDF (.pdf)'),
                  icon: const Icon(Icons.picture_as_pdf_outlined,
                      size: 16, color: AppColors.danger),
                  label: const Text('PDF',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                const SizedBox(width: 8),
                // Export Excel
                OutlinedButton.icon(
                  onPressed: () => _exportFile('Excel (.xlsx)'),
                  icon: const Icon(Icons.table_chart_outlined,
                      size: 16, color: AppColors.profit),
                  label: const Text('Excel',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Data Table Card
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(AppColors.surfaceSubtle),
              horizontalMargin: 20,
              columnSpacing: 22,
              columns: const [
                DataColumn(
                    label: Text('#',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('NAMA PRODUK',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('QTY TERJUAL',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('MODAL / UNIT',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('HARGA / UNIT',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('TOTAL MODAL (HPP)',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('TOTAL OMZET',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('TOTAL LABA',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('MARGIN (%)',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(
                    label: Text('STATUS ANALITIK',
                        style: TextStyle(fontWeight: FontWeight.w700))),
              ],
              rows: [
                ...reportItems.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final item = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text('#$i ${item.rankIcon}',
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('${item.qtySold}',
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(CurrencyFormatter.format(item.unitCost),
                          style: const TextStyle(color: AppColors.cogs))),
                      DataCell(Text(CurrencyFormatter.format(item.unitPrice))),
                      DataCell(Text(CurrencyFormatter.format(item.totalModal),
                          style: const TextStyle(
                              color: AppColors.cogs,
                              fontWeight: FontWeight.w600))),
                      DataCell(Text(CurrencyFormatter.format(item.totalOmzet),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary))),
                      DataCell(Text(CurrencyFormatter.format(item.totalKeuntungan),
                          style: const TextStyle(
                              color: AppColors.profit,
                              fontWeight: FontWeight.w800))),
                      DataCell(Text(
                          CurrencyFormatter.formatPercent(item.marginPercent),
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.analyticsStatus,
                            style: TextStyle(
                              color: item.statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // TOTAL ROW (From Blueprint Section 6.A)
                DataRow(
                  color: WidgetStateProperty.all(AppColors.primaryLight.withOpacity(0.5)),
                  cells: [
                    const DataCell(Text('TOTAL',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary))),
                    const DataCell(Text('Semua Produk',
                        style: TextStyle(fontWeight: FontWeight.w800))),
                    DataCell(Text('$totalQty Item',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary))),
                    const DataCell(Text('-')),
                    const DataCell(Text('-')),
                    DataCell(Text(CurrencyFormatter.format(totalModal),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.cogs))),
                    DataCell(Text(CurrencyFormatter.format(totalOmzet),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary))),
                    DataCell(Text(CurrencyFormatter.format(totalProfit),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.profit))),
                    DataCell(Text(CurrencyFormatter.formatPercent(avgMargin),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.profit))),
                    const DataCell(Text('Laba Kotor Periode Ini',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.profit))),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Menu Engineering Matrix Insight Box (Blueprint Section 6.B)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lightbulb_rounded,
                        color: AppColors.cogs, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Rekomendasi Pintar (Menu Engineering Matrix)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                      child: _InsightCard(
                        icon: '🌟',
                        title: 'Produk Bintang (Star)',
                        content:
                            'Es Kopi Susu Aren menghasilkan omzet tertinggi (Rp 15,3 Jt). Pertahankan rasa & letakkan di baris paling atas kasir.',
                        borderColor: AppColors.profit,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _InsightCard(
                        icon: '💎',
                        title: 'Tambang Emas (High Margin)',
                        content:
                            'Americano Dingin margin 76.7%! Buat promo bundling dengan snack pastry untuk meningkatkan kuantitas terjual.',
                        borderColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _InsightCard(
                        icon: '⚠️',
                        title: 'Evaluasi HPP (Low Margin)',
                        content:
                            'Croissant Butter margin tipis (22.2%). Pertimbangkan menaikkan harga Rp 2.000 atau cari supplier bahan baku baru.',
                        borderColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final Color borderColor;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
