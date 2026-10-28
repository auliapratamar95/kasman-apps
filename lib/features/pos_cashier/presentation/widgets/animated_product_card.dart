import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/micro_animations.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../models/product_model.dart';

class AnimatedProductCard extends StatelessWidget {
  final ProductModel product;
  final int cartQuantity;
  final VoidCallback onAddToCart;
  final bool showCost;

  const AnimatedProductCard({
    super.key,
    required this.product,
    required this.cartQuantity,
    required this.onAddToCart,
    this.showCost = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasInCart = cartQuantity > 0;

    return TactileScaleTap(
      onTap: onAddToCart,
      scaleFactor: 0.95,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasInCart ? AppColors.primary : AppColors.border,
            width: hasInCart ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: hasInCart
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Container
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    color: AppColors.surfaceSubtle,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (product.imageUrl != null)
                          Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(
                                Icons.coffee_rounded,
                                size: 40,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.coffee_rounded,
                              size: 40,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        // Stock warning if low
                        if (product.stock <= 10)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sisa ${product.stock}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Product Details
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.sku,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textDisabled,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Pricing section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(product.price),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            if (showCost) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'Modal: ${CurrencyFormatter.format(product.costPrice)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.cogs,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${CurrencyFormatter.formatPercent(product.marginPercent)})',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.profit,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Pop-up Quantity Badge if in cart
            if (hasInCart)
              Positioned(
                top: 8,
                right: 8,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: MicroAnimations.fast,
                  curve: Curves.elasticOut,
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$cartQuantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
