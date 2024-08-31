import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/Pengaturan.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final DBKidztime dbKidztime = DBKidztime();

    dbKidztime.getDatabase().then((database) {
      getPengaturan(database).then((pengaturan) {
        Timer(const Duration(seconds: 3), () {
          if (pengaturan.isEmpty) {
            Get.offAndToNamed(
              '/setup-page',
              arguments: {
                'from': 'splash_screen',
              },
            );
          } else {
            Get.offAndToNamed('/lock-page');
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: WidgetUtil().parseHexColor(primaryColor),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.21,
            child: Hero(
              tag: 'apps-icon',
              child: Image.asset(logo),
            ),
          ),
        ),
      ),
    );
  }
}
