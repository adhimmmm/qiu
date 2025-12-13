import 'dart:developer';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  /// ===============================
  /// INIT SERVICE (DIPANGGIL DI main.dart)
  /// ===============================
  Future<NotificationService> init() async {
    await _requestPermission();
    await _initLocalNotification();
    await _printFcmToken();
    log('🚀 NotificationService INIT START');

    _listenForegroundMessage();
    _listenNotificationClick();
    _listenTokenRefresh();
    log('✅ NotificationService INIT DONE');
    return this;
  }

  /// ===============================
  /// REQUEST PERMISSION (ANDROID 13+)
  /// ===============================
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  /// ===============================
  /// INIT LOCAL NOTIFICATION + CHANNEL
  /// ===============================
  Future<void> _initLocalNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _handleNavigation(response.payload!);
        }
      },
    );

    /// 🔥 CHANNEL DENGAN CUSTOM SOUND
    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      'promo_channel', // ⚠️ JANGAN GANTI TANPA UNINSTALL
      'Promo Notification',
      description: 'Notifikasi promo laundry',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('promo_sound'),
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// ===============================
  /// CETAK FCM TOKEN (WAJIB UNTUK MODUL)
  /// ===============================
 Future<void> _printFcmToken() async {
  final token = await _fcm.getToken();

  if (token != null) {
    log('🔥 FCM TOKEN (INITIAL): $token');
  } else {
    log('⏳ FCM TOKEN NULL, WAITING...');
  }

  /// 🔥 LISTENER PALING PENTING
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    log('🔥 FCM TOKEN (REFRESH): $newToken');
  });
}


  /// ===============================
  /// TOKEN REFRESH LISTENER
  /// ===============================
  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) {
      log('🔁 FCM TOKEN REFRESHED: $newToken');
    });
  }

  /// ===============================
  /// FOREGROUND HANDLER
  /// ===============================
  void _listenForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 Foreground Message Data: ${message.data}');

      _showLocalNotification(
        title: message.notification?.title ?? 'Promo Laundry',
        body: message.notification?.body ??
            'Ada promo menarik untuk kamu!',
        payload: message.data['route'] ?? '/promo',
      );
    });
  }

  /// ===============================
  /// BACKGROUND & TERMINATED CLICK
  /// ===============================
  void _listenNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📲 Notification Clicked (Background)');
      _handleNavigation(message.data['route'] ?? '/promo');
    });

    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log('🚀 Notification Clicked (Terminated)');
        _handleNavigation(message.data['route'] ?? '/promo');
      }
    });
  }

  /// ===============================
  /// SHOW LOCAL NOTIFICATION
  /// ===============================
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'promo_channel', // HARUS SAMA
      'Promo Notification',
      channelDescription: 'Notifikasi promo laundry',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('promo_sound'),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// ===============================
  /// NAVIGATION HANDLER
  /// ===============================
  void _handleNavigation(String route) {
    if (route.isNotEmpty) {
      Get.toNamed(route);
    } else {
      Get.toNamed('/promo');
    }
  }
}
