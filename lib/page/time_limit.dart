import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/main.dart';
import 'package:kidztime/model/batasPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
import 'package:kidztime/page/widget/radio_input_widget.dart';
import 'package:kidztime/page/widget/text_input_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class TimeLimitScreen extends StatefulWidget {
  TimeLimitScreen({Key? key}) : super(key: key);

  //controllers
  late TextEditingController namaController = TextEditingController();
  late TextEditingController deskripsiController = TextEditingController();
  late TextEditingController bataswaktuController = TextEditingController();
  late TextEditingController toleransiController = TextEditingController();

  late Future<Database> dbKidztime = DBKidztime().getDatabase();

  @override
  _TimeLimitScreenState createState() => _TimeLimitScreenState();
}

class _TimeLimitScreenState extends State<TimeLimitScreen> {
  //variable for storing selected status
  bool _selectedStatus = true;

  @override
  void initState() {
    super.initState();
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
              callback: () {},
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
                            controller: widget.namaController,
                            title: "Nama",
                            placeholder: "Masukkan nama",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextInputWidget(
                            controller: widget.deskripsiController,
                            title: "Deskripsi",
                            placeholder: "Masukkan deskripsi",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextInputWidget(
                            controller: widget.bataswaktuController,
                            title: "Batas Waktu",
                            placeholder: "Masukkan batas waktu",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextInputWidget(
                            controller: widget.toleransiController,
                            title: "Toleransi",
                            placeholder: "Masukkan toleransi",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          RadioButtonWidget<bool>(
                            title: "Status Aktif",
                            options: [true, false],
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
                              child: InkWell(
                                onTap: () {
                                  _saveTimeLimit();
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

  void _saveTimeLimit() {
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
                      widget.namaController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.deskripsiController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.bataswaktuController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.toleransiController.text,
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
            nama: widget.namaController.text,
            deskripsi: widget.deskripsiController.text,
            batasWaktu: widget.bataswaktuController.text,
            batasToleransi: widget.toleransiController.text,
            statusAktif: _selectedStatus, // Save as boolean
          );

          insertOrUpdateBatasPenggunaan(widget.dbKidztime, bataspenggunaan)
              .then((e) {
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
                detail: [const Text("Data berhasil disimpan")],
                okButtonText: "OK",
                okButtonFunction: () {
                  Navigator.of(context).pop();
                  Get.offAndToNamed('/main-menu');
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
    if (widget.namaController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Nama tidak boleh kosong");
      return false;
    }

    if (widget.deskripsiController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Deskripsi tidak boleh kosong");
      return false;
    }

    if (widget.bataswaktuController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Batas Waktu tidak boleh kosong");
      return false;
    }

    if (widget.toleransiController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Toleransi tidak boleh kosong");
      return false;
    }

    return true;
  }
}
