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

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  _LockPageState createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  late List<TextEditingController> sandiControllers;
  late Future<Database> dbKidztime;

  String? sandi;
  bool isValid = true;

  @override
  void initState() {
    super.initState();
    sandiControllers = List.generate(4, (_) => TextEditingController());
    dbKidztime = DBKidztime().getDatabase();

    dbKidztime.then((db) {
      getPengaturan(db).then((pengaturan) {
        setState(() {
          sandi = pengaturan.isNotEmpty ? pengaturan.first.sandi : DEFAULT_KEY;
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              lockPage: true,
            ),
            const SizedBox(height: 5),
            if (!isValid)
              const Text(
                "Sandi yang anda masukkan tidak benar",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
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
      for (TextEditingController item in sandiControllers) {
        item.text = "";
      }
      FocusScope.of(context).unfocus();

      isValid = false;
      setState(() {});
    }
  }
}
