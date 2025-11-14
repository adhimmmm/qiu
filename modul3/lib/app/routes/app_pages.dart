import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';

// <-- 1. IMPORT FILE FAVORIT BARU ANDA
import '../modules/favorites/bindings/favorites_binding.dart';
import '../modules/favorites/views/favorites_view.dart';

import 'app_routes.dart'; // Pastikan ini mengimpor file di atas

class AppPages {
  AppPages._();

  // Tetapkan LOGIN sebagai rute inisial default
  static const initial = Routes.LOGIN;

  static final routes = [
    // Rute HOME (tetap)
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // Rute LOGIN (tetap)
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // <-- 2. TAMBAHKAN BLOK GetPage BARU DI SINI
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
  ];
}