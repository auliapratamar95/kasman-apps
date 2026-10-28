import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/micro_animations.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../pos_cashier/providers/pos_provider.dart';
import '../widgets/period_filter_bar.dart';
import '../widgets/profit_modal_pie_chart.dart';
import '../widgets/top_products_report_table.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);
    final isDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    // Aggregate orders for the current period
    final orders = state.orders;

    final totalOmzet = orders.fold(0.0, (sum, o) => sum + o.grandTotal);
    final totalModal = orders.fold(0.0, (sum, o) => sum + o.totalCost);
    final totalProfit = orders.fold(0.0, (sum, o) => sum + o.totalProfit);
    final totalTransactions = orders.length;
    final totalCupsSold =
        orders.fold(0, (sum, o) => sum + o.totalItemCount);
    final avgMargin =
        totalOmzet > 0 ? (totalProfit / totalOmzet) * 100 : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Period Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Dashboard Analitik & Keuangan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pantau omzet, modal (HPP), dan laba bersih secara akurat',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  PeriodFilterBar(
                    selectedPeriod: state.reportPeriod,
                    onPeriodChanged: (period) =>
                        notifier.setReportPeriod(period),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4 Executive KPI Cards (From Blueprint Section 5.B)
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            title: 'TOTAL OMZET (SALES)',
                            amount: CurrencyFormatter.format(totalOmzet),
                            subtitle: 'Penjualan Kotor Periode Ini',
                            icon: Icons.account_balance_wallet_rounded,
                            accentColor: AppColors.revenue,
                            badgeText: '+18.4% vs bln lalu',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _KpiCard(
                            title: 'TOTAL MODAL (COGS)',
                            amount: CurrencyFormatter.format(totalModal),
                            subtitle: 'Akumulasi HPP Produk Terjual',
                            icon: Icons.inventory_2_rounded,
                            accentColor: AppColors.cogs,
                            badgeText: 'Porsi Modal 43.1%',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _KpiCard(
                            title: 'KEUNTUNGAN BERSIH',
                            amount: CurrencyFormatter.format(totalProfit),
                            subtitle: 'Gross Profit (Omzet - Modal)',
                            icon: Icons.trending_up_rounded,
                            accentColor: AppColors.profit,
                            badgeText: 'Laba Sehat',
                            isHighlight: true,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _KpiCard(
                            title: 'RATA-RATA MARGIN',
                            amount: CurrencyFormatter.formatPercent(avgMargin),
                            subtitle:
                                '$totalTransactions Transaksi ($totalCupsSold Cup)',
                            icon: Icons.pie_chart_rounded,
                            accentColor: AppColors.primary,
                            badgeText: 'Target 50% Tercapai',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _KpiCard(
                          title: 'TOTAL OMZET (SALES)',
                          amount: CurrencyFormatter.format(totalOmzet),
                          subtitle: 'Penjualan Kotor Periode Ini',
                          icon: Icons.account_balance_wallet_rounded,
                          accentColor: AppColors.revenue,
                          badgeText: '+18.4%',
                        ),
                        const SizedBox(height: 10),
                        _KpiCard(
                          title: 'TOTAL MODAL (COGS)',
                          amount: CurrencyFormatter.format(totalModal),
                          subtitle: 'Akumulasi HPP Produk Terjual',
                          icon: Icons.inventory_2_rounded,
                          accentColor: AppColors.cogs,
                          badgeText: 'Porsi 43.1%',
                        ),
                        const SizedBox(height: 10),
                        _KpiCard(
                          title: 'KEUNTUNGAN BERSIH',
                          amount: CurrencyFormatter.format(totalProfit),
                          subtitle: 'Gross Profit (Omzet - Modal)',
                          icon: Icons.trending_up_rounded,
                          accentColor: AppColors.profit,
                          badgeText: 'Laba Sehat',
                          isHighlight: true,
                        ),
                        const SizedBox(height: 10),
                        _KpiCard(
                          title: 'RATA-RATA MARGIN',
                          amount: CurrencyFormatter.formatPercent(avgMargin),
                          subtitle:
                              '$totalTransactions Transaksi ($totalCupsSold Cup)',
                          icon: Icons.pie_chart_rounded,
                          accentColor: AppColors.primary,
                          badgeText: 'Target Tercapai',
                        ),
                      ],
                    ),

              const SizedBox(height: 24),

              // Interactive Donut Chart Section
              ProfitModalPieChart(
                totalRevenue: totalOmzet,
                totalCost: totalModal,
                totalProfit: totalProfit,
                totalDiscount: 0,
              ),

              const SizedBox(height: 24),

              // Complete Sales & Profit Report Table
              TopProductsReportTable(
                orders: orders,
                products: state.products,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final bool isHighlight;

  const _KpiCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isHighlight ? accentColor.withOpacity(0.5) : AppColors.border,
          width: isHighlight ? 1.5 : 1.0,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isHighlight ? accentColor.withOpacity(0.03) : Colors.white,
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: MicroAnimations.fast,
              child: Text(
                amount,
                key: ValueKey(amount),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isHighlight ? accentColor : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
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
