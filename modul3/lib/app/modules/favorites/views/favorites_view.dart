import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({Key? key}) : super(key: key);

  // Kita pinjam warna dari HomeView
  static const Color primaryTeal = Color(0xFF1E5B53);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        // Tambahkan ini untuk memastikan icon back berwarna putih
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        // Jika list di controller-nya kosong, tampilkan pesan
        if (controller.favoritesList.isEmpty) {
          return const Center(
            child: Text(
              'Anda belum menambahkan item favorit.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Jika ada data, tampilkan sebagai ListView
        return ListView.builder(
          itemCount: controller.favoritesList.length,
          itemBuilder: (context, index) {
            final product = controller.favoritesList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                // Karena imageUrl kita kosong, kita pakai ikon
                leading: CircleAvatar(
                  backgroundColor: primaryTeal.withOpacity(0.1),
                  child: const Icon(
                    Icons.local_laundry_service,
                    color: primaryTeal,
                  ),
                ),

                // Tampilkan nama dan harga dari database Hive
                title: Text(product.name),
                subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),

                // Tombol Hapus (Remove)
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline, // Ikon Hapus
                    color: Colors.red,
                  ),
                  onPressed: () {
                    // Panggil fungsi controller untuk menghapus
                    controller.removeFavorite(product);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
