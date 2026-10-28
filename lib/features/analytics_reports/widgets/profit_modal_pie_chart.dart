import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/micro_animations.dart';
import '../../../../shared/utils/currency_formatter.dart';

class ProfitModalPieChart extends StatefulWidget {
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double totalDiscount;

  const ProfitModalPieChart({
    super.key,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    this.totalDiscount = 0,
  });

  @override
  State<ProfitModalPieChart> createState() => _ProfitModalPieChartState();
}

class _ProfitModalPieChartState extends State<ProfitModalPieChart> {
  int _touchedIndex = -1;
  int _chartMode = 1; // 1: Komposisi Omzet, 2: Kategori Menu

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Toggle Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _chartMode == 1
                          ? 'Komposisi Omzet (Modal vs Laba)'
                          : 'Kontribusi Laba per Kategori',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Visualisasi pembagian keuangan real-time',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                // Toggle mode switch
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _ModeTab(
                        label: 'Modal vs Laba',
                        isSelected: _chartMode == 1,
                        onTap: () => setState(() => _chartMode = 1),
                      ),
                      _ModeTab(
                        label: 'Per Kategori',
                        isSelected: _chartMode == 2,
                        onTap: () => setState(() => _chartMode = 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Donut Chart with Center Hole text
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 65,
                      sections: _chartMode == 1
                          ? _buildFinancialSections()
                          : _buildCategorySections(),
                    ),
                    swapAnimationDuration: MicroAnimations.chartSweep,
                    swapAnimationCurve: Curves.easeInOutCubic,
                  ),

                  // Center Hole Text (From Blueprint Section 5.A)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Laba Bersih',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatCompact(widget.totalProfit),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.profit,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.profitLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                size: 10, color: AppColors.profit),
                            Text(
                              '+14.2%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.profit,
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

            const SizedBox(height: 20),

            // Legend indicators
            _chartMode == 1
                ? _buildFinancialLegend()
                : _buildCategoryLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildFinancialSections() {
    final profit = widget.totalProfit > 0 ? widget.totalProfit : 1.0;
    final cost = widget.totalCost > 0 ? widget.totalCost : 1.0;
    final discount = widget.totalDiscount > 0 ? widget.totalDiscount : 0.0;
    final total = profit + cost + discount;

    final profitPct = (profit / total) * 100;
    final costPct = (cost / total) * 100;
    final discountPct = (discount / total) * 100;

    return [
      // Profit (Emerald)
      PieChartSectionData(
        color: AppColors.profit,
        value: profit,
        title: '${profitPct.toStringAsFixed(1)}%',
        radius: _touchedIndex == 0 ? 32 : 24,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      // Cost / HPP (Amber)
      PieChartSectionData(
        color: AppColors.cogs,
        value: cost,
        title: '${costPct.toStringAsFixed(1)}%',
        radius: _touchedIndex == 1 ? 32 : 24,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      if (discount > 0)
        PieChartSectionData(
          color: AppColors.discount,
          value: discount,
          title: '${discountPct.toStringAsFixed(1)}%',
          radius: _touchedIndex == 2 ? 32 : 24,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
    ];
  }

  List<PieChartSectionData> _buildCategorySections() {
    // Proportional mock for category contribution (Kopi 55%, Non-Kopi 20%, Snack 25%)
    return [
      PieChartSectionData(
        color: AppColors.primary,
        value: 55,
        title: '55%',
        radius: _touchedIndex == 0 ? 32 : 24,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      PieChartSectionData(
        color: AppColors.teal,
        value: 20,
        title: '20%',
        radius: _touchedIndex == 1 ? 32 : 24,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      PieChartSectionData(
        color: AppColors.revenue,
        value: 25,
        title: '25%',
        radius: _touchedIndex == 2 ? 32 : 24,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ];
  }

  Widget _buildFinancialLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _LegendItem(
          color: AppColors.profit,
          label: 'Keuntungan Bersih',
          amount: CurrencyFormatter.format(widget.totalProfit),
        ),
        _LegendItem(
          color: AppColors.cogs,
          label: 'Total Modal (HPP)',
          amount: CurrencyFormatter.format(widget.totalCost),
        ),
        if (widget.totalDiscount > 0)
          _LegendItem(
            color: AppColors.discount,
            label: 'Diskon Promo',
            amount: CurrencyFormatter.format(widget.totalDiscount),
          ),
      ],
    );
  }

  Widget _buildCategoryLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _LegendItem(
          color: AppColors.primary,
          label: 'Signature Coffee',
          amount: '55% Kontribusi',
        ),
        _LegendItem(
          color: AppColors.teal,
          label: 'Non-Coffee',
          amount: '20% Kontribusi',
        ),
        _LegendItem(
          color: AppColors.revenue,
          label: 'Snack & Pastry',
          amount: '25% Kontribusi',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TactileScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
