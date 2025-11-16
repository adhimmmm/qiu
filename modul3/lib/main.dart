import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes/app_pages.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/theme_service.dart';
import 'app/data/services/favorite_service.dart';
import 'app/data/models/favorite_product_model.dart';

Future<void> initServices() async {
  // Inisialisasi Hive
  await Hive.initFlutter();

  // Register adapter Hive
  Hive.registerAdapter(FavoriteProductModelAdapter());

  // Inisialisasi AuthService
  await Get.putAsync(() => AuthService().init());

  // Inisialisasi FavoriteService
  await Get.putAsync(() => FavoriteService().init());

  // Inisialisasi ThemeService
  await Get.putAsync(() => ThemeService().init());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi semua services
  await initServices();

  // Tentukan initial route berdasarkan login Supabase
  final auth = Get.find<AuthService>();
  final initialRoute = auth.isLoggedIn
      ? AppPages.routes[0].name // halaman home kamu
      : AppPages.initial;       // halaman login

  runApp(LaundryApp(initialRoute: initialRoute));
}

class LaundryApp extends StatelessWidget {
  final String initialRoute;

  const LaundryApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false,

      // Tema (tidak diubah!)
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: Get.find<ThemeService>().themeMode,

      initialRoute: initialRoute,
      getPages: AppPages.routes,

      // FIX OVERLAY ERROR (SANGAT PENTING)
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => child!,
            ),
          ],
        );
      },
    );
  }
}
