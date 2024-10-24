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

  await Preferences.getLockTime().then((lockTime) async {
    // Mendapatkan waktu penguncian dari preferensi pengguna.

    /** Initialize notifikasi already set */
    final List<Notifikasi> listNotifikasi =
        await fetchNotifikasisOrderByWaktuDesc(dbKidztime);
    // Mengambil daftar notifikasi yang sudah diatur, disusun berdasarkan waktu secara menurun (paling terbaru berada di awal daftar).
    /** --------------------------------- */

    timer = Timer.periodic(const Duration(seconds: 1), (a) async {
      // Membuat timer yang berjalan setiap detik.

      if (service is AndroidServiceInstance) {
        // Memastikan service ini berjalan sebagai AndroidServiceInstance.

        DateTime now = DateTime.now();
        // Mengambil waktu sekarang.

        /** Memunculkan notifikasi */

        if (listNotifikasi.isNotEmpty) {
          // Memastikan ada notifikasi di dalam daftar.

          int remainingTime = lockTime.difference(now).inSeconds;
          // Menghitung sisa waktu hingga penguncian dalam satuan detik.

          // Mengonversi notifikasi.waktu (dalam menit) menjadi detik.
          int notifSisaWaktu = listNotifikasi.first.waktu * 60;

          /** Skip jika notif sisa waktu notif > remaining time */
          if (notifSisaWaktu > remainingTime) {
            listNotifikasi.removeAt(0);
            // Menghapus notifikasi pertama dari daftar jika sisa waktunya lebih besar dari waktu penguncian.
          }

          if (remainingTime == notifSisaWaktu) {
            // Jika waktu tersisa sama dengan waktu yang diatur dalam notifikasi.
            await showNotification(
                flutterLocalNotificationsPlugin, listNotifikasi);
            // Menampilkan notifikasi kepada pengguna.

            listNotifikasi.removeAt(0);
            // Menghapus notifikasi setelah ditampilkan.
          }
        }

        /** ---------------------- */

        if (now.isAfter(lockTime)) {
          // Jika waktu sekarang telah melewati waktu penguncian.
          serviceStopped(dbKidztime, timer, service).then((value) {
            openApp();
            // Menghentikan layanan, mengupdate status di database, dan membuka aplikasi utama.
          });
        }
      }
    });
  });

  // bring to foreground
}

Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    List<Notifikasi> listNotifikasi) async {
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
