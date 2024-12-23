import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/jadwalPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/time_input_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleScreen extends StatefulWidget {
  ScheduleScreen({super.key});

  late Future<Database> dbKidztime = DBKidztime().getDatabase();

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleEntry _schedule = ScheduleEntry();
  late Jadwalpenggunaan _jadwalpenggunaan;
  late int? id;

  @override
  void initState() {
    super.initState();
    id = null;

    if (Get.arguments != null) {
      final args = Get.arguments;
      _jadwalpenggunaan = args;

      id = _jadwalpenggunaan.id;
      _schedule.waktuMulaiController.text = _jadwalpenggunaan.waktuMulai;
      _schedule.waktuAkhirController.text = _jadwalpenggunaan.waktuAkhir;

      for (var day in _jadwalpenggunaan.hari.split(",")) {
        _schedule.selectedDays[day] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var hasbackbutton = true;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: height,
            width: width,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    const Text("Masukkan batas penggunaan terjadwal"),
                    _buildScheduleForm(), // Only one schedule form now
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          WidgetUtil().getAppBarV2(
            titleScreen: "Set Schedule",
            callback: () {
              Get.back();
            },
            context: context,
            hasBackButton: true,
          )
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return CardWidget(
      verticalMargin: 30.0,
      horizontalMargin: 30.0,
      verticalPadding: 20.0,
      horizontalPadding: 30.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Hari'),
          Column(
            children: _schedule.selectedDays.keys.map((day) {
              return CheckboxListTile(
                title: Text(day),
                value: _schedule.selectedDays[day],
                onChanged: (value) {
                  setState(() {
                    _schedule.selectedDays[day] = value ?? false;
                  });
                },
              );
            }).toList(),
          ),
          TimeInputWidget(
            title: "Waktu Mulai",
            controller: _schedule.waktuMulaiController,
            hint: "Tekan di sini",
            initialTime: _schedule.getWaktuMulai(),
          ),
          const SizedBox(height: 10.0),
          TimeInputWidget(
            title: "Waktu Akhir",
            controller: _schedule.waktuAkhirController,
            hint: "Tekan di sini",
            initialTime: _schedule.getWaktuAkhir(),
          ),
          const SizedBox(height: 10.0),
          // RadioButtonWidget<bool>(
          //   title: "Status Aktif",
          //   options: const [true, false],
          //   optionLabels: const {true: 'Aktif', false: 'Tidak Aktif'},
          //   groupValue: _schedule.selectedStatus,
          //   onChanged: (value) {
          //     setState(() {
          //       _schedule.selectedStatus = value ?? true;
          //     });
          //   },
          // ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _saveSchedule(); // Save the single schedule
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  WidgetUtil().parseHexColor(darkColor),
                ),
              ),
              child: const Text(
                "Simpan Jadwal",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSchedule() async {
    Database db = await widget.dbKidztime;

    List<String> days = [];
    if (_schedule.isValid()) {
      for (var day in _schedule.selectedDays.keys) {
        if (_schedule.selectedDays[day] == true) {
          days.add(day);
        }
      }

      Jadwalpenggunaan jadwalpenggunaan = Jadwalpenggunaan(
        hari: days.join(","),
        waktuMulai: _schedule.waktuMulaiController.text,
        waktuAkhir: _schedule.waktuAkhirController.text,
        statusAktif: false,
      );

      if (id == null) {
        insertJadwalPenggunaan(widget.dbKidztime, jadwalpenggunaan);

        print('New data added to database: $jadwalpenggunaan');
      } else {
        jadwalpenggunaan.id = id;
        updateJadwalPenggunaan(widget.dbKidztime, jadwalpenggunaan);

        print('Data Update to database: $jadwalpenggunaan');
      }

      print('Schedule for $days');
      print('  Waktu Mulai: ${_schedule.waktuMulaiController.text}');
      print('  Waktu Akhir: ${_schedule.waktuAkhirController.text}');
      print('  Status Aktif: ${_schedule.selectedStatus}');

      WidgetUtil().customeDialog(
        context: context,
        title: "Berhasil",
        detail: [const Text("Semua data berhasil disimpan")],
        okButtonText: "OK",
        okButtonFunction: () {
          Navigator.of(context).pop();
          // Get.offAndToNamed('/list-schedule');
          Get.back(result: "added");
        },
      );
    } else {
      WidgetUtil().showToast(msg: "Mohon isi data dengan benar!");
    }
  }
}

class ScheduleEntry {
  TextEditingController waktuMulaiController = TextEditingController();
  TextEditingController waktuAkhirController = TextEditingController();
  bool selectedStatus = true;
  Map<String, bool> selectedDays = {
    'Senin': false,
    'Selasa': false,
    'Rabu': false,
    'Kamis': false,
    'Jumat': false,
    'Sabtu': false,
    'Minggu': false,
  };

  TimeOfDay getWaktuMulai() {
    return waktuMulaiController.text.isEmpty
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: int.parse(waktuMulaiController.text.split(":")[0]),
            minute: int.parse(waktuMulaiController.text.split(":")[1]),
          );
  }

  TimeOfDay getWaktuAkhir() {
    return waktuAkhirController.text.isEmpty
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: int.parse(waktuAkhirController.text.split(":")[0]),
            minute: int.parse(waktuAkhirController.text.split(":")[1]),
          );
  }

  bool isValid() {
    return waktuMulaiController.text.isNotEmpty &&
        waktuAkhirController.text.isNotEmpty;
  }
}
