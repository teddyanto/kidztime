import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/png_assets.dart';

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
    countTimer = Timer.periodic(const Duration(seconds: 1), (e) {
      setState(() {
        countDown -= 1;
      });

      if (countDown == 0) {
        countTimer.cancel();
        Get.offAndToNamed(
          "/lock-page",
          arguments: {
            'from': 'times_up_screen',
          },
        );
      }
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
