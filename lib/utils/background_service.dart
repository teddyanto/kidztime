import 'dart:async';
import 'dart:ui';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:kidztime/utils/preferences.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  late Timer timer;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
    timer.cancel();
    print("SERVICE STOPPED !");
  });

  await Preferences.getLockTime().then((lockTime) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        DateTime now = DateTime.now();

        print('FLUTTER BACKGROUND SERVICE: $now');
        print('FLUTTER BACKGROUND SERVICE time: $lockTime');

        if (now.isAfter(lockTime)) {
          print("UDAH LEWAT CUYYY WAKTU NYA");
          timer.cancel();
          await LaunchApp.openApp(
            androidPackageName: 'com.binus.kidztime',
          );

          try {
            // Ensure the service instance is used
            service.invoke('stopService');
          } catch (e) {
            print("Error invoking 'stopService': $e");
          }
        }

        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Kidztime service",
            content: "Updated at ${DateTime.now()}",
          );
        }
      }
    });
  });

  // bring to foreground
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
