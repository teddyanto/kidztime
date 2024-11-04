import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/notifikasi.dart'; // Create a model for Notifikasi
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/text_input_widget.dart';
import 'package:kidztime/page/widget/time_input_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Controllers
  final TextEditingController judulController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();
  late int? id;

  final Future<Database> dbKidztime = DBKidztime().getDatabase();

  // Variable to store selected time
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    id = null;

    // Handle incoming arguments for updating an existing notification
    if (Get.arguments != null) {
      final args = Get.arguments as Notifikasi;
      id = args.id;
      judulController.text = args.judul;
      detailController.text = args.detail;
      // Convert string time to TimeOfDay if necessary
      int minutes = args.waktu;
      int hours = (minutes / 60).floor();
      minutes = minutes % 60;

      _selectedTime = TimeOfDay(hour: hours, minute: minutes);
      waktuController.text =
          "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Masukkan data notifikasi"),
                        CardWidget(
                          horizontalMargin: 30.0,
                          verticalMargin: 30.0,
                          horizontalPadding: 30.0,
                          verticalPadding: 20.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextInputWidget(
                                maxLength: 50,
                                controller: judulController,
                                title: "Judul Notifikasi",
                                placeholder: "Masukkan judul notifikasi",
                              ),
                              const SizedBox(height: 10.0),
                              TextInputWidget(
                                maxLength: 200,
                                controller: detailController,
                                title: "Detail Notifikasi",
                                placeholder: "Masukkan detail notifikasi",
                                maxLines: 3,
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 10.0),
                              TimeInputWidget(
                                controller: waktuController,
                                title: "Waktu Notifikasi",
                                hint: "Tekan di sini",
                                initialTime: _selectedTime ??
                                    const TimeOfDay(hour: 0, minute: 0),
                              ),
                              const SizedBox(height: 10.0),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    saveNotification();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      WidgetUtil().parseHexColor(darkColor),
                                    ),
                                  ),
                                  child: const Text(
                                    "Simpan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          WidgetUtil().getAppBarV2(
            titleScreen: "Notification",
            callback: () {
              Get.back();
            },
            context: context,
            hasBackButton: true,
          ),
        ],
      ),
    );
  }

  void saveNotification() {
    if (validateInput()) {
      WidgetUtil().customeDialog(
        context: context,
        title: "Simpan data?",
        detail: [
          const Text("Detail Data Notifikasi"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Judul:"),
                    Text("Detail:"),
                    Text("Waktu:"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judulController.text,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(detailController.text,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(waktuController.text,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
        okButtonFunction: () {
          // Convert the waktu string to minutes
          List<String> timeParts = waktuController.text.split(':');
          int totalMinutes =
              int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);

          // Create notification model
          Notifikasi notifikasi = Notifikasi(
              id: id, // Provide a default value if id is null
              judul: judulController.text,
              detail: detailController.text,
              waktu: totalMinutes); // Use the calculated total minutes

          // Save to the database
          insertOrUpdateNotifikasi(dbKidztime, notifikasi).then((_) {
            Navigator.of(context).pop();

            WidgetUtil().showLoadingDialog(context: context);
            Timer(const Duration(seconds: 3), () {
              Navigator.of(context).pop();

              WidgetUtil().customeDialog(
                context: context,
                title: "Berhasil",
                detail: [
                  const Text("Data notifikasi berhasil disimpan"),
                ],
                okButtonText: "OK",
                okButtonFunction: () {
                  print('Data added to database: $notifikasi');
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
    if (judulController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Judul tidak boleh kosong");
      return false;
    }

    if (detailController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Detail tidak boleh kosong");
      return false;
    }

    if (waktuController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Waktu tidak boleh kosong");
      return false;
    }

    return true;
  }
}
