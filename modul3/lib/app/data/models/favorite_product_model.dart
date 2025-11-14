import 'package:hive/hive.dart';

// Baris ini penting untuk menghubungkan ke file yang akan di-generate
part 'favorite_product_model.g.dart';

@HiveType(typeId: 1) // typeId harus unik untuk setiap model Hive
class FavoriteProductModel extends HiveObject {
  // Kita asumsikan produk punya ID unik (bisa int atau String)
  @HiveField(0)
  final String productId;

  // Simpan data lain yang perlu ditampilkan di halaman favorit
  // agar tidak perlu memanggil API lagi
  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String imageUrl;

  FavoriteProductModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}