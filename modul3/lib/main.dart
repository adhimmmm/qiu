import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/auth_service.dart';

// <-- BARU: Import model dan service untuk fitur favorit
import 'app/data/models/favorite_product_model.dart';
import 'app/data/services/favorite_service.dart';

// Fungsi untuk inisialisasi layanan asinkronus (Hive, Supabase, shared_preferences)
Future<void> initServices() async {
  // Inisialisasi Hive (Penyimpanan lokal terstruktur)
  await Hive.initFlutter();

  // <-- BARU: Daftarkan adapter Hive Anda
  // Ini harus dilakukan setelah initFlutter() dan sebelum membuka box
  Hive.registerAdapter(FavoriteProductModelAdapter());

  // Inisialisasi AuthService (Termasuk shared_preferences dan placeholder Supabase)
  // Get.putAsync digunakan untuk inisialisasi asinkronus dan dependency injection
  await Get.putAsync(() => AuthService().init());

  // <-- BARU: Inisialisasi FavoriteService Anda
  // Ini akan membuka 'favorites' box dan memuat data
  await Get.putAsync(() => FavoriteService().init());

  // Placeholder untuk inisialisasi Supabase
  // await Supabase.initialize(url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_SUPABASE_ANON_KEY');
}

void main() async {
  // Wajib dipanggil sebelum memanggil kode native/asinkronus (misalnya: Hive.initFlutter())
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi semua layanan penting
  await initServices();

  // Tentukan rute awal berdasarkan status autentikasi
  final authService = Get.find<AuthService>();
  final initialRoute =
      authService.isLoggedIn ? AppPages.routes[0].name : AppPages.initial;

  runApp(LaundryApp(initialRoute: initialRoute));
}

class LaundryApp extends StatelessWidget {
  final String initialRoute;

  const LaundryApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laundry App - HTTP Experiments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: initialRoute, // Gunakan rute yang sudah ditentukan
      getPages: AppPages.routes,
    );
  }
}