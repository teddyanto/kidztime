import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/Pengaturan.dart';
import 'package:kidztime/page/widget/password_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/env.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class LockPage extends StatelessWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> sandiControllers = List.generate(
      4,
      (_) => TextEditingController(),
    );

    final Future<Database> dbKidztime = DBKidztime().getDatabase();
    late String? sandi;
    dbKidztime.then((e) {
      getPengaturan(e).then((pengaturan) {
        for (Pengaturan element in pengaturan) {
          sandi = element.sandi;
        }
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: WidgetUtil().parseHexColor(primaryColor),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: WidgetUtil().parseHexColor(darkColor),
                  width: 3,
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.25,
              child: Hero(
                tag: 'apps-icon',
                child: Image.asset(
                  logo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "KidzTime",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "“Waktu Terkontrol, Kesehatan Terjaga”\nAplikasi Kontrol Gawai untuk Anak yang Lebih Baik.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            FourLetterInput(
              controllers: sandiControllers,
              passwordHandleCheck: () {
                passwordHandleCheck(sandiControllers, sandi ?? DEFAULT_KEY);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void passwordHandleCheck(List<TextEditingController> input, String sandi) {
  bool valid = true;

  print(sandi);
  String inputKey = "";
  for (var item in input) {
    print(item.text);
    inputKey += item.text;
  }

  if (inputKey == sandi) {
    Get.offAndToNamed("/main-menu");
  } else {
    print("Salah euy");
  }
}
