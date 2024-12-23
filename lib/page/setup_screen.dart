import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/Pengaturan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/password_widget.dart';
import 'package:kidztime/page/widget/text_input_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class Setupscreen extends StatefulWidget {
  Setupscreen({super.key});

// List controller textfield yang dipakai
  late TextEditingController namaController = TextEditingController();
  late TextEditingController deskripsiController = TextEditingController();
  late List<TextEditingController> sandiControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  late Future<Database> dbKidztime = DBKidztime().getDatabase();
  late String sandiVal;

  @override
  State<Setupscreen> createState() => _SetupscreenState();
}

class _SetupscreenState extends State<Setupscreen> {
  bool hasBackButton = true;

  late Future<Database> dbKidztime;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      final fromScreen = args['from'];
      if (fromScreen == 'splash_screen') {
        setState(() {
          hasBackButton = false;
        });
      }
    } else {
      _loadPengaturan();
    }
  }

  @override
  void dispose() {
    widget.namaController.dispose();
    widget.deskripsiController.dispose();

    super.dispose();
  }

  Future<void> _loadPengaturan() async {
    final db = await DBKidztime().getDatabase();
    final pengaturan = await getPengaturan(db);
    if (pengaturan.isNotEmpty) {
      setState(() {
        final p = pengaturan.first;
        widget.namaController.text = p.nama;
        widget.deskripsiController.text = p.deskripsi;
        for (int i = 0; i < 4; i++) {
          widget.sandiControllers[i].text = p.sandi[i];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 120,
                ),
                const Text("Please set a password to secure the app"),
                CardWidget(
                  horizontalMargin: 30.0,
                  verticalMargin: 30.0,
                  horizontalPadding: 30.0,
                  verticalPadding: 40.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextInputWidget(
                        title: "Nama",
                        placeholder: "Masukkan nama anda di sini ...",
                        controller: widget.namaController,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextInputWidget(
                        title: "Deskripsi",
                        placeholder: "Deskripsi kan diri anda ...",
                        controller: widget.deskripsiController,
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Sandi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "*Sandi ini digunakan untuk membuka aplikasi",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FourLetterInput(
                          obscureText: false,
                          controllers: widget.sandiControllers,
                          passwordHandleCheck: () {
                            _saveAppSetup();
                          }),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (hasBackButton)
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  WidgetUtil().parseHexColor(primaryColor),
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed("/times-up");
                              },
                              label: const Row(
                                children: [
                                  Text(
                                    "Trial ",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                WidgetUtil().parseHexColor(darkColor),
                              ),
                            ),
                            onPressed: () {
                              _saveAppSetup();
                            },
                            label: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          WidgetUtil().getAppBarV2(
            titleScreen: "App Setup",
            callback: () {
              Get.back();
            },
            context: context,
            hasBackButton: hasBackButton,
          )
        ],
      ),
    );
  }

  void _saveAppSetup() {
    if (_validationCheck()) {
      WidgetUtil().customeDialog(
        context: context,
        title: "Simpan data?",
        detail: [
          const Text("Detail data:"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama:"),
                    Text("Sandi:"),
                    Text("Deskripsi:"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.namaController.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.sandiVal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.deskripsiController.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        okButtonFunction: () {
          Pengaturan pengaturan = Pengaturan(
            id: 1,
            nama: widget.namaController.text,
            deskripsi: widget.deskripsiController.text,
            sandi: widget.sandiVal,
          );

          insertPengaturan(widget.dbKidztime, pengaturan).then((e) {
            // ini buat ngilangin dialog sebelumnya yg konfirmasi
            Navigator.of(context).pop();

            WidgetUtil().showLoadingDialog(
              context: context,
            );

            Timer(const Duration(seconds: 1), () {
              Navigator.of(context)
                  .pop(); // Ini buat ngilangin showDoalog atasnya

              WidgetUtil().customeDialog(
                context: context,
                title: "Information",
                detail: [const Text("Berhasil menyimpan data !")],
                okButtonText: "OK",
                okButtonFunction: () {
                  Navigator.of(context)
                      .pop(); // Ini buat ngilangin customeDialog yg sekarang
                  if (!hasBackButton) {
                    Get.offAndToNamed('/');
                  } else {
                    Get.offAndToNamed('/main-menu');
                  }
                },
              );
            });
          });
        },
        okButtonText: "Konfirmasi",
        cancelButtonText: "Batal",
      );
    }
  }

  bool _validationCheck() {
    if (widget.namaController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Mohon isi nama dengan benar");
      return false;
    }
    if (widget.deskripsiController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Mohon isi deskripsi dengan benar");
      return false;
    }
    widget.sandiVal = "";
    for (TextEditingController element in widget.sandiControllers) {
      widget.sandiVal += element.text;
    }

    if (widget.sandiVal.length < 4) {
      WidgetUtil().showToast(msg: "Mohon isi sandi dengan benar");
      return false;
    }

    return true;
  }
}
