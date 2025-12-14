import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:laundry_app/app/routes/app_routes.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _localNotif;

  Future<NotificationService> init() async {
    print('🚀 NotificationService initializing...');
    
    _localNotif = FlutterLocalNotificationsPlugin();
    await _forceGenerateToken();
    _setupForegroundListener();
    _setupTapListener();
    
    print('✅ NotificationService ready');
    return this;
  }

  Future<void> _forceGenerateToken() async {
    try {
      await _fcm.deleteToken();
      final token = await _fcm.getToken();
      print('🔥 FCM Token: $token');
    } catch (e) {
      print('❌ Token error: $e');
    }
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((message) {
      print('📱 Foreground message: ${message.notification?.title}');
      _showLocalNotification(
        title: message.notification?.title ?? 'Promo',
        body: message.notification?.body ?? 'Promo menarik',
      );
    });
  }

  void _setupTapListener() {
    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('👆 Tapped from background');
      Get.offNamed(Routes.PROMO);
    });

    // Terminated tap
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        print('👆 Tapped from terminated');
        Future.delayed(Duration(milliseconds: 500), () {
          Get.offNamed(Routes.PROMO);
        });
      }
    });
  }

  void _showLocalNotification({
    required String title,
    required String body,
  }) {
    const android = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: android),
    );
  }
}