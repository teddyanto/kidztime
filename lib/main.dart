import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kidztime/background_service.dart';
import 'package:kidztime/routes.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundService.instance.init();
  databaseInitialize();
  runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({key}) : super(key: key);

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
      initialRoute: '/',
      getPages: Routes().get(),
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('in')],
    );
  }
}
