import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/batasPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
import 'package:kidztime/page/widget/radio_input_widget.dart';
import 'package:kidztime/page/widget/text_input_widget.dart';
import 'package:kidztime/page/widget/time_input_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class TimeLimitScreen extends StatefulWidget {
  const TimeLimitScreen({super.key});

  @override
  _TimeLimitScreenState createState() => _TimeLimitScreenState();
}

class _TimeLimitScreenState extends State<TimeLimitScreen> {
//controllers
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController bataswaktuController = TextEditingController();
  final TextEditingController toleransiController = TextEditingController();
  late int? id;

  final Future<Database> dbKidztime = DBKidztime().getDatabase();

  //variable for storing selected status
  bool _selectedStatus = true;
  late Bataspenggunaan _bataspenggunaan;

  @override
  void initState() {
    super.initState();
    id = -1;

    if (Get.arguments != null) {
      final args = Get.arguments;
      _bataspenggunaan = args;

      id = _bataspenggunaan.id;
      namaController.text = _bataspenggunaan.nama;
      deskripsiController.text = _bataspenggunaan.deskripsi;
      bataswaktuController.text = _bataspenggunaan.batasWaktu;
      toleransiController.text = _bataspenggunaan.batasToleransi;
      _selectedStatus = _bataspenggunaan.statusAktif;
    }
  }

  @override
  Widget build(BuildContext context) {
    //hasbackbutton
    var hasbackbutton = true;

    return Scaffold(
      appBar: WidgetUtil().getAppBar(),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeaderWidget(
              titleScreen: "Time Limit",
              callback: () {
                Get.back();
              },
              hasBackButton: hasbackbutton,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CardWidget(
                      horizontalMargin: 30.0,
                      verticalMargin: 30.0,
                      horizontalPadding: 30.0,
                      verticalPadding: 40.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextInputWidget(
                            maxLength: 20,
                            controller: namaController,
                            title: "Nama Batasan",
                            placeholder: "Masukkan nama batasan",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextInputWidget(
                            maxLength: 150,
                            controller: deskripsiController,
                            title: "Deskripsi",
                            placeholder: "Masukkan deskripsi",
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TimeInputWidget(
                            controller: bataswaktuController,
                            title: "Batas Waktu",
                            hint: "Tekan di sini",
                            initialTime: bataswaktuController.text == ''
                                ? const TimeOfDay(hour: 0, minute: 0)
                                : TimeOfDay(
                                    hour: int.parse(bataswaktuController.text
                                        .split(":")[0]),
                                    minute: int.parse(bataswaktuController.text
                                        .split(":")[1])),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TimeInputWidget(
                            controller: toleransiController,
                            title: "Toleransi",
                            hint: "Tekan di sini",
                            initialTime: toleransiController.text == ""
                                ? const TimeOfDay(hour: 0, minute: 5)
                                : TimeOfDay(
                                    hour: int.parse(
                                        toleransiController.text.split(":")[0]),
                                    minute: int.parse(toleransiController.text
                                        .split(":")[1])),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          RadioButtonWidget<bool>(
                            title: "Status Aktif",
                            options: const [true, false],
                            optionLabels: const {
                              true: 'Aktif',
                              false: 'Tidak Aktif',
                            },
                            groupValue: _selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value ?? true;
                              });
                            },
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    saveTimeLimit();
                                  },
                                  borderRadius: BorderRadius.circular(10.0),
                                  splashColor: Colors.amber,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40.0, vertical: 5.0),
                                    decoration: BoxDecoration(
                                      color:
                                          WidgetUtil().parseHexColor(darkColor),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Text(
                                      "Simpan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                )),
              ),
            )
          ]),
    );
  }

  void saveTimeLimit() {
    if (validateInput()) {
      WidgetUtil().customeDialog(
        context: context,
        title: "Simpan data?",
        detail: [
          const Text("Detail Data?"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama:"),
                    Text("Deskripsi: "),
                    Text("Batas Waktu: "),
                    Text("Toleransi: "),
                    Text("Status Aktif: "),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      deskripsiController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      bataswaktuController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      toleransiController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _selectedStatus ? 'Aktif' : 'Tidak Aktif',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        okButtonFunction: () {
          // save data to database
          //saveData();
          Bataspenggunaan bataspenggunaan = Bataspenggunaan(
            id: id,
            nama: namaController.text,
            deskripsi: deskripsiController.text,
            batasWaktu: bataswaktuController.text,
            batasToleransi: toleransiController.text,
            statusAktif: _selectedStatus, // Save as boolean
          );

          if (bataspenggunaan.statusAktif) {
            updateStatusAktifBatasPenggunaan(dbKidztime, false);
          }

          insertOrUpdateBatasPenggunaan(dbKidztime, bataspenggunaan).then((e) {
            // Print the data that was just inserted
            print('Data added to database: $bataspenggunaan');

            Navigator.of(context).pop();

            WidgetUtil().showLoadingDialog(
              context: context,
            );
            Timer(const Duration(seconds: 3), () {
              Navigator.of(context).pop();

              WidgetUtil().customeDialog(
                context: context,
                title: "Berhasil",
                detail: [
                  const Text("Data berhasil disimpan"),
                ],
                okButtonText: "OK",
                okButtonFunction: () {
                  Navigator.of(context).pop();

                  Get.back(result: "added");
                },
              );
            });
          });
        },
        okButtonText: "Simpan",
        cancelButtonText: "Batal",
      );
    }
  }

  bool validateInput() {
    if (namaController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Nama tidak boleh kosong");
      return false;
    }

    if (deskripsiController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Deskripsi tidak boleh kosong");
      return false;
    }

    if (bataswaktuController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Batas Waktu tidak boleh kosong");
      return false;
    }

    if (toleransiController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Toleransi tidak boleh kosong");
      return false;
    }

    return true;
  }
}
