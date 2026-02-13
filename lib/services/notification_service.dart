import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    tz.initializeTimeZones();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'movie_tickets_channel',
      'Билеты в кино',
      description: 'Уведомления о билетах и сеансах',
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> showCartAddedNotification(String movieTitle) async {
    await _notifications.show(
      1,
      '🎬 Добавлено в корзину!',
      '$movieTitle добавлен в корзину',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'movie_tickets_channel',
          'Билеты в кино',
          channelDescription: 'Уведомления о билетах и сеансах',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'cart_added_$movieTitle',
    );
  }

  static Future<void> scheduleCartReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(minutes: 1));  // тест: 1 минута

    await _notifications.zonedSchedule(
      2,
      '⏰ Корзина ждет!',
      'У вас есть непогашенные билеты. Не забудьте оплатить!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'movie_tickets_channel',
          'Билеты в кино',
          channelDescription: 'Уведомления о билетах и сеансах',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'cart_reminder',
    );
  }

  static Future<void> cancelCartReminder() async {
    await _notifications.cancel(2);
  }
}
