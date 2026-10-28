import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/micro_animations.dart';

class PeriodFilterBar extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const PeriodFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterTab(
              label: 'Hari Ini',
              id: 'today',
              isSelected: selectedPeriod == 'today',
              onTap: () => onPeriodChanged('today'),
            ),
            _FilterTab(
              label: 'Minggu Ini',
              id: 'week',
              isSelected: selectedPeriod == 'week',
              onTap: () => onPeriodChanged('week'),
            ),
            _FilterTab(
              label: 'Bulan Ini',
              id: 'month',
              isSelected: selectedPeriod == 'month',
              onTap: () => onPeriodChanged('month'),
            ),
            _FilterTab(
              label: 'Tahun Ini',
              id: 'year',
              isSelected: selectedPeriod == 'year',
              onTap: () => onPeriodChanged('year'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final String id;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.id,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TactileScaleTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MicroAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
