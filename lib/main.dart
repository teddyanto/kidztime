import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kidztime/routes.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/notification_service.dart';
import 'package:kidztime/utils/preferences.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize android_alarm_manager_plus

// Initialize time zone data
  tz.initializeTimeZones();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initNotification();

  // // Initialize database
  databaseInitialize();

  /** Ini buat informasi aja, aplikasi kita tuh kek mana sih isi informasi nya */
  PackageInfo.fromPlatform().then((value) {
    print(value);
  });

  /** Ini logic untuk pengecekan aplikasi pertama kali dibuka 
   * 
   * Dibuka saat ada aktivitas background / tidak
   * Dicek juga waktu nya udah abis atau belum
   * 
   * Pokoknya kalo waktu udh abis dan aplikasi mau dibuka
   * (Entah dibuka manual 'klik aplikasi' / otomatis kebuka karena fitur background service kita)
   * Dia masuknya di halaman TimesUpPage (Karena ide nya ini dibuka sama yg lg main)
   * 
   * Sebaliknya, berarti masuk ke halaman normal 'MainPage'
  */

  DateTime now = DateTime.now();
  final service = FlutterBackgroundService();
  var isRunning = await service.isRunning();
  if (isRunning) {
    await Preferences.getLockTime().then((lockTime) {
      if (now.isAfter(lockTime)) {
        runApp(const TimesUpPage());
      } else {
        runApp(const MainPage());
      }
    });
  } else {
    runApp(const MainPage());
  }

  /**
   * Kalo ngeh, di atas ada Preferences.setTemp(???)
   * 
   * Nah itu buat set aja temporary di sharedpreferences buat testing masuk di mana sih
   * Nanti dihapus aja kalo udh live
   * 
   * Pemanfaatannya bisa di mana aja, contoh nya di main_screen sih yg ada
   * 
   */
}

class MainPage extends StatelessWidget {
  const MainPage({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: WidgetUtil().parseHexColor(primaryColor),
        primaryColorDark: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor:
              WidgetUtil().parseHexColor(primaryColor), // Global AppBar color
          elevation: 0, // Customize the AppBar elevation if needed
        ),
      ),
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: Routes().get(),
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('in')],
    );
  }
}

class TimesUpPage extends StatelessWidget {
  const TimesUpPage({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryColor = WidgetUtil().parseHexColor('#012C3D');

    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: primaryColor,
        primaryColorDark: Colors.black,
      ),
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
      initialRoute: '/times-up',
      getPages: Routes().get(),
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('in')],
    );
  }
}
