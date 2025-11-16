import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';

import '../../../data/models/laundry_service_model.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';

// FAVORIT
import '../../../data/models/favorite_product_model.dart';
import '../../../data/services/favorite_service.dart';

// ROLE
import '../../../data/models/user_role.dart';

// THEME
import '../../../data/services/theme_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DioService _dioService = DioService();
  final FavoriteService favoriteService = Get.find<FavoriteService>();
  final ThemeService _themeService = Get.find<ThemeService>();

  /// UI state
  final isLoading = false.obs;
  final services = <LaundryService>[].obs;
  final errorMessage = ''.obs;
  final currentIndex = 0.obs;

  /// Role User
  final userRole = UserRole.visitor.obs;

  /// Offline Mode
  final isOfflineMode = false.obs;
  late Box<dynamic> _cacheBox;

  @override
  void onInit() {
    super.onInit();
    _initCache();
    fetchUserRole();
    fetchServices();
  }

  // =========================
  // CACHE INITIALIZATION
  // =========================
  Future<void> _initCache() async {
    try {
      _cacheBox = await Hive.openBox('services_cache');
      print("📦 Cache box opened successfully");
    } catch (e) {
      print("❌ Cache initialization error: $e");
    }
  }

  // =========================
  // THEME / DARK MODE
  // =========================
  bool get isDarkMode => _themeService.isDarkMode.value;

  void toggleTheme() {
    _themeService.toggleTheme();
  }

  // =========================
  // NAVBAR
  // =========================
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // FETCH USER ROLE
  // =========================
  Future<void> fetchUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final result = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(Duration(seconds: 5));

      if (result != null) {
        if (result['role'] == 'admin') {
          userRole.value = UserRole.admin;
        } else {
          userRole.value = UserRole.visitor;
        }
      }
    } catch (e) {
      print("⚠️ Fetch role error (using default visitor): $e");
      userRole.value = UserRole.visitor;
    }
  }

  // =========================
  // FETCH DATA (WITH OFFLINE SUPPORT)
  // =========================
  Future<void> fetchServices() async {
    print("═══════════════════════════════════════");
    print("🚀 FETCH SERVICES STARTED");
    print("═══════════════════════════════════════");

    // 1. LOAD CACHE FIRST (INSTANT UI)
    await _loadFromCache();

    // 2. TRY FETCH FROM NETWORK
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Fetch dari kedua sumber
      final dioServices = await _fetchFromDio();
      final supabaseServices = await _fetchFromSupabase();

      // Gabung data
      final allServices = [...dioServices, ...supabaseServices];

      if (allServices.isNotEmpty) {
        services.value = allServices;
        await _saveToCache(allServices);
        isOfflineMode.value = false;

        print("═══════════════════════════════════════");
        print("✅ ONLINE MODE - Data updated");
        print("🔥 Total: ${allServices.length} services");
        print("🔵 From API: ${dioServices.length}");
        print("🟢 From Supabase: ${supabaseServices.length}");
        print("═══════════════════════════════════════");
      } else {
        // Kalau tidak ada data baru, tetap pakai cache
        if (services.isEmpty) {
          errorMessage.value = "No data available";
        }
        isOfflineMode.value = true;
      }
    } catch (e) {
      print("❌ FETCH ERROR: $e");
      errorMessage.value = "Using cached data";
      isOfflineMode.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOAD FROM CACHE
  // =========================
  Future<void> _loadFromCache() async {
    try {
      final cached = _cacheBox.get('services_list');

      if (cached != null && cached is List && cached.isNotEmpty) {
        services.value = cached
            .map(
              (json) => LaundryService.fromJson(
                Map<String, dynamic>.from(json),
                fromApi: json['fromApi'] ?? false,
              ),
            )
            .toList();

        print("📦 CACHE LOADED: ${services.length} services");
        isOfflineMode.value = true;
      } else {
        print("📦 Cache is empty");
      }
    } catch (e) {
      print("❌ Cache load error: $e");
    }
  }

  // =========================
  // SAVE TO CACHE
  // =========================
  Future<void> _saveToCache(List<LaundryService> data) async {
    try {
      final jsonList = data.map((s) => s.toJson()).toList();
      await _cacheBox.put('services_list', jsonList);
      print("💾 CACHE SAVED: ${data.length} services");
    } catch (e) {
      print("❌ Cache save error: $e");
    }
  }

  // =========================
  // FETCH FROM DIO (WITH TIMEOUT)
  // =========================
  Future<List<LaundryService>> _fetchFromDio() async {
    try {
      print("🔵 Fetching from DIO API...");

      final dioResult = await _dioService.fetchServices().timeout(
        Duration(seconds: 8),
      );

      if (dioResult['success']) {
        final List<dynamic> dioData = dioResult['data'];

        final services = dioData.map((json) {
          if (json is LaundryService) {
            return json.copyWith(fromApi: true);
          } else {
            return LaundryService.fromJson(
              json as Map<String, dynamic>,
              fromApi: true,
            );
          }
        }).toList();

        print("✅ DIO SUCCESS: ${services.length} services");
        return services;
      } else {
        print("⚠️ DIO failed: ${dioResult['error']}");
        return [];
      }
    } catch (e) {
      print("⚠️ DIO timeout/error: $e");
      return [];
    }
  }

  // =========================
  // FETCH FROM SUPABASE (WITH TIMEOUT)
  // =========================
  Future<List<LaundryService>> _fetchFromSupabase() async {
    try {
      print("🟢 Fetching from SUPABASE...");

      final supabaseList = await Supabase.instance.client
          .from('laundry_services')
          .select()
          .timeout(Duration(seconds: 8));

      if (supabaseList is List && supabaseList.isNotEmpty) {
        final services = supabaseList
            .map<LaundryService>(
              (json) => LaundryService.fromJson(json, fromApi: false),
            )
            .toList();

        print("✅ SUPABASE SUCCESS: ${services.length} services");
        return services;
      } else {
        print("⚠️ SUPABASE returned empty list");
        return [];
      }
    } catch (e) {
      print("⚠️ SUPABASE timeout/error: $e");
      return [];
    }
  }

  // =========================
  // FAVORITE
  // =========================
  bool isFavorite(String productId) {
    return favoriteService.favoriteProductIds.contains(productId);
  }

  void toggleFavorite(LaundryService product) {
    final double priceAsDouble = double.tryParse(product.price) ?? 0.0;

    final favoriteData = FavoriteProductModel(
      productId: product.id,
      name: product.name,
      price: priceAsDouble,
      imageUrl: '',
    );

    favoriteService.toggleFavorite(favoriteData);
  }

  // =========================
  // CRUD SUPABASE
  // =========================

  Future<bool> addService({
    required String name,
    required String subtitle,
    required String price,
    required String discount,
  }) async {
    // Validasi input kosong
    if (name.trim().isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Nama layanan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (subtitle.trim().isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Subtitle tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (price.trim().isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Harga tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validasi harga harus berupa angka
    final priceNumber = double.tryParse(price.trim());
    if (priceNumber == null) {
      Get.snackbar(
        'Validasi Error',
        'Harga harus berupa angka',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (priceNumber <= 0) {
      Get.snackbar(
        'Validasi Error',
        'Harga harus lebih besar dari 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validasi diskon harus berupa angka (jika diisi)
    if (discount.trim().isNotEmpty) {
      final discountNumber = double.tryParse(discount.trim());
      if (discountNumber == null) {
        Get.snackbar(
          'Validasi Error',
          'Diskon harus berupa angka',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      if (discountNumber < 0) {
        Get.snackbar(
          'Validasi Error',
          'Diskon tidak boleh negatif',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    }

    try {
      await Supabase.instance.client.from('laundry_services').insert({
        'name': name.trim(),
        'subtitle': subtitle.trim(),
        'price': price.trim(),
        'discount': discount.trim().isEmpty ? null : discount.trim(),
      });

      await fetchServices();

      Get.snackbar(
        'Berhasil',
        'Layanan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print("❌ Add Error: $e");

      Get.snackbar(
        'Error',
        'Gagal menambahkan layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> updateService({
    required String id,
    required String name,
    required String subtitle,
    required String price,
    required String discount,
  }) async {
    // Validasi input kosong
    if (name.trim().isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Nama layanan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (subtitle.trim().isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Subtitle tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (price.trim().isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Harga tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validasi harga harus berupa angka
    final priceNumber = double.tryParse(price.trim());
    if (priceNumber == null) {
      Get.snackbar(
        'Validasi Error',
        'Harga harus berupa angka',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (priceNumber <= 0) {
      Get.snackbar(
        'Validasi Error',
        'Harga harus lebih besar dari 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validasi diskon harus berupa angka (jika diisi)
    if (discount.trim().isNotEmpty) {
      final discountNumber = double.tryParse(discount.trim());
      if (discountNumber == null) {
        Get.snackbar(
          'Validasi Error',
          'Diskon harus berupa angka',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      if (discountNumber < 0) {
        Get.snackbar(
          'Validasi Error',
          'Diskon tidak boleh negatif',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    }

    try {
      await Supabase.instance.client
          .from('laundry_services')
          .update({
            'name': name.trim(),
            'subtitle': subtitle.trim(),
            'price': price.trim(),
            'discount': discount.trim().isEmpty ? null : discount.trim(),
          })
          .eq('id', id);

      await fetchServices();

      Get.snackbar(
        'Berhasil',
        'Layanan berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print("❌ Update Error: $e");
      Get.snackbar(
        'Error',
        'Gagal mengupdate layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      await Supabase.instance.client
          .from('laundry_services')
          .delete()
          .eq('id', id);

      await fetchServices();

      Get.snackbar(
        'Berhasil',
        'Layanan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print("❌ Delete Error: $e");
      Get.snackbar(
        'Error',
        'Gagal menghapus layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
