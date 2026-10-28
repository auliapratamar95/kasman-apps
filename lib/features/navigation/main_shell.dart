import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/micro_animations.dart';
import '../analytics_reports/presentation/dashboard_screen.dart';
import '../auth/cashier_pin_lock.dart';
import '../auth/google_login_screen.dart';
import '../menu_management/menu_management_screen.dart';
import '../pos_cashier/presentation/pos_screen.dart';
import '../pos_cashier/providers/pos_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _isLoggedIn = true;

  final List<Widget> _screens = const [
    PosScreen(),
    DashboardScreen(),
    MenuManagementScreen(),
  ];

  void _onNavigationSelect(int index) {
    final state = ref.read(posProvider);

    // If cashier tries to access Dashboard or Menu Management, require Owner PIN
    if (index > 0 && state.userRole == 'CASHIER') {
      CashierPinLockDialog.show(
        context,
        title: 'Buka Dashboard Owner (PIN: 1234)',
        targetRole: 'OWNER',
      ).then((unlocked) {
        if (unlocked == true) {
          setState(() => _currentIndex = index);
        }
      });
      return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return GoogleLoginScreen(
        onLoginSuccess: () => setState(() => _isLoggedIn = true),
      );
    }

    final state = ref.watch(posProvider);
    final isDesktop = ResponsiveLayout.isTabletOrDesktop(context);
    final isOwner = state.userRole == 'OWNER';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 800;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand & Store Info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.teal],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Kopi Kasir Modern',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (!isCompact) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.profitLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Vercel PWA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.profit,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (!isCompact)
                            const Text(
                              'Cabang Boulevard Barat • Shift Pagi',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Staff & Role Switcher Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Role Badge Toggle
                      TactileScaleTap(
                        onTap: () {
                          if (isOwner) {
                            ref.read(posProvider.notifier).setUserRole('CASHIER');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Mode Kasir Aktif. Akses Owner sekarang terkunci PIN.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() => _currentIndex = 0);
                          } else {
                            CashierPinLockDialog.show(
                              context,
                              title: 'Masuk Mode Owner (PIN: 1234)',
                              targetRole: 'OWNER',
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOwner
                                ? AppColors.primaryLight
                                : AppColors.cogsLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isOwner
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.cogs.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOwner
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                                size: 16,
                                color: isOwner
                                    ? AppColors.primary
                                    : AppColors.cogs,
                              ),
                              if (!isCompact) ...[
                                const SizedBox(width: 6),
                                Text(
                                  isOwner ? 'Mode Owner' : 'Mode Kasir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isOwner
                                        ? AppColors.primary
                                        : AppColors.cogs,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 14,
                                  color: isOwner
                                      ? AppColors.primary
                                      : AppColors.cogs,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Cashier profile info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              state.activeCashier.isNotEmpty
                                  ? state.activeCashier[0]
                                  : 'B',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!isCompact && isDesktop) ...[
                            const SizedBox(width: 6),
                            Text(
                              state.activeCashier,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(width: 8),

                      // Quick Lock / Shift Change Button
                      IconButton(
                        tooltip: 'Ganti Shift Kasir (Kunci Layar)',
                        icon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          CashierPinLockDialog.show(
                            context,
                            title: 'Kunci Layar Shift Kasir',
                            targetRole: state.userRole,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Row(
        children: [
          // Desktop Left Sidebar Navigation (Blueprint Section 7.A)
          if (isDesktop)
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _SidebarItem(
                    icon: Icons.point_of_sale_rounded,
                    label: 'Kasir POS',
                    badge: state.cart.isNotEmpty
                        ? '${state.cartTotalQuantity}'
                        : null,
                    isSelected: _currentIndex == 0,
                    onTap: () => _onNavigationSelect(0),
                  ),
                  _SidebarItem(
                    icon: Icons.insights_rounded,
                    label: 'Dashboard Analitik',
                    isLocked: !isOwner,
                    isSelected: _currentIndex == 1,
                    onTap: () => _onNavigationSelect(1),
                  ),
                  _SidebarItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'Produk & HPP',
                    isLocked: !isOwner,
                    isSelected: _currentIndex == 2,
                    onTap: () => _onNavigationSelect(2),
                  ),
                  const Spacer(),
                  const Divider(),
                  _SidebarItem(
                    icon: Icons.logout_rounded,
                    label: 'Keluar',
                    color: AppColors.danger,
                    isSelected: false,
                    onTap: () => setState(() => _isLoggedIn = false),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Main Screen Area
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      // Mobile Bottom Navigation Bar (Blueprint Section 7.B)
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => _onNavigationSelect(idx),
              backgroundColor: Colors.white,
              elevation: 8,
              destinations: [
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: state.cart.isNotEmpty,
                    label: Text('${state.cartTotalQuantity}'),
                    child: const Icon(Icons.point_of_sale_rounded),
                  ),
                  label: 'Kasir',
                ),
                NavigationDestination(
                  icon: Icon(
                    isOwner ? Icons.insights_rounded : Icons.lock_outline,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(
                    isOwner ? Icons.inventory_2_rounded : Icons.lock_outline,
                  ),
                  label: 'Menu HPP',
                ),
              ],
            ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isSelected;
  final bool isLocked;
  final Color? color;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.isSelected,
    this.isLocked = false,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? (isSelected ? AppColors.primary : AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TactileScaleTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: activeColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: activeColor,
                  ),
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock_rounded, size: 14, color: AppColors.textDisabled)
              else if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
