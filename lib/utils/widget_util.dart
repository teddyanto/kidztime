import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidztime/utils/colors.dart';

class WidgetUtil {
  static final WidgetUtil _singleton = WidgetUtil._internal();

  factory WidgetUtil() => _singleton;

  WidgetUtil._internal();

  Color parseHexColor(String hexColorString) {
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString";
    }
    int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }

  void showToast({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
    );
  }

  PreferredSize getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(0),
      child: AppBar(
        backgroundColor: WidgetUtil().parseHexColor(darkColor),
      ),
    );
  }

  Future<void> customeDialog({
    required BuildContext context,
    required String title,
    required List<Widget> detail,
    required String okButtonText,
    required Function okButtonFunction,
    String? cancelButtonText,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: detail,
            ),
          ),
          actions: <Widget>[
            cancelButtonText != null
                ? TextButton(
                    child: Text(cancelButtonText),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : Container(),
            TextButton(
              child: Text(okButtonText),
              onPressed: () {
                okButtonFunction();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showLoadingDialog({
    required BuildContext context,
    int? secondStop,
  }) {
    if (secondStop != null) {
      Timer(Duration(seconds: secondStop), () {
        Navigator.of(context).pop();
      });
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  String getMonthName(indexMonth) {
    List<String> bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return bulan[indexMonth - 1];
  }

  String getDayName(int indexDay) {
    List<String> hari = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jum'at",
      "Sabtu",
      "Minggu"
    ];
    return hari[indexDay - 1];
  }
}
