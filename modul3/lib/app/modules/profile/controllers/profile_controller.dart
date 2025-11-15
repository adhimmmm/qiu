import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/theme_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ThemeService _themeService = Get.find<ThemeService>();

  // Observable variables
  final isLoading = false.obs;
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  // =========================
  // THEME / DARK MODE
  // =========================
  bool get isDarkMode => _themeService.isDarkMode.value;

  void toggleTheme() {
    _themeService.toggleTheme();
  }

  // =========================
  // FETCH USER PROFILE
  // =========================
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // Ambil data dari table profiles
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        // Gabungkan data dari auth user dan profiles
        userProfile.value = UserProfileModel(
          id: user.id,
          email: user.email ?? '',
          fullName: response['full_name'],
          phone: response['phone'],
          avatarUrl: response['avatar_url'],
          role: response['role'] ?? 'visitor',
          createdAt: DateTime.parse(user.createdAt),
          updatedAt: response['updated_at'] != null
              ? DateTime.parse(response['updated_at'])
              : null,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah Anda yakin ingin keluar dari akun ini?',
      textConfirm: 'Logout',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      cancelTextColor: Get.theme.primaryColor,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // Tutup dialog
        isLoading.value = true;
        try {
          await _authService.signOut();
        } catch (e) {
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  // =========================
  // NAVIGATION
  // =========================
  void navigateToHome() {
    Get.offAllNamed(Routes.HOME);
  }

  void navigateToFavorites() {
    Get.toNamed(Routes.FAVORITES);
  }
}
