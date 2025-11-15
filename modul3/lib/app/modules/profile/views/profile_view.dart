import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                controller.isDarkMode
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_round,
              ),
              onPressed: controller.toggleTheme,
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.userProfile.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }

        final profile = controller.userProfile.value;
        if (profile == null) {
          return const Center(child: Text('Gagal memuat profil'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildAvatarSection(context, profile),
              const SizedBox(height: 30),
              _buildProfileInfoCard(context, profile),
              const SizedBox(height: 20),
              _buildMenuOptions(context),
              const SizedBox(height: 20),
              _buildLogoutButton(context),
              const SizedBox(height: 120),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAvatarSection(BuildContext context, profile) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border.all(color: Theme.of(context).primaryColor, width: 3),
          ),
          child: Center(
            child: profile.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.avatarUrl!,
                      width: 114,
                      height: 114,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(context, profile);
                      },
                    ),
                  )
                : _buildInitialsAvatar(context, profile),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          profile.displayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: profile.role == 'admin'
                ? Colors.orange.shade100
                : Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.role == 'admin' ? '👑 Admin' : '👤 Visitor',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: profile.role == 'admin'
                  ? Colors.orange.shade800
                  : Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, profile) {
    return Text(
      profile.initials,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            context,
            icon: Icons.email,
            label: 'Email',
            value: profile.email,
          ),
          const Divider(height: 30),
          _buildInfoRow(
            context,
            icon: Icons.person,
            label: 'Nama Lengkap',
            value: profile.fullName ?? 'Belum diisi',
          ),
          const Divider(height: 30),
          _buildInfoRow(
            context,
            icon: Icons.phone,
            label: 'No. Telepon',
            value: profile.phone ?? 'Belum diisi',
          ),
          const Divider(height: 30),
          _buildInfoRow(
            context,
            icon: Icons.calendar_today,
            label: 'Bergabung Sejak',
            value: profile.createdAt != null
                ? _formatDate(profile.createdAt!)
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            context,
            icon: Icons.favorite,
            title: 'Favorit Saya',
            subtitle: 'Lihat layanan favorit',
            onTap: controller.navigateToFavorites,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            context,
            icon: Icons.settings,
            title: 'Pengaturan',
            subtitle: 'Atur preferensi aplikasi (Coming Soon)',
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Fitur ini akan segera hadir!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Theme.of(context).primaryColor,
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuTile(
            context,
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'Pusat bantuan & FAQ (Coming Soon)',
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Fitur ini akan segera hadir!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Theme.of(context).primaryColor,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.logout,
          icon: const Icon(Icons.logout),
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
        color: Theme.of(context).cardColor,
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
          final isActive = index == 3; // Profile always active

          return GestureDetector(
            onTap: () {
              if (index == 0) {
                // Home
                controller.navigateToHome();
              } else if (index == 1) {
                // Booking
                Get.snackbar(
                  'Coming Soon',
                  'Halaman Booking akan segera hadir!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Theme.of(context).primaryColor,
                  colorText: Colors.white,
                  duration: const Duration(milliseconds: 1500),
                );
              } else if (index == 2) {
                // Chat
                Get.snackbar(
                  'Coming Soon',
                  'Halaman Chat akan segera hadir!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Theme.of(context).primaryColor,
                  colorText: Colors.white,
                  duration: const Duration(milliseconds: 1500),
                );
              }
              // index 3 (Account) - sudah di halaman ini
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
                        : (Theme.of(context).brightness == Brightness.dark
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
                          : (Theme.of(context).brightness == Brightness.dark
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
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
