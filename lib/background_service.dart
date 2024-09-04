import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:kidztime/utils/widget_util.dart';

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

  // bring to foreground
  timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Kidztime service",
          content: "Updated at ${DateTime.now()}",
        );
      }

      DateTime startService = BackgroundService.time;
      int serviceHour = startService.hour;
      int serviceMinute = startService.minute;
      int serviceSecond = startService.second;
      String serviceString = "$serviceHour$serviceMinute$serviceSecond";

      DateTime now = DateTime.now();
      int nowHour = now.hour;
      int nowMinute = now.minute;
      int nowSecond = now.second;
      String nowString = "$nowHour$nowMinute$nowSecond";

      if (serviceString == nowString) {
        WidgetUtil().showToast(msg: "Times is up");
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    print('FLUTTER BackgroundService time: ${BackgroundService.time}');

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "Platform.androidInfo",
      },
    );
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return false;
}

class BackgroundService {
  static final BackgroundService instance = BackgroundService._internal();
  static final DateTime time = DateTime.now().add(const Duration(seconds: 5));
  static final service = FlutterBackgroundService();

  factory BackgroundService() {
    return instance;
  }

  BackgroundService._internal();

  Future init() async {
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
      ),
    );
  }

  Future<void> start() async {
    service.startService();
  }
}
