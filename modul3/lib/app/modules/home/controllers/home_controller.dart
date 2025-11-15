import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/laundry_service_model.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';

// FAVORIT
import '../../../data/models/favorite_product_model.dart';
import '../../../data/services/favorite_service.dart';

// ROLE
import '../../../data/models/user_role.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DioService _dioService = DioService();
  final FavoriteService favoriteService = Get.find<FavoriteService>();

  /// UI state
  final isLoading = false.obs;
  final services = <LaundryService>[].obs;
  final errorMessage = ''.obs;
  final currentIndex = 0.obs;

  /// Role User
  final userRole = UserRole.visitor.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRole();
    fetchServices();
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

    final result = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    if (result != null) {
      if (result['role'] == 'admin') {
        userRole.value = UserRole.admin;
      } else {
        userRole.value = UserRole.visitor;
      }
    }
  }

  // =========================
  // FETCH DATA (DIO + SUPABASE)
  // =========================
  Future<void> fetchServices() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. DIO API - tandai dengan fromApi: true
      final dioResult = await _dioService.fetchServices();
      List<LaundryService> dioServices = [];

      if (dioResult['success']) {
        final List<dynamic> dioData = dioResult['data'];

        // Mapping data dari DIO dan tandai fromApi = true
        dioServices = dioData.map((json) {
          if (json is LaundryService) {
            // Jika sudah LaundryService, copy dengan fromApi = true
            return json.copyWith(fromApi: true);
          } else {
            // Jika masih Map, parse dengan fromApi = true
            return LaundryService.fromJson(
              json as Map<String, dynamic>,
              fromApi: true,
            );
          }
        }).toList();

        print("🔥 JUMLAH DATA DARI DIO API: ${dioServices.length}");
      }

      // 2. SUPABASE - tandai dengan fromApi: false (default)
      print("🔥 CEK SUPABASE: MENGAMBIL DATA...");
      final supabaseList = await Supabase.instance.client
          .from('laundry_services')
          .select();

      print("🔥 HASIL RAW SUPABASE:");
      print(supabaseList);

      if (supabaseList is! List) {
        print("❌ ERROR: Supabase return bukan list");
      }

      if (supabaseList.isEmpty) {
        print("⚠️ WARNING: Supabase mengembalikan list KOSONG");
      }

      // Mapping data dari Supabase dengan fromApi = false (default)
      final supabaseServices = supabaseList
          .map<LaundryService>(
            (json) => LaundryService.fromJson(json, fromApi: false),
          )
          .toList();

      print("🔥 JUMLAH DATA DARI SUPABASE: ${supabaseServices.length}");

      // 3. Gabung dua sumber
      services.value = [...dioServices, ...supabaseServices];

      print("🔥 TOTAL GABUNGAN SERVICES: ${services.length}");
      print("🔥 DATA DARI API: ${services.where((s) => s.fromApi).length}");
      print(
        "🔥 DATA DARI SUPABASE: ${services.where((s) => !s.fromApi).length}",
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print("❌ FETCH ERROR: $e");
    } finally {
      isLoading.value = false;
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
  // CRUD SUPABASE (hanya untuk data Supabase)
  // =========================

  Future<bool> addService({
    required String name,
    required String subtitle,
    required String price,
    required String discount,
  }) async {
    try {
      await Supabase.instance.client.from('laundry_services').insert({
        'name': name,
        'subtitle': subtitle,
        'price': price,
        'discount': discount.isEmpty ? null : discount,
      });

      await fetchServices();
      Get.snackbar(
        'Berhasil',
        'Layanan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      print("❌ Add Error: $e");
      Get.snackbar(
        'Error',
        'Gagal menambahkan layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
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
    try {
      await Supabase.instance.client
          .from('laundry_services')
          .update({
            'name': name,
            'subtitle': subtitle,
            'price': price,
            'discount': discount.isEmpty ? null : discount,
          })
          .eq('id', id);

      await fetchServices();
      Get.snackbar(
        'Berhasil',
        'Layanan berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      print("❌ Update Error: $e");
      Get.snackbar(
        'Error',
        'Gagal mengupdate layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
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
      );
      return true;
    } catch (e) {
      print("❌ Delete Error: $e");
      Get.snackbar(
        'Error',
        'Gagal menghapus layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
