import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
/// 🔔 NOTIFICATION GLOBAL CONFIG (WAJIB GLOBAL)
/// =====================================================

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // HARUS sama dengan AndroidManifest.xml
  'High Importance Notifications',
  description: 'Channel untuk notifikasi penting',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// =====================================================
/// 🔥 FCM BACKGROUND HANDLER (WAJIB ADA)
/// =====================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

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

  // 🔔 NOTIFICATION SERVICE
  await Get.putAsync<NotificationService>(() => NotificationService().init());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 FIREBASE INIT
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔔 REGISTER BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 🔔 CREATE HIGH IMPORTANCE CHANNEL (INI KUNCI HEADS-UP)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // 🔔 REQUEST PERMISSION (ANDROID 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // INIT SERVICES
  await initServices();

  // INITIAL ROUTE
  final auth = Get.find<AuthService>();
  final initialRoute = auth.isLoggedIn ? Routes.HOME : AppPages.initial;

  runApp(LaundryApp(initialRoute: initialRoute));
}

/// =====================================================
/// APP ROOT
/// =====================================================
class LaundryApp extends StatelessWidget {
  final String initialRoute;

  const LaundryApp({super.key, required this.initialRoute});

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
        return Overlay(initialEntries: [OverlayEntry(builder: (_) => child!)]);
      },
    );
  }
}
