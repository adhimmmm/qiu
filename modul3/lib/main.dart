import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/auth_service.dart';

// Import model dan service untuk fitur favorit
import 'app/data/models/favorite_product_model.dart';
import 'app/data/services/favorite_service.dart';

// Import theme service untuk dark mode
import 'app/data/services/theme_service.dart';

// Fungsi untuk inisialisasi layanan asinkronus
Future<void> initServices() async {
  // Inisialisasi Hive
  await Hive.initFlutter();

  // Daftarkan adapter Hive
  Hive.registerAdapter(FavoriteProductModelAdapter());

  // Inisialisasi AuthService
  await Get.putAsync(() => AuthService().init());

  // Inisialisasi FavoriteService
  await Get.putAsync(() => FavoriteService().init());

  // Inisialisasi ThemeService (Dark Mode)
  await Get.putAsync(() => ThemeService().init());

  // Placeholder untuk inisialisasi Supabase
  // await Supabase.initialize(url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_SUPABASE_ANON_KEY');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi semua layanan penting
  await initServices();

  // Tentukan rute awal berdasarkan status autentikasi
  final authService = Get.find<AuthService>();
  final initialRoute = authService.isLoggedIn
      ? AppPages.routes[0].name
      : AppPages.initial;

  runApp(LaundryApp(initialRoute: initialRoute));
}

class LaundryApp extends StatelessWidget {
  final String initialRoute;

  const LaundryApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: Get.find<ThemeService>().themeMode,
      
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}