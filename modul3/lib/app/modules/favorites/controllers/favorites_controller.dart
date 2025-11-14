import 'package:get/get.dart';
import 'package:laundry_app/app/data/models/favorite_product_model.dart';
import 'package:laundry_app/app/data/services/favorite_service.dart';

class FavoritesController extends GetxController {
  // 1. Dapatkan service yang sudah kita buat (yang menyimpan data Hive)
  final FavoriteService favoriteService = Get.find<FavoriteService>();

  // 2. Siapkan list reaktif untuk menampung data favorit
  final favoritesList = <FavoriteProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 3. Muat data saat halaman dibuka
    loadFavorites();

    // 4. (PENTING) Buat 'listener'
    //    Jika user menghapus favorit dari Halaman Home,
    //    halaman ini akan otomatis update juga.
    favoriteService.favoriteProductIds.listen((_) {
      loadFavorites();
    });
  }

  // Fungsi untuk memuat data dari service ke list reaktif
  void loadFavorites() {
    favoritesList.value = favoriteService.getAllFavorites();
    print("Berhasil memuat ${favoritesList.length} item favorit");
  }

  // Fungsi untuk menghapus favorit (memanggil fungsi yang sama)
  // Kita hanya perlu 'pass-through' (meneruskan) data ke service
  void removeFavorite(FavoriteProductModel product) {
    // Service kita sudah pintar, memanggil 'toggle' pada
    // item yang sudah ada akan menghapusnya.
    favoriteService.toggleFavorite(product);
  }
}