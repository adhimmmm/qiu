import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// ROUTES
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

// SERVICES
import 'app/data/services/auth_service.dart';
import 'app/data/services/theme_service.dart';
import 'app/data/services/favorite_service.dart';
import 'app/data/services/notification_service.dart';

// MODELS
import 'app/data/models/favorite_product_model.dart';

/// =====================================================
/// INIT ALL SERVICES
/// =====================================================
Future<void> initServices() async {
  // HIVE
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteProductModelAdapter());

  // AUTH
  await Get.putAsync<AuthService>(() => AuthService().init());

  // FAVORITE
  await Get.putAsync<FavoriteService>(() => FavoriteService().init());

  // THEME
  await Get.putAsync<ThemeService>(() => ThemeService().init());

  // 🔔 NOTIFICATION (MODUL 6)
  await Get.putAsync<NotificationService>(
    () => NotificationService().init(),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 FIREBASE INIT (WAJIB SEBELUM FCM)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // INIT SERVICES
  await initServices();

  // INITIAL ROUTE
  final auth = Get.find<AuthService>();
  final initialRoute =
      auth.isLoggedIn ? Routes.HOME : AppPages.initial;

  runApp(LaundryApp(initialRoute: initialRoute));
}

/// =====================================================
/// APP ROOT
/// =====================================================
class LaundryApp extends StatelessWidget {
  final String initialRoute;

  const LaundryApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false,

      // THEME
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: Get.find<ThemeService>().themeMode,

      // ROUTING
      initialRoute: initialRoute,
      getPages: AppPages.routes,

      // FIX OVERLAY ERROR
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (_) => child!),
          ],
        );
      },
    );
  }
}
