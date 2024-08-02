import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/env.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';

class LockPage extends StatelessWidget {
  const LockPage({Key? key}) : super(key: key);

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
            FourLetterInput(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FourLetterInput extends StatefulWidget {
  @override
  _FourLetterInputState createState() => _FourLetterInputState();
}

class _FourLetterInputState extends State<FourLetterInput> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controllers[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              counterText: '', // Hide the length counter
              border: InputBorder.none,
            ),
            textInputAction:
                index < 3 ? TextInputAction.next : TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            onChanged: (text) {
              if (text.length == 1 && index < 3) {
                FocusScope.of(context).nextFocus();
              } else if (text.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
            onEditingComplete: () {
              passwordHandleCheck(_controllers);
            },
          ),
        ),
      ),
    );
  }
}

void passwordHandleCheck(List<TextEditingController> _input) {
  bool valid = true;
  const _defaultKey = DEFAULT_KEY;
  String inputKey = "";
  for (var item in _input) {
    print(item.text);
    inputKey += item.text;
  }

  if (inputKey == _defaultKey) {
    Get.offAndToNamed("/main-menu");
  } else {
    print("Salah euy");
  }
}
