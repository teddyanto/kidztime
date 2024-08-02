import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetUtil {
  static final WidgetUtil _singleton = WidgetUtil._internal();

  factory WidgetUtil() => _singleton;

  WidgetUtil._internal();

  Color parseHexColor(String hexColorString) {
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = "FF" + hexColorString;
    }
    int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }

  // void showToast({required String msg}) {
  //   Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 1,
  //   );
  // }

  PreferredSize getAppBar() {
    return PreferredSize(
      child: AppBar(
        backgroundColor: WidgetUtil().parseHexColor('#012C3D'),
      ),
      preferredSize: const Size.fromHeight(0),
    );
  }
}
