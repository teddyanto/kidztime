import 'dart:async';
import 'dart:ui';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/model/notifikasi.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/preferences.dart';
import 'package:sqflite/sqflite.dart';

const appPackage = 'com.binus.kidztime';
const youtubePackage = 'com.google.android.youtube';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  late Timer timer;
  final Future<Database> dbKidztime = DBKidztime().getDatabase();

  /** Untuk notifikasi */
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  /** ---------------- */

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      print("setAsForeground");
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    serviceStopped(dbKidztime, timer, service);
  });

  print("MMMM ada yg ubah dari background_service.dart 333");

  await Preferences.getLockTime().then((lockTime) async {
    /** Initialize notifikasi already set */

    final List<Notifikasi> listNotifikasi =
        await fetchNotifikasisOrderByWaktuDesc(dbKidztime);
    /** --------------------------------- */

    timer = Timer.periodic(const Duration(seconds: 1), (a) async {
      if (service is AndroidServiceInstance) {
        DateTime now = DateTime.now();

        /** Memunculkan notifikasi */

        if (listNotifikasi.isNotEmpty) {
          int remainingTime = lockTime.difference(now).inSeconds;

          // Convert notifikasi.waktu (which is in minutes) to seconds
          int notifSisaWaktu = listNotifikasi.first.waktu * 60;

          /** Skip jika notif sisa waktu notif > remaining time */
          if (notifSisaWaktu > remainingTime) {
            listNotifikasi.removeAt(0);
          }

          print("SISA WAKTU : $remainingTime");
          print("Notif Sisa Waktu  : $notifSisaWaktu");
          if (remainingTime == notifSisaWaktu) {
            await flutterLocalNotificationsPlugin.show(
              listNotifikasi.first.id,
              listNotifikasi.first.judul,
              listNotifikasi.first.detail,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  '912',
                  appPackage,
                  channelDescription: 'Notification for Kidztime Apps',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
              payload:
                  'Notification for ${listNotifikasi.first.judul}', // Optional payload
            );

            listNotifikasi.removeAt(0);
          }
        }

        /** ---------------------- */

        if (now.isAfter(lockTime)) {
          print("WAKTU SUDAH HABIS");
          serviceStopped(dbKidztime, timer, service).then((value) {
            openApp();
          });
        }

        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Kidztime service",
            content: "Device akan terkunci pada $lockTime",
          );
        }
      }
    });
  });

  // bring to foreground
}

Future<void> serviceStopped(
  Future<Database> dbKidztime,
  Timer timer,
  ServiceInstance service,
) async {
  Preferences.getTempAktivitas().then((tempAktivitas) {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime.parse(tempAktivitas.tanggal);
    print("SERVICE DIHENTIKAN $now");
    Duration alreadyRunning = now.difference(startTime);

    Aktivitas aktivitas = Aktivitas(
      judul: tempAktivitas.judul,
      deskripsi: tempAktivitas.deskripsi,
      waktu: alreadyRunning.inSeconds,
      tanggal: tempAktivitas.tanggal,
    );

    insertAktivitas(dbKidztime, aktivitas);

    timer.cancel();

    Timer(const Duration(seconds: 1), () {
      service.stopSelf();
    });
  });
}

Future<void> openApp() async {
  try {
    await LaunchApp.openApp(
      androidPackageName: appPackage,
    );
  } on PlatformException catch (e) {
    print("Failed to bring app to foreground: '${e.message}'.");
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return false;
}

class BackgroundService {
  static final BackgroundService instance = BackgroundService._internal();
  static final service = FlutterBackgroundService();

  factory BackgroundService() {
    return instance;
  }

  BackgroundService._internal();

  Future init() async {
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: false,
      ),
    );
  }

  Future<void> start() async {
    service.startService();
  }
}
