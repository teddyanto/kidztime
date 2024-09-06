import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:kidztime/model/pengaturan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:sqflite/sqflite.dart';

class TimesUpScreen extends StatefulWidget {
  const TimesUpScreen({super.key});

  @override
  State<TimesUpScreen> createState() => _TimesUpScreenState();
}

class _TimesUpScreenState extends State<TimesUpScreen> {
  int countDown = 3;
  late Timer countTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final Future<Database> dbKidztime = DBKidztime().getDatabase();
    dbKidztime.then((e) {
      getPengaturan(e).then((pengaturan) {
        for (Pengaturan element in pengaturan) {
          countTimer = Timer.periodic(const Duration(seconds: 1), (e) {
            setState(() {
              countDown -= 1;
            });

            if (countDown == 0) {
              countTimer.cancel();
              screenLock(
                context: context,
                correctString: element.sandi,
                canCancel: false,
                title: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                          10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white, // Warna latar belakang kartu
                          borderRadius:
                              BorderRadius.circular(16.0), // Sudut melengkung
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.2), // Warna bayangan
                              spreadRadius: 2, // Radius penyebaran bayangan
                              blurRadius: 10, // Radius blur bayangan
                              offset: const Offset(5, 5), // Posisi bayangan
                            ),
                          ],
                        ),
                        width: 60,
                        child: Image.asset(
                          logo,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Silahkan masukkan sandi yang benar untuk membuka perangkat anda.",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                onUnlocked: () async {
                  FlutterBackgroundService().invoke("stopService");
                  SystemNavigator.pop();
                },
              );
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardWidget(
                horizontalMargin: 20,
                horizontalPadding: 10,
                verticalMargin: 0,
                verticalPadding: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        5,
                      ),
                      width: 60,
                      child: Image.asset(
                        logo,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Anda telah melewati batas waktu penggunaan gawai. Saatnya beristirahat !!!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Gawai akan terkunci dalam ",
                  ),
                  Text(
                    countDown.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
