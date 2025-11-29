import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/favorites/bindings/favorites_binding.dart';
import '../modules/favorites/views/favorites_view.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/views/location_view.dart';
import '../modules/location/bindings/network_location_binding.dart';
import '../modules/location/views/network_location_view.dart';
import '../modules/location/bindings/gps_location_binding.dart';
import '../modules/location/views/gps_location_view.dart';

// <-- IMPORT PROFILE MODULE (BARU)
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';

import 'app_routes.dart';

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
      name: Routes.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: Routes.NETWORK_LOCATION,
      page: () => const NetworkLocationView(),
      binding: NetworkLocationBinding(),
    ),
    GetPage(
      name: Routes.GPS_LOCATION,
      page: () => const GpsLocationView(),
      binding: GpsLocationBinding(),
    ),
  ];
}
