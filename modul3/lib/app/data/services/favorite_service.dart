import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:laundry_app/app/data/models/favorite_product_model.dart';

class FavoriteService extends GetxService {
  // Nama "box" (database) kita
  final String _boxName = 'favorites';

  // Variabel untuk menampung box yang sudah dibuka
  late Box<FavoriteProductModel> _favoriteBox;

  // Gunakan RxSet untuk menyimpan daftar ID produk yang jadi favorit.
  // 'Set' lebih cepat untuk cek "apakah item ini ada?"
  // 'Rx' (reaktif) agar UI bisa update otomatis.
  final RxSet<String> favoriteProductIds = <String>{}.obs;

  // Fungsi inisialisasi, akan kita panggil dari main.dart
  Future<FavoriteService> init() async {
    // 1. Buka box-nya. Hive akan membuat file 'favorites.hive' jika belum ada.
    _favoriteBox = await Hive.openBox<FavoriteProductModel>(_boxName);

    // 2. Muat semua ID favorit yang sudah tersimpan ke dalam RxSet
    _loadFavoriteIds();

    return this;
  }

  // Fungsi internal untuk memuat ID saat app pertama kali dibuka
  void _loadFavoriteIds() {
    // .keys mengembalikan semua kunci (kita akan pakai productId sebagai kunci)
    // .cast<String>() memastikan semua kuncinya adalah String
    favoriteProductIds.addAll(_favoriteBox.keys.cast<String>());
  }

  // --- Ini adalah fungsi utama yang akan dipanggil dari Controller ---

  // Fungsi untuk mengecek apakah sebuah produk sudah difavoritkan
  bool isFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }

  // Fungsi untuk menambah/menghapus favorit
  Future<void> toggleFavorite(FavoriteProductModel product) async {
    if (isFavorite(product.productId)) {
      // Jika SUDAH ada (favorit), maka HAPUS
      await _favoriteBox.delete(product.productId);
      favoriteProductIds.remove(product.productId);
    } else {
      // Jika BELUM ada (bukan favorit), maka TAMBAH
      // Kita gunakan productId sebagai 'key' agar mudah dicari
      await _favoriteBox.put(product.productId, product);
      favoriteProductIds.add(product.productId);
    }
  }

  // Fungsi untuk mengambil semua objek produk favorit (untuk halaman favorit)
  List<FavoriteProductModel> getAllFavorites() {
    // .values mengembalikan semua data/objek yang ada di dalam box
    return _favoriteBox.values.toList();
  }
}