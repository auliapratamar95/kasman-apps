import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/micro_animations.dart';
import '../pos_cashier/providers/pos_provider.dart';

class CashierPinLockDialog extends ConsumerStatefulWidget {
  final String title;
  final String targetRole; // e.g., 'OWNER' or 'CASHIER'
  final VoidCallback? onSuccess;

  const CashierPinLockDialog({
    super.key,
    this.title = 'Masukkan PIN Owner (Default: 1234)',
    this.targetRole = 'OWNER',
    this.onSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Masukkan PIN Akses (Default: 1234)',
    String targetRole = 'OWNER',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CashierPinLockDialog(
        title: title,
        targetRole: targetRole,
      ),
    );
  }

  @override
  ConsumerState<CashierPinLockDialog> createState() => _CashierPinLockDialogState();
}

class _CashierPinLockDialogState extends ConsumerState<CashierPinLockDialog> {
  String _pin = '';
  final String _correctPin = '1234';
  bool _isError = false;

  void _onKeyPress(String key) {
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
        _isError = false;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() {
    if (_pin == _correctPin) {
      ref.read(posProvider.notifier).setUserRole(widget.targetRole);
      ref.read(posProvider.notifier).setOwnerLocked(false);
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isError = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isError
                  ? 'PIN salah! Silakan coba lagi (PIN Default: 1234)'
                  : 'Gunakan PIN 4 digit untuk membuka akses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _isError ? AppColors.danger : AppColors.textMuted,
                fontWeight: _isError ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),
            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? (_isError ? AppColors.danger : AppColors.primary)
                        : AppColors.border,
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            // Numeric Keypad Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                  (val) => _KeypadButton(
                    label: val,
                    onTap: () => _onKeyPress(val),
                  ),
                ),
                // Quick Clear
                TactileScaleTap(
                  onTap: () => setState(() => _pin = ''),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                _KeypadButton(
                  label: '0',
                  onTap: () => _onKeyPress('0'),
                ),
                TactileScaleTap(
                  onTap: _onBackspace,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeypadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactileScaleTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
