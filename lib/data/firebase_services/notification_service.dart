import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/logger.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotificationSystem() async {
    // ask permission
    await _requestPermission();

    // create Android channel
    await _createNotificationChannel();

    // initialize local notification plugin
    await _initLocalNotifications();

    // listen foreground messages
    _listenForegroundMessages();

    // background & terminated already handled in main.dart handler
    _printToken();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission();
    AppLogger.debug(
        "🔔 Notification Permission: ${settings.authorizationStatus}");
  }

  // Future<void> _requestPermission() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );

  //   print("Permission status: ${settings.authorizationStatus}");
  // }

  // Step2

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    AppLogger.debug("📡 Android notification channel created");
  }

  Future<void> _initLocalNotifications() async {
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initSettings);
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.debug(
          "📥 Foreground message received: ${message.notification?.title}");

      final notification = message.notification;
      if (notification == null) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
      );
    });
  }

  Future<void> _printToken() async {
    final token = await _messaging.getToken();
    AppLogger.debug("🔑 FCM Token: $token");
  }
}
