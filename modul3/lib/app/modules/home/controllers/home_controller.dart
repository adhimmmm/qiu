import 'package:get/get.dart';
import '../../../data/models/laundry_service_model.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';

// <-- 1. IMPORT BARU UNTUK FITUR FAVORIT
import '../../../data/models/favorite_product_model.dart'; // <-- Penting
import '../../../data/services/favorite_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DioService _dioService = DioService();

  // <-- 2. INISIALISASI SERVICE FAVORIT
  final FavoriteService favoriteService = Get.find<FavoriteService>();

  final isLoading = false.obs;
  final services = <LaundryService>[].obs;
  final errorMessage = ''.obs;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('🏠 Home Controller initialized');
    fetchServices();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  //fungsi logout
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

  Future<void> fetchServices() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dioService.fetchServices();

      if (result['success']) {
        services.value = result['data'];
        print('✅ Loaded ${services.length} services');
      } else {
        errorMessage.value = result['error'];
        Get.snackbar(
          'Error',
          'Failed to load services: ${result['error']}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- [ FUNGSI BARU UNTUK FITUR FAVORIT ] ---

  /// Fungsi [isFavorite]
  bool isFavorite(String productId) {
    // Membaca dari RxSet di service
    return favoriteService.favoriteProductIds.contains(productId);
  }

  /// Fungsi [toggleFavorite]
  /// Dipanggil dari tombol 'onPressed' di view.
  void toggleFavorite(LaundryService product) {
    
    // --- [ INI ADALAH PERBAIKANNYA ] ---
    
    // 1. Kita ubah 'price' (String) dari LaundryService menjadi 'double'.
    //    Kita gunakan tryParse untuk keamanan jika data 'price' tidak valid.
    //    (Catatan: Ini akan gagal jika 'price' berisi "Rp " atau ".")
    final double priceAsDouble = double.tryParse(product.price) ?? 0.0;

    // 2. Buat objek FavoriteProductModel dengan 4 field yang benar
    final favoriteData = FavoriteProductModel(
      productId: product.id,   // <- Diambil dari LaundryService
      name: product.name,        // <- Diambil dari LaundryService
      price: priceAsDouble,      // <- Hasil konversi kita
      imageUrl: '',              // <- Kita beri string kosong karena tidak ada data
    );

    // 3. Panggil service untuk menyimpan/menghapus
    favoriteService.toggleFavorite(favoriteData);
  }
}