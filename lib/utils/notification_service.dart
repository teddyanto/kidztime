import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kidztime/model/notifikasi.dart';
import 'package:sqflite/sqflite.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          print("Notification tapped: ${notificationResponse.payload}");
        }
      },
    );

    // Create a notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel name
      description: 'your_channel_description', // Channel description
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleNotifications(
      Future<Database> database, int remainingTime) async {
    final List<Notifikasi> notifikasis =
        await fetchNotifikasisOrderByWaktuDesc(database);

    for (var notifikasi in notifikasis) {
      // Convert notifikasi.waktu (which is in minutes) to seconds
      final int waktuInSeconds = notifikasi.waktu * 60;

      // Check if remainingTime matches waktuInSeconds
      if (remainingTime == waktuInSeconds) {
        // Trigger the notification
        await flutterLocalNotificationsPlugin.show(
          notifikasi.id ?? 0,
          notifikasi.judul,
          notifikasi.detail,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id',
              'your_channel_name',
              channelDescription: 'your_channel_description',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: 'Notification for ${notifikasi.judul}', // Optional payload
        );
        print(
            'Notification triggered for ${notifikasi.judul} at remaining time: $remainingTime seconds');
      }
    }
  }
}
