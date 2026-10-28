import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/branding_provider.dart';

class BrandLogo extends ConsumerWidget {
  final double size;
  final double borderRadius;
  final bool showBackground;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const BrandLogo({
    super.key,
    this.size = 36,
    this.borderRadius = 10,
    this.showBackground = true,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(storeBrandingProvider);

    Widget imageWidget;
    if (branding.hasCustomLogo) {
      imageWidget = Image.memory(
        branding.logoBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(branding.defaultLogoAsset, fit: BoxFit.contain),
      );
    } else {
      imageWidget = Image.asset(
        branding.defaultLogoAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.point_of_sale_rounded,
          color: AppColors.primary,
        ),
      );
    }

    if (!showBackground) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: imageWidget,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: imageWidget,
      ),
    );
  }
}
