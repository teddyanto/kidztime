import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  int i = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        Get.offAndToNamed('/lock-page');
      },
    );
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
