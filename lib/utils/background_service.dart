import 'dart:async';
import 'dart:ui';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:kidztime/model/aktivitas.dart';
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

  await Preferences.getLockTime().then((lockTime) {
    timer = Timer.periodic(const Duration(seconds: 1), (a) async {
      if (service is AndroidServiceInstance) {
        DateTime now = DateTime.now();

        print("LOCK AT $lockTime");
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
