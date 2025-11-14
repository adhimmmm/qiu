import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart'; // Import baru
import '../modules/login/views/login_view.dart'; // Import baru
import 'app_routes.dart';

class AppPages {
  AppPages._();

  // Tetapkan LOGIN sebagai rute inisial default
  static const initial = Routes.LOGIN; // Diubah dari Routes.HOME

  static final routes = [
    // Rute HOME (tetap)
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // Rute LOGIN (baru)
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
  ];
}