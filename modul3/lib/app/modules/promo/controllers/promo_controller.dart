import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromoController extends GetxController {
  late final Map<String, dynamic> promoData;
  
  final RxBool isLoading = false.obs;
  final RxBool isPromoClaimable = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get data dari arguments atau default
    promoData = Get.arguments ?? _getDefaultPromoData();
    
    // Log untuk debug
    print('🎯 Promo Data: $promoData');
  }

  /// Default promo data jika tidak ada arguments
  Map<String, dynamic> _getDefaultPromoData() {
    return {
      'title': 'Promo Spesial Laundry',
      'subtitle': 'Penawaran terbatas hanya untuk Anda',
      'description':
          'Dapatkan diskon hingga 20% untuk semua layanan pencucian pakaian premium kami. Promo ini berlaku untuk pemesanan baru dan pelanggan setia.',
      'discount': '20',
      'image':
          'assets/images/promo_banner.png', // Update sesuai asset Anda
    };
  }

  /// Klaim promo (bisa integrate dengan backend)
  Future<void> claimPromo() async {
    try {
      isLoading.value = true;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      isPromoClaimable.value = false;
      
      // TODO: Integrate dengan backend untuk simpan promo claim
      // final result = await _promoService.claimPromo(promoData['id']);
      
      Get.snackbar(
        'Berhasil',
        'Promo berhasil diklaim! Silakan cek email Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengklaim promo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}