import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/micro_animations.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../models/cart_item_model.dart';
import '../providers/pos_provider.dart';
import '../../menu_management/product_form_dialog.dart';
import 'widgets/animated_product_card.dart';
import 'widgets/cart_panel.dart';
import 'widgets/payment_modal.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isDesktop
            ? const _DesktopPosLayout()
            : const _MobilePosLayout(),
      ),
      bottomNavigationBar: isDesktop ? null : const _MobileStickyCartBar(),
    );
  }
}

class _DesktopPosLayout extends ConsumerWidget {
  const _DesktopPosLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left & Center Area: Catalog & Categories (65% width)
        Expanded(
          flex: 65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _PosHeaderBar(),
                SizedBox(height: 14),
                _CategoryFilterBar(),
                SizedBox(height: 14),
                Expanded(child: _ProductGrid()),
              ],
            ),
          ),
        ),

        // Right Area: Fixed Cart & Checkout Panel (35% width)
        Expanded(
          flex: 35,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
            child: CartPanel(
              onCheckout: () => PaymentModal.show(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobilePosLayout extends ConsumerWidget {
  const _MobilePosLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PosHeaderBar(),
          SizedBox(height: 12),
          _CategoryFilterBar(),
          SizedBox(height: 12),
          Expanded(child: _ProductGrid()),
        ],
      ),
    );
  }
}

class _PosHeaderBar extends ConsumerWidget {
  const _PosHeaderBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);

    return Row(
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama produk, kopi, atau SKU...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 20),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => notifier.setSearchQuery(''),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (val) => notifier.setSearchQuery(val),
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterBar extends ConsumerWidget {
  const _CategoryFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          final isSelected = state.selectedCategoryId == cat.id;

          return TactileScaleTap(
            onTap: () => notifier.selectCategory(cat.id),
            child: AnimatedContainer(
              duration: MicroAnimations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);
    final isOwner = state.userRole == 'OWNER';

    final products = state.filteredProducts;

    if (products.isEmpty) {
      final isCatalogEmpty = state.products.isEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_business_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCatalogEmpty
                    ? 'Katalog Produk Masih Bersih'
                    : 'Tidak ada produk yang cocok dengan pencarian',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isCatalogEmpty
                    ? 'Mulai tambahkan produk makanan / minuman Anda secara manual'
                    : 'Coba ubah kata kunci pencarian atau filter kategori Anda',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              if (isCatalogEmpty) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ProductFormDialog.show(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Produk Pertama'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic crossAxisCount based on available width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1100) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.82,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            final cartItem = state.cart.firstWhere(
              (item) => item.product.id == product.id,
              orElse: () => CartItemModel(product: product, quantity: 0),
            );

            return AnimatedProductCard(
              product: product,
              cartQuantity: cartItem.quantity,
              showCost: isOwner,
              onAddToCart: () => notifier.addToCart(product),
            );
          },
        );
      },
    );
  }
}

class _MobileStickyCartBar extends ConsumerWidget {
  const _MobileStickyCartBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);

    if (state.cart.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: TactileScaleTap(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: CartPanel(
                  isBottomSheet: true,
                  onCheckout: () {
                    Navigator.pop(context);
                    PaymentModal.show(context);
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${state.cartTotalQuantity} Item',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(state.cartGrandTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 14),
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
