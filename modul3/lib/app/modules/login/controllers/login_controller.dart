import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  // Mengambil instance AuthService yang sudah diinisialisasi di main.dart
  final AuthService _authService = Get.find<AuthService>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (isLoading.value) return;

    isLoading.value = true;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // 1. Pengecekan Input Lokal (Sinkronus)
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error', 
          'Email dan password harus diisi.',
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.shade400, 
          colorText: Colors.white
        );
        isLoading.value = false; // <<< KUNCI ANTI-FREEZE SINKRONUS
        return;
      }
      
      // 2. Pengecekan Database (Asinkronus)
      final success = await _authService.signIn(email, password);

      if (success) {
        // ✅ Sukses: Redirect ke Home
        Get.offAllNamed(Routes.HOME); 
      } else {
        // ❌ Gagal Kredensial: Tampilkan pesan & RESET LOADING
        Get.snackbar(
          'Login Gagal', 
          'Email atau password salah. Coba user@test.com/password',
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.shade400, 
          colorText: Colors.white,
          duration: const Duration(seconds: 4)
        );
        isLoading.value = false; // <<< KUNCI ANTI-FREEZE ASINKRONUS (Gagal Login)
      }
    } catch (e) {
      // ⚠️ Gagal Jaringan/Lainnya: Tampilkan pesan & RESET LOADING
      Get.snackbar(
        'Error Koneksi', 
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.red.shade700, 
        colorText: Colors.white,
        duration: const Duration(seconds: 5) 
      );
      isLoading.value = false; // <<< KUNCI ANTI-FREEZE ASINKRONUS (Gagal Jaringan)
    } 
    // BLOK finally YANG RUMIT TELAH DIHAPUS.
  }

  void goToRegister() {
    Get.snackbar('Info', 'Registration is handled via AuthService (Supabase).',
        snackPosition: SnackPosition.BOTTOM);
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}