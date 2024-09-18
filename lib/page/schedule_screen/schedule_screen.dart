import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/jadwalPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
import 'package:kidztime/page/widget/time_input_widget.dart';
import 'package:kidztime/page/widget/radio_input_widget.dart';
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
  ScheduleEntry _schedule = ScheduleEntry();

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
            titleScreen: "Set Schedule",
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
                    _buildScheduleForm(), // Only one schedule form now
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          _saveSchedule(); // Save the single schedule
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
                            "Simpan Jadwal",
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return CardWidget(
      verticalMargin: 30.0,
      horizontalMargin: 30.0,
      verticalPadding: 40.0,
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
          RadioButtonWidget<bool>(
            title: "Status Aktif",
            options: const [true, false],
            optionLabels: const {true: 'Aktif', false: 'Tidak Aktif'},
            groupValue: _schedule.selectedStatus,
            onChanged: (value) {
              setState(() {
                _schedule.selectedStatus = value ?? true;
              });
            },
          ),
        ],
      ),
    );
  }

  void _saveSchedule() async {
    Database db = await widget.dbKidztime;

    if (_schedule.isValid()) {
      Set<String> processedDays = {};

      for (var day in _schedule.selectedDays.keys) {
        if (_schedule.selectedDays[day] == true &&
            !processedDays.contains(day)) {
          Jadwalpenggunaan jadwalpenggunaan = Jadwalpenggunaan(
            hari: day,
            waktuMulai: _schedule.waktuMulaiController.text,
            waktuAkhir: _schedule.waktuAkhirController.text,
            statusAktif: _schedule.selectedStatus,
          );

          var existingJadwal = await getJadwalByHari(widget.dbKidztime, day);

          if (existingJadwal != null) {
            jadwalpenggunaan.id = existingJadwal.id;
            await updateJadwalPenggunaan(widget.dbKidztime, jadwalpenggunaan);
            print('Data updated in database: $jadwalpenggunaan');
          } else {
            int newId = await insertJadwalPenggunaan(
                widget.dbKidztime, jadwalpenggunaan);
            jadwalpenggunaan.id = newId;
            print('New data added to database: $jadwalpenggunaan');
          }

          processedDays.add(day);

          print('Schedule for $day:');
          print('  Waktu Mulai: ${_schedule.waktuMulaiController.text}');
          print('  Waktu Akhir: ${_schedule.waktuAkhirController.text}');
          print('  Status Aktif: ${_schedule.selectedStatus}');
        }
      }

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
      WidgetUtil().showToast(msg: "Invalid input for schedule entry!");
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