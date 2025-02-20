import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger logger = Logger(); // ロガーを追加

  Future<void> initializeFCM() async {
    // iOS の通知許可をリクエスト（iOS で必要）
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    logger.i("🔔 通知許可ステータス: ${settings.authorizationStatus}");

    // ローカル通知の設定
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.i("🔄 通知がタップされました: ${response.payload}");
      },
    );

    // FCM トークンを取得
    String? token = await _messaging.getToken();
    if (token != null) {
      logger.i("🔥 FCM Token: $token");
    } else {
      logger.w("❌ FCM トークンの取得に失敗");
    }

    // トピック購読（Web では実行しない）
    if (!kIsWeb) {
      await _messaging.subscribeToTopic("all_users");
      logger.i("✅ Subscribed to 'all_users' topic");
    } else {
      logger.w("⚠️ Web では subscribeToTopic() はサポートされていません。");
    }

    // Foreground（アプリ起動中）で通知を受け取る
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i("📩 Foreground メッセージ受信: ${message.notification?.title}");
      if (!kIsWeb) {
        _showLocalNotification(message); // モバイルアプリでローカル通知を表示
      }
    });

    // iOS で foreground 通知を有効化
    if (!kIsWeb) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // バックグラウンド & 終了時の通知を処理
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i("🔄 ユーザーが通知をタップしました: ${message.notification?.title}");
    });
  }

  // ローカル通知を表示
  void _showLocalNotification(RemoteMessage message) {
    var androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    var iosDetails = const DarwinNotificationDetails();
    var generalNotificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _localNotifications.show(
      0,
      message.notification?.title ?? "通知",
      message.notification?.body ?? "内容なし",
      generalNotificationDetails,
    );
  }
}
