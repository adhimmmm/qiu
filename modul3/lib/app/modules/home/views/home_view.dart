import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/auth_service.dart';

// Import model 'LaundryService' diperlukan untuk type safety di _buildServiceList
import '../../../data/models/laundry_service_model.dart';

// <-- 1. IMPORT BARU UNTUK NAVIGASI HALAMAN
import '../../../routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  // --- PALET WARNA BARU ---
  static const Color primaryTeal = Color(0xFF1E5B53);
  static const Color accentTeal = Color(0xFF388E3C);
  static const Color lightBackground = Color(0xFFF0F0F0);

  // --- DATA (Konstanta untuk Keringkasan Kode) ---
  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Laundry', 'icon': Icons.local_laundry_service, 'color': primaryTeal},
    {'name': 'Setrika', 'icon': Icons.iron, 'color': primaryTeal},
    {'name': 'Express', 'icon': Icons.flash_on, 'color': primaryTeal},
    {'name': 'Sepatu', 'icon': Icons.sports_soccer, 'color': primaryTeal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        // Menghilangkan AppBar bawaan untuk fokus pada header kustom
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: lightBackground,
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: primaryTeal));
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState();
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSectionTitle('Service Categories'),
                _buildCategories(),
                const SizedBox(height: 20),
                _buildSectionTitle('Popular Services', onTap: (context) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('View All popular services!'),
                      backgroundColor: accentTeal,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                // Kita cast ke List<LaundryService> untuk keamanan
                _buildServiceList(controller.services
                    .take(3)
                    .toList()
                    .cast<LaundryService>()),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      // Menggunakan Bottom Navigation Bar (TETAP UTUH, 4 TOMBOL)
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGET UTAMA ---

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${controller.errorMessage.value}',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchServices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Header yang menggabungkan Location, Search, dan Hero Banner (diadaptasi dari gambar)
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: lightBackground,
      child: Column(
        children: [
          // 1. Top Bar & Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: primaryTeal, size: 24),
                    SizedBox(width: 8),
                    Text('Malang, ID',
                        style: TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    // --- Tombol Notifikasi (Asli) ---
                    const Icon(Icons.notifications_none,
                        color: primaryTeal, size: 24),
                    
                    // <-- 2. TOMBOL FAVORIT (BARU) DITAMBAHKAN DI SINI -->
                    const SizedBox(width: 10), // Jarak
                    GestureDetector(
                      onTap: () {
                        // Pindah ke Halaman Favorit
                        Get.toNamed(Routes.FAVORITES);
                      },
                      child: const Icon(
                        Icons.favorite_border, // Ikon Hati (Outline)
                        color: primaryTeal,
                        size: 24,
                      ),
                    ),
                    // <-- AKHIR DARI TOMBOL FAVORIT -->

                    const SizedBox(width: 10), // Jarak
                    
                    // --- Tombol Profil (Asli) ---
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300,
                        ),
                        // Placeholder untuk gambar profil
                        child: const Icon(Icons.person, color: primaryTeal),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4)
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: primaryTeal),
                  hintText: 'Search for a service...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 15),
                ),
              ),
            ),
          ),
          // 3. Hero/Banner Area (diadaptasi)
          Container(
            height: 180,
            width: double.infinity,
            margin:
                const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: primaryTeal.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LAUNDRY SOLUTION,',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                Text('ONE TAP AWAY!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                // Placeholder untuk tombol aksi/explore
                Chip(
                    label: Text('Pesan Sekarang',
                        style: TextStyle(
                            color: primaryTeal, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // <<< FUNGSI BARU UNTUK MENAMPILKAN DIALOG LOGOUT
  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah Anda yakin ingin keluar dari akun ini?',
      confirmTextColor: Colors.white,
      cancelTextColor: primaryTeal,
      buttonColor: primaryTeal,
      onConfirm: () {
        Get.back(); // Tutup dialog sebelum logout
        controller.logout(); // Panggil fungsi logout dari controller
      },
      onCancel: () {
        // Hanya menutup dialog jika dibatalkan
        Get.back();
      },
      textConfirm: 'Logout',
      textCancel: 'Batal',
      radius: 15.0,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: primaryTeal),
      middleTextStyle: const TextStyle(color: Colors.black87),
    );
  }

  // --- WIDGET LIST KATEGORI (Clean Card Style) ---

  Widget _buildSectionTitle(String title, {Function(BuildContext)? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTeal,
            ),
          ),
          if (onTap != null)
            Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () => onTap(context),
                  child: Text(
                    'View all >',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.tealAccent.shade400,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      // Padding horizontal disamakan dengan padding title
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Penting agar bisa di-scroll oleh SingleChildScrollView
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 3, // Rasio lebar/tinggi untuk card yang lebar dan pendek
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
            // Lebar akan diatur oleh GridView
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: primaryTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryTeal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right,
                    color: Colors.grey, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET SERVICE POPULER (Best Seller diubah namanya) ---

  // Saya ubah List<dynamic> menjadi List<LaundryService> agar lebih aman
  Widget _buildServiceList(List<LaundryService> services) {
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Tidak ada layanan yang tersedia.'),
      );
    }

    // Warna diubah agar lebih kontras dengan tema baru
    final colors = [
      const Color(0xFFF9AA33), // Oranye
      const Color(0xFF2C3E50), // Biru gelap
      const Color(0xFF27AE60), // Hijau
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: colors[index % colors.length].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Stack sangat penting agar kita bisa menumpuk tombol favorit
            child: Stack(
              children: [
                // --- KODE ASLI ANDA (AMAN) ---
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_laundry_service,
                          color: Colors.white, size: 30),
                      const SizedBox(height: 8),
                      Text(service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(service.subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                      Text(service.price,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                
                // --- KODE DISKON ASLI ANDA (AMAN) ---
                if (service.discount != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      // Kita tambahkan '!' karena kita sudah cek null
                      child: Text(service.discount!, 
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                // --- [ KODE FAVORIT (SUDAH DIPERBAIKI) ] ---
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Obx(() {
                    
                    // Menggunakan 'service.id' yang BENAR
                    final isFav = controller.isFavorite(service.id); 
                    
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        // Memanggil controller dengan 'service'
                        controller.toggleFavorite(service);
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BOTTOM NAVIGASI (KEMBALI KE 4 TOMBOL ASLI) ---

  Widget _buildBottomNav() {
    // Tombol kembali ke 4 item, tidak ada 'Favorit' di sini
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'index': 0},
      {'icon': Icons.calendar_today_outlined, 'label': 'Booking', 'index': 1},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat', 'index': 2},
      {'icon': Icons.person_outline, 'label': 'Account', 'index': 3},
    ];

    //kondisi kalau rolenya admin

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final index = item['index'] as int;

          return Builder(
            // Builder Wajib untuk konteks ScaffoldMessenger/Snackbar
            builder: (context) {
              return Obx(() {
                final isActive = controller.currentIndex.value == index;

                return GestureDetector(
                  // Logika onTap kembali seperti semula
                  onTap: () {
                    controller.changeIndex(index);

                    if (index != 0) {
                      // Menggunakan ScaffoldMessenger di dalam Builder untuk solusi aman
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Halaman ${item['label']} (Coming Soon)'),
                          backgroundColor: primaryTeal,
                          duration: const Duration(milliseconds: 1000),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      // Gaya aktif item yang menarik
                      color: isActive
                          ? primaryTeal.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isActive ? primaryTeal : Colors.grey.shade600,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive ? primaryTeal : Colors.grey.shade600,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          );
        }).toList(),
      ),
    );
  }
}