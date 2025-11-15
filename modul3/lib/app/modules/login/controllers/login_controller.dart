import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  // Tambahan untuk mode Login / Register
  final isRegisterMode = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // 🔄 Toggle Login <-> Register
  void toggleRegisterMode() {
    isRegisterMode.value = !isRegisterMode.value;
  }

  // ===============================
  //        LOGIN FUNCTION
  // ===============================
  Future<void> login() async {
    if (isLoading.value) return;

    isLoading.value = true;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Email dan password harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final success = await _authService.signIn(email, password);

      if (success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Login Gagal',
          'Email atau password salah.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error Koneksi',
        'Gagal terhubung ke server.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  // ===============================
  //        REGISTER FUNCTION
  // ===============================
  Future<void> register() async {
    if (isLoading.value) return;

    isLoading.value = true;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Email dan password harus diisi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // 1️⃣ Daftarkan akun baru ke Supabase
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        // 2️⃣ Set role default = visitor ke table profiles
        await Supabase.instance.client
            .from('profiles')
            .update({'role': 'visitor'})
            .eq('id', user.id);

        Get.snackbar(
          'Success',
          'Akun berhasil dibuat sebagai Visitor!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );

        // 3️⃣ Kembali ke mode login
        isRegisterMode.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
