import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class StoreBrandingState {
  final String storeName;
  final String storeSubtitle;
  final String storeAddress;
  final String storePhone;
  final Uint8List? logoBytes; // Uploaded custom logo bytes (PNG/JPG)
  final String defaultLogoAsset;

  const StoreBrandingState({
    this.storeName = 'Kasman POS',
    this.storeSubtitle = 'Aplikasi Kasir Cloud Multi-Platform',
    this.storeAddress = 'Jl. Boulevard Barat No. 88, Jakarta',
    this.storePhone = '0812-3456-7890',
    this.logoBytes,
    this.defaultLogoAsset = 'assets/images/kasman_logo.png',
  });

  bool get hasCustomLogo => logoBytes != null && logoBytes!.isNotEmpty;

  StoreBrandingState copyWith({
    String? storeName,
    String? storeSubtitle,
    String? storeAddress,
    String? storePhone,
    Uint8List? logoBytes,
    bool clearCustomLogo = false,
  }) {
    return StoreBrandingState(
      storeName: storeName ?? this.storeName,
      storeSubtitle: storeSubtitle ?? this.storeSubtitle,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      logoBytes: clearCustomLogo ? null : (logoBytes ?? this.logoBytes),
      defaultLogoAsset: defaultLogoAsset,
    );
  }
}

class StoreBrandingNotifier extends Notifier<StoreBrandingState> {
  final ImagePicker _picker = ImagePicker();

  @override
  StoreBrandingState build() {
    return const StoreBrandingState();
  }

  void updateInfo({
    String? name,
    String? subtitle,
    String? address,
    String? phone,
  }) {
    state = state.copyWith(
      storeName: name,
      storeSubtitle: subtitle,
      storeAddress: address,
      storePhone: phone,
    );
  }

  Future<bool> pickCustomLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        state = state.copyWith(logoBytes: bytes);
        return true;
      }
    } catch (e) {
      debugPrint('Error picking custom logo: $e');
    }
    return false;
  }

  void resetToDefaultLogo() {
    state = state.copyWith(clearCustomLogo: true);
  }
}

final storeBrandingProvider =
    NotifierProvider<StoreBrandingNotifier, StoreBrandingState>(
        StoreBrandingNotifier.new);
