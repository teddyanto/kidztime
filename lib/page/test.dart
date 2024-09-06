import 'package:flutter/material.dart';
import 'package:kidztime/page/main_screen.dart';
import 'package:kidztime/utils/png_assets.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white30,
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(4.0),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: <MenuWidget>[
            MenuWidget(
              width: 0,
              icon: iconMenu1,
              title: "Atur Batas Waktu",
              callBack: () {
                print("Clicked");
              },
            ),
          ].map((MenuWidget widget) {
            return widget;
          }).toList(),
        ),
      ),
    );
  }
}
