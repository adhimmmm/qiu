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

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'Email and password must not be empty.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white);
        return;
      }
      
      final success = await _authService.signIn(email, password);

      if (success) {
        Get.offAllNamed(Routes.HOME); // Redirect ke Home
      } else {
        Get.snackbar('Login Failed', 'Invalid credentials or network error. Try user@test.com/password',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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