import 'package:get/get.dart';

import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/favorites/bindings/favorites_binding.dart';
import '../modules/favorites/views/favorites_view.dart';
import '../modules/gps_map/bindings/gps_map_binding.dart';
import '../modules/gps_map/views/gps_map_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import 'app_routes.dart';

// <-- IMPORT PROFILE MODULE (BARU)

class AppPages {
  AppPages._();

  static const initial = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),

    // <-- TAMBAHAN ROUTE PROFILE (BARU)
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.BOOKING,
      page: () => const BookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.GPS_MAP,
      page: () => const GpsMapView(),
      binding: GpsMapBinding(),
    ),
  ];
}
