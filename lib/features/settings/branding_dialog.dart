import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_logo.dart';
import 'branding_provider.dart';

class BrandingDialog extends ConsumerStatefulWidget {
  const BrandingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const BrandingDialog(),
    );
  }

  @override
  ConsumerState<BrandingDialog> createState() => _BrandingDialogState();
}

class _BrandingDialogState extends ConsumerState<BrandingDialog> {
  late TextEditingController _nameController;
  late TextEditingController _subtitleController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final branding = ref.read(storeBrandingProvider);
    _nameController = TextEditingController(text: branding.storeName);
    _subtitleController = TextEditingController(text: branding.storeSubtitle);
    _addressController = TextEditingController(text: branding.storeAddress);
    _phoneController = TextEditingController(text: branding.storePhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(storeBrandingProvider.notifier).updateInfo(
          name: _nameController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan White-Label & Logo Toko berhasil disimpan!'),
        backgroundColor: AppColors.profit,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(storeBrandingProvider);
    final notifier = ref.read(storeBrandingProvider.notifier);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.palette_outlined,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'White-Label & Logo Toko',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Sesuaikan logo dan identitas merek toko Anda. Tampil di aplikasi dan struk cetak.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Logo Uploader Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Live Brand Logo Preview
                    const BrandLogo(
                      size: 68,
                      borderRadius: 14,
                      padding: EdgeInsets.all(6),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Logo Aplikasi & Struk',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Format: PNG, JPG, atau foto dari iPhone / Android.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Upload Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final success =
                                      await notifier.pickCustomLogo();
                                  if (success && mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Logo baru berhasil di-upload!'),
                                        backgroundColor: AppColors.profit,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.upload_file_rounded,
                                    size: 15),
                                label: const Text('Ganti Logo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // Reset to Kasman default
                              if (branding.hasCustomLogo)
                                OutlinedButton(
                                  onPressed: () =>
                                      notifier.resetToDefaultLogo(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    side: const BorderSide(
                                        color: AppColors.borderStrong),
                                  ),
                                  child: const Text(
                                    'Reset Default',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Inputs
              const Text('Nama Toko / Brand',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Kopi Kasman, Cafe Senja...',
                ),
              ),

              const SizedBox(height: 14),
              const Text('Tagline / Subtitle Toko',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Modern Cloud Coffee & Eatery',
                ),
              ),

              const SizedBox(height: 14),
              const Text('Alamat Usaha (Tampil di Struk)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Jl. Boulevard Barat No. 88, Jakarta',
                ),
              ),

              const SizedBox(height: 14),
              const Text('Nomor Telepon / WhatsApp Toko',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: '0812-3456-7890',
                ),
              ),

              const SizedBox(height: 26),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
