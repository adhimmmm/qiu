import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/laundry_service_model.dart';
import '../../../data/models/user_role.dart';
import '../../../routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Kategori data tetap konstan
  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Laundry', 'icon': Icons.local_laundry_service},
    {'name': 'Setrika', 'icon': Icons.iron},
    {'name': 'Express', 'icon': Icons.flash_on},
    {'name': 'Sepatu', 'icon': Icons.sports_soccer},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: controller.userRole.value == UserRole.admin
            ? FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
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
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Obx(() {
              return _buildServiceList(
                controller.services.toList().cast<LaundryService>(),
              );
            }),
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Malang, ID',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    // TOGGLE DARK MODE
                    GestureDetector(
                      onTap: () => controller.toggleTheme(),
                      child: Obx(() {
                        return Icon(
                          controller.isDarkMode
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_round,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.FAVORITES),
                      child: Icon(
                        Icons.favorite_border,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.PROFILE),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                        ),
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                  hintText: 'Search for a service...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 15),
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
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LAUNDRY SOLUTION,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'ONE TAP AWAY!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Chip(
                  label: Text(
                    'Pesan Sekarang',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
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

  Widget _buildSectionTitle(String title, {Function(BuildContext)? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Get.theme.primaryColor,
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
                      color: Get.theme.colorScheme.secondary,
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
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Get.theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
              ),
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
                    color: Get.theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Get.theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Get.theme.brightness == Brightness.dark
                      ? Colors.grey.shade600
                      : Colors.grey,
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Tidak ada layanan yang tersedia.',
          style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
        ),
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
        physics: const BouncingScrollPhysics(),
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
              clipBehavior: Clip.none,
              children: [
                // 🔷 CARD CONTENT
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
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

                // 🔴 BADGE DISKON (POJOK KANAN ATAS)
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

                // 💚 FAVORITE BUTTON (POJOK KANAN BAWAH)
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

                // 🟦 LABEL API / DB (SEDIKIT DI ATAS FAVORITE)
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

                // 🟨 EDIT + DELETE (CENTER TOP)
                if (controller.userRole.value == UserRole.admin &&
                    !service.fromApi)
                  Positioned(
                    top: 5, // dinaikkan sedikit agar NEW floating style
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // EDIT
                        GestureDetector(
                          onTap: () => _showEditServiceDialog(context, service),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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
                        // DELETE
                        GestureDetector(
                          onTap: () => _showDeleteConfirm(context, service),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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
        color: Get.theme.cardColor,
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
                    if(index == 1){
                      Get.toNamed(Routes.BOOKING);
                    } else if (index == 3) {
                      Get.toNamed(Routes.PROFILE);
                    } else if (index != 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Halaman ${item['label']} (Coming Soon)',
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
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
                          ? Theme.of(context).primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : (Get.theme.brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : (Get.theme.brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600),
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

  void _showAddServiceDialog(BuildContext context) {
    final nameC = TextEditingController();
    final subtitleC = TextEditingController();
    final priceC = TextEditingController();
    final discountC = TextEditingController();

    Get.defaultDialog(
      title: "Tambah Layanan",
      backgroundColor: Theme.of(context).cardColor,
      titleStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subtitleC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Subtitle",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Discount (optional)",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      textConfirm: "Tambah",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      cancelTextColor: Theme.of(context).primaryColor,
      buttonColor: Theme.of(context).primaryColor,
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

  void _showEditServiceDialog(BuildContext context, LaundryService service) {
    final nameC = TextEditingController(text: service.name);
    final subtitleC = TextEditingController(text: service.subtitle);
    final priceC = TextEditingController(text: service.price);
    final discountC = TextEditingController(text: service.discount ?? '');

    Get.defaultDialog(
      title: "Edit Layanan",
      backgroundColor: Theme.of(context).cardColor,
      titleStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subtitleC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Subtitle",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountC,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: "Discount (optional)",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      cancelTextColor: Theme.of(context).primaryColor,
      buttonColor: Theme.of(context).primaryColor,
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

  void _showDeleteConfirm(BuildContext context, LaundryService service) {
    Get.defaultDialog(
      title: "Hapus Layanan?",
      backgroundColor: Theme.of(context).cardColor,
      titleStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          "Apakah Anda yakin ingin menghapus layanan \"${service.name}\"?",
      middleTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      cancelTextColor: Theme.of(context).primaryColor,
      buttonColor: Theme.of(context).primaryColor,
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
