import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/laundry_service_model.dart';
import '../../../data/models/user_role.dart';
import '../../../routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // --- PALET WARNA BARU ---
  static const Color primaryTeal = Color(0xFF1E5B53);
  static const Color accentTeal = Color(0xFF388E3C);
  static const Color lightBackground = Color(0xFFF0F0F0);

  // --- DATA (Konstanta untuk Keringkasan Kode) ---
  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Laundry',
      'icon': Icons.local_laundry_service,
      'color': primaryTeal,
    },
    {'name': 'Setrika', 'icon': Icons.iron, 'color': primaryTeal},
    {'name': 'Express', 'icon': Icons.flash_on, 'color': primaryTeal},
    {'name': 'Sepatu', 'icon': Icons.sports_soccer, 'color': primaryTeal},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: lightBackground,
        ),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: controller.userRole.value == UserRole.admin
            ? FloatingActionButton(
                backgroundColor: primaryTeal,
                onPressed: () => _showAddServiceDialog(context),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: primaryTeal),
        );
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
            _buildSectionTitle(
              'Popular Services',
              onTap: (context) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('View All popular services!'),
                    backgroundColor: accentTeal,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildServiceList(
              controller.services.toList().cast<LaundryService>(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: ${controller.errorMessage.value}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchServices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: lightBackground,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: primaryTeal, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Malang, ID',
                      style: TextStyle(
                        color: primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: primaryTeal,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.FAVORITES),
                      child: const Icon(
                        Icons.favorite_border,
                        color: primaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(Icons.person, color: primaryTeal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                    blurRadius: 4,
                  ),
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
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryTeal.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LAUNDRY SOLUTION,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'ONE TAP AWAY!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Chip(
                  label: Text(
                    'Pesan Sekarang',
                    style: TextStyle(
                      color: primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah Anda yakin ingin keluar dari akun ini?',
      confirmTextColor: Colors.white,
      cancelTextColor: primaryTeal,
      buttonColor: primaryTeal,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
      onCancel: () => Get.back(),
      textConfirm: 'Logout',
      textCancel: 'Batal',
      radius: 15.0,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: primaryTeal,
      ),
      middleTextStyle: const TextStyle(color: Colors.black87),
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 3,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
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
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceList(List<LaundryService> services) {
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Tidak ada layanan yang tersedia.'),
      );
    }

    final colors = [
      const Color(0xFFF9AA33),
      const Color(0xFF2C3E50),
      const Color(0xFF27AE60),
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_laundry_service,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        service.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (service.discount != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.discount!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // FAVORITE BUTTON
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Obx(() {
                    final isFav = controller.isFavorite(service.id);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => controller.toggleFavorite(service),
                    );
                  }),
                ),

                // ADMIN ACTIONS: edit + delete
                // Hanya muncul untuk admin DAN data dari Supabase (bukan dari API)
                if (controller.userRole.value == UserRole.admin &&
                    !service.fromApi)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showEditServiceDialog(context, service),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showDeleteConfirm(context, service),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Badge untuk membedakan sumber data (opsional, hanya untuk admin)
                if (controller.userRole.value == UserRole.admin)
                  Positioned(
                    bottom: 40,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: service.fromApi
                            ? Colors.blue.shade700.withOpacity(0.9)
                            : Colors.green.shade700.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.fromApi ? 'API' : 'DB',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'index': 0},
      {'icon': Icons.calendar_today_outlined, 'label': 'Booking', 'index': 1},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat', 'index': 2},
      {'icon': Icons.person_outline, 'label': 'Account', 'index': 3},
    ];

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
            builder: (context) {
              return Obx(() {
                final isActive = controller.currentIndex.value == index;

                return GestureDetector(
                  onTap: () {
                    controller.changeIndex(index);

                    if (index != 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Halaman ${item['label']} (Coming Soon)',
                          ),
                          backgroundColor: primaryTeal,
                          duration: const Duration(milliseconds: 1000),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
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
                            color: isActive
                                ? primaryTeal
                                : Colors.grey.shade600,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
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

  // -----------------------
  // Dialog: Add Service
  // -----------------------
  void _showAddServiceDialog(BuildContext context) {
    final nameC = TextEditingController();
    final subtitleC = TextEditingController();
    final priceC = TextEditingController();
    final discountC = TextEditingController();

    Get.defaultDialog(
      title: "Tambah Layanan",
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subtitleC,
              decoration: const InputDecoration(labelText: "Subtitle"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceC,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountC,
              decoration: const InputDecoration(
                labelText: "Discount (optional)",
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      textConfirm: "Tambah",
      textCancel: "Batal",
      onConfirm: () async {
        final ok = await controller.addService(
          name: nameC.text.trim(),
          subtitle: subtitleC.text.trim(),
          price: priceC.text.trim(),
          discount: discountC.text.trim(),
        );
        if (ok) {
          Get.back();
        }
      },
    );
  }

  // -----------------------
  // Dialog: Edit Service
  // -----------------------
  void _showEditServiceDialog(BuildContext context, LaundryService service) {
    final nameC = TextEditingController(text: service.name);
    final subtitleC = TextEditingController(text: service.subtitle);
    final priceC = TextEditingController(text: service.price);
    final discountC = TextEditingController(text: service.discount ?? '');

    Get.defaultDialog(
      title: "Edit Layanan",
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subtitleC,
              decoration: const InputDecoration(labelText: "Subtitle"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceC,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountC,
              decoration: const InputDecoration(
                labelText: "Discount (optional)",
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      onConfirm: () async {
        final ok = await controller.updateService(
          id: service.id,
          name: nameC.text.trim(),
          subtitle: subtitleC.text.trim(),
          price: priceC.text.trim(),
          discount: discountC.text.trim(),
        );
        if (ok) {
          Get.back();
        }
      },
    );
  }

  // -----------------------
  // Dialog: Delete Confirm
  // -----------------------
  void _showDeleteConfirm(BuildContext context, LaundryService service) {
    Get.defaultDialog(
      title: "Hapus Layanan?",
      middleText:
          "Apakah Anda yakin ingin menghapus layanan \"${service.name}\"?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      onConfirm: () async {
        final ok = await controller.deleteService(service.id);
        if (ok) {
          Get.back();
        }
      },
      onCancel: () => Get.back(),
    );
  }
}
