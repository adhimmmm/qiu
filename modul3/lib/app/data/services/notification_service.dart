import 'dart:developer';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();


  /// ===============================
  /// INIT SERVICE
  /// ===============================
  Future<NotificationService> init() async {
    await _requestPermission();
    await _initLocalNotification();
    await _forceGenerateToken();

    _listenForegroundMessage();
    _listenTokenRefresh();
    setupClickHandler();

    return this;
  }

  /// ===============================
  /// REQUEST PERMISSION
  /// ===============================
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 PERMISSION STATUS: ${settings.authorizationStatus}');
  }

  /// ===============================
  /// FORCE TOKEN GENERATION
  /// ===============================
  Future<void> _forceGenerateToken() async {
    try {
      await _fcm.deleteToken(); // 🔥 PAKSA BUAT TOKEN BARU
      final token = await _fcm.getToken();

      print('==============================');
      print('🔥 FCM TOKEN RESULT');
      print('TOKEN: $token');
      print('==============================');

      if (token == null) {
        print('❌ TOKEN MASIH NULL');
      }
    } catch (e) {
      print('❌ ERROR GET TOKEN: $e');
    }
  }

  /// ===============================
  /// TOKEN REFRESH
  /// ===============================
  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((token) {
      print('🔁 TOKEN REFRESHED: $token');
    });
  }


/// ===============================
/// BACKGROUND & TERMINATED CLICK
/// ===============================
void setupClickHandler() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 CLICK FROM BACKGROUND: ${message.data}');
  });

  _fcm.getInitialMessage().then((message) {
    if (message != null) {
      print('🚀 CLICK FROM TERMINATED: ${message.data}');
    }
  });
}

  /// ===============================
  /// LOCAL NOTIFICATION INIT
  /// ===============================
  Future<void> _initLocalNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _localNotif.initialize(initSettings);
  }

  /// ===============================
  /// FOREGROUND MESSAGE
  /// ===============================
  void _listenForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 FOREGROUND MESSAGE: ${message.data}');

      _showLocalNotification(
        title: message.notification?.title ?? 'Promo',
        body: message.notification?.body ?? 'Promo menarik untuk kamu',
      );
    });
  }

  /// ===============================
  /// SHOW LOCAL NOTIFICATION
  /// ===============================
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'promo_channel',
      'Promo Notification',
      channelDescription: 'Notifikasi promo',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
