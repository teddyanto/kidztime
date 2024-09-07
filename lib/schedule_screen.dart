import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/jadwalPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/dropdown_input_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
import 'package:kidztime/page/widget/radio_input_widget.dart';
import 'package:kidztime/page/widget/time_input_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleScreen extends StatefulWidget {
  ScheduleScreen({super.key});

  late TextEditingController waktuMulaiController = TextEditingController();
  late TextEditingController waktuAkhirController = TextEditingController();

  late Future<Database> dbKidztime = DBKidztime().getDatabase();

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _selectedStatus = true;
  String? selectedDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text("Please set a gadget usage schedule"),
                    CardWidget(
                      verticalMargin: 30.0,
                      horizontalMargin: 30.0,
                      verticalPadding: 40.0,
                      horizontalPadding: 30.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownInputWidget(
                            title: 'Pilih Hari',
                            items: const [
                              'Senin',
                              'Selasa',
                              'Rabu',
                              'Kamis',
                              'Jumat',
                              'Sabtu',
                              'Minggu'
                            ],
                            value: selectedDay,
                            onChanged: (value) {
                              setState(() {
                                selectedDay = value;
                              });
                            },
                          ),
                          TimeInputWidget(
                            title: "Waktu Mulai",
                            controller: widget.waktuMulaiController,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TimeInputWidget(
                            title: "Waktu Akhir",
                            controller: widget.waktuAkhirController,
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
                            child: InkWell(
                              onTap: () {
                                _saveSchedule();
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              splashColor: Colors.amber,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  color: WidgetUtil().parseHexColor(darkColor),
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
    );
  }

  void _saveSchedule() async {
    if (validateInput()) {
      Database db = await widget.dbKidztime;
      WidgetUtil().customeDialog(
        context: context,
        title: "Simpan data?",
        detail: [
          const Text("Simpan data jadwal penggunaan gadget?"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hari"),
                    Text("Waktu Mulai"),
                    Text("Waktu Akhir"),
                    Text("Status Aktif"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDay ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.waktuMulaiController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.waktuAkhirController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _selectedStatus ? "Aktif" : "Tidak Aktif",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        okButtonFunction: () async {
          // Create Jadwalpenggunaan instance
          Jadwalpenggunaan jadwalpenggunaan = Jadwalpenggunaan(
            hari: selectedDay ?? "",
            waktuMulai: widget.waktuMulaiController.text,
            waktuAkhir: widget.waktuAkhirController.text,
            statusAktif: _selectedStatus,
          );

          // Check if a record with the same 'hari' exists
          var existingJadwal =
              await getJadwalByHari(widget.dbKidztime, selectedDay);

          if (existingJadwal != null) {
            // If the record exists, update the existing entry
            jadwalpenggunaan.id = existingJadwal.id; // Ensure id is mutable
            await updateJadwalPenggunaan(widget.dbKidztime, jadwalpenggunaan);
            print('Data updated in database: $jadwalpenggunaan');
          } else {
            // If no record exists, insert a new entry and get the ID
            int newId = await insertJadwalPenggunaan(
                widget.dbKidztime, jadwalpenggunaan);
            jadwalpenggunaan.id = newId; // Update model with the new ID
            print('New data added to database: $jadwalpenggunaan');
          }

          // Close the dialog and show success message
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
        },
        okButtonText: "Simpan",
        cancelButtonText: "Batal",
      );
    }
  }

  bool validateInput() {
    if (selectedDay == null ||
        widget.waktuMulaiController.text.isEmpty ||
        widget.waktuAkhirController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Harap isi semua kolom!");
      return false;
    }
    if (widget.waktuMulaiController.text.length < 5 ||
        widget.waktuAkhirController.text.length < 5) {
      WidgetUtil().showToast(msg: "Format waktu salah!");
      return false;
    }
    if (widget.waktuMulaiController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Waktu mulai tidak boleh kosong!");
      return false;
    }
    if (widget.waktuAkhirController.text.isEmpty) {
      WidgetUtil().showToast(msg: "Waktu akhir tidak boleh kosong!");
      return false;
    }

    return true;
  }
}
