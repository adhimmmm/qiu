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

    bool isValidEmail(String email) {
  return GetUtils.isEmail(email);
}

  // ===============================
  //        LOGIN FUNCTION
  // ===============================
  Future<void> login() async {
  if (isLoading.value) return;

  final email = emailController.text.trim();
  final password = passwordController.text;


  // === VALIDASI EMAIL ===
  if (email.isEmpty) {
    Get.snackbar('Error', 'Email tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  if (!isValidEmail(email)) {
    Get.snackbar('Error', 'Format email tidak valid.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  // === VALIDASI PASSWORD ===
  if (password.isEmpty) {
    Get.snackbar('Error', 'Password tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  isLoading.value = true;
  FocusManager.instance.primaryFocus?.unfocus();

  try {
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
    }
  } catch (e) {
    Get.snackbar(
      'Error Koneksi',
      'Gagal terhubung ke server.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}

  // ===============================
  //        REGISTER FUNCTION
  // ===============================
  Future<void> register() async {
  if (isLoading.value) return;

  final email = emailController.text.trim();
  final password = passwordController.text;

  // === VALIDASI EMAIL ===
  if (email.isEmpty) {
    Get.snackbar('Error', 'Email tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  if (!isValidEmail(email)) {
    Get.snackbar('Error', 'Format email tidak valid.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  // === VALIDASI PASSWORD ===
  if (password.isEmpty) {
    Get.snackbar('Error', 'Password tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  if (password.length < 6) {
    Get.snackbar('Error', 'Password minimal 6 karakter.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white);
    return;
  }

  isLoading.value = true;
  FocusManager.instance.primaryFocus?.unfocus();

  try {
    // SIGN UP Supabase
    final response =
        await Supabase.instance.client.auth.signUp(email: email, password: password);

    final user = response.user;

    if (user != null) {
      // Simpan role default menggunakan UPSERT
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'role': 'visitor',
      });

      // Notifikasi
      Get.snackbar(
        'Success',
        'Akun berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );

      // Balik ke mode login
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
