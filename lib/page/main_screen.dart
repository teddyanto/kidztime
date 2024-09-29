import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/model/batasPenggunaan.dart';
import 'package:kidztime/model/pengaturan.dart';
import 'package:kidztime/page/widget/main_screen_widget.dart';
import 'package:kidztime/utils/background_service.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/preferences.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  late List<Aktivitas> daftarAktivitas = [];

  late Bataspenggunaan? _bataspenggunaan;

  String nama = "user_name";
  String temp = "";

  bool _batasWaktuIsRunning = false;
  int _remainingTime = 0;
  Timer _timer = Timer(const Duration(seconds: 0), () {});

  Timer _doubleTapTimer = Timer(const Duration(seconds: 0), () {});

  @override
  void initState() {
    super.initState();

    _bataspenggunaan = null;

    // TESTING AJA, BISA DIPAKE BUAT MUNCULIN APA GITU
    Preferences.getTemp().then((e) {});

    dbKidztime.then((e) {
      getPengaturan(e).then((pengaturan) {
        for (Pengaturan element in pengaturan) {
          setState(() {
            nama = element.nama;
          });
        }
      });

      getAktivitas(e).then((aktivitas) {
        setState(() {
          daftarAktivitas = aktivitas;
        });
      });

      getBatasPenggunaan(e).then((batasPenggunaan) {
        print("getBatasPenggunaan");
        for (var i = 0; i < batasPenggunaan.length; i++) {
          var item = batasPenggunaan[i];
          if (item.statusAktif) {
            setState(() {
              _bataspenggunaan = item;
            });
          }
        }
      });

      final service = FlutterBackgroundService();
      service.isRunning().then((isRunning) {
        if (isRunning) {
          Preferences.getLockTime().then((lockTime) {
            DateTime now = DateTime.now();

            if (now.isBefore(lockTime)) {
              setState(() {
                _remainingTime = lockTime.difference(now).inSeconds;
                _batasWaktuIsRunning = true;
                startTimer();
              });
            }
          });
        }
      });
    });
  }

  void refreshDaftarAktivitas(Future<Database> database) async {
    final db = await database;

    getAktivitas(db).then((data) {
      print("getAktivitas ${data.toString()}");
      setState(() {
        daftarAktivitas = data;
      });
    });
  }

  void startTimer() {
    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (a) async {
        if (_remainingTime == 0) {
          _timer.cancel();
        } else {
          setState(() {
            _remainingTime -= 1;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double paddingHorizontal = 25;

    DateTime now = DateTime.now();
    int year = now.year;
    int monthIndex = now.month;
    int day = now.day;
    int dayIndex = now.weekday;

    String currentDate =
        "${WidgetUtil().getDayName(dayIndex)}, ${day.toString().padLeft(2, '0')} ${WidgetUtil().getMonthName(monthIndex)} $year";

    double padding = 20;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (e) async {
          WidgetUtil().customeDialog(
            context: context,
            title: "Keluar aplikasi ?",
            detail: [],
            okButtonText: "Ya",
            okButtonFunction: () {
              SystemNavigator.pop();
            },
            cancelButtonText: "Batal",
          );
        },
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 160,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      GreetingMainWidget(nama: nama),
                      const SubTitleWidget(
                          teks: "(5) Aktivitas Penggunaan Terakhir"),
                      AktivitasTerakhirWidget(daftarAktivitas: daftarAktivitas),
                      const SubTitleWidget(teks: "Menu"),
                      const SizedBox(
                        height: 20,
                      ),
                      DaftarMenuMainWidget(
                        padding: padding,
                        listMenuWidget: <MenuWidget>[
                          MenuWidget(
                            width: MediaQuery.of(context).size.width,
                            icon: iconMenu1,
                            title: "Batas Waktu",
                            callBack: () async {
                              final result = await Get.toNamed(
                                "/list-time-limit",
                                arguments: {
                                  'batasWaktuIsRunning': _batasWaktuIsRunning,
                                },
                              );

                              if (_batasWaktuIsRunning == false) {
                                setState(() {
                                  _bataspenggunaan = result;
                                  if (_bataspenggunaan != null) {
                                    _batasWaktuIsRunning = false;

                                    int hours = int.parse(_bataspenggunaan!
                                        .batasWaktu
                                        .split(":")[0]);
                                    int minutes = int.parse(_bataspenggunaan!
                                        .batasWaktu
                                        .split(":")[1]);

                                    setState(() {
                                      _remainingTime =
                                          (hours * 3600) + (minutes * 60);
                                    });
                                  }
                                });
                              }
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu2,
                            title: "Jadwal Penggunaan",
                            callBack: () async {
                              // Get.toNamed('/schedule-page');
                              // Get.toNamed('/list-schedule');
                              final result =
                                  await Get.toNamed("/list-schedule");
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu3,
                            title: "Aktivitas Gawai",
                            callBack: () {
                              Get.toNamed('/activity-page');
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu4,
                            title: "Pengaturan Aplikasi",
                            callBack: () {
                              Get.toNamed("/setup-page");
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu5,
                            title: "Cara Penggunaan",
                            callBack: () {
                              Get.toNamed("/how-to-page");
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu6,
                            title: "Tentang aplikasi",
                            callBack: () {
                              Get.toNamed("/about-page");
                            },
                          ),
                          // MenuWidget(
                          //   width: width,
                          //   icon: "",
                          //   title: "Advertisment",
                          //   callBack: () {
                          //     Get.toNamed("/ads-page");
                          //   },
                          // ),
                        ],
                      ),
                      BatasWaktuBarWidget(
                        aktif: _batasWaktuIsRunning,
                        remainingTime: _remainingTime,
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: ClipPath(
                clipper: CurvedAppBarClipper(),
                child: HeaderMainWidget(
                    paddingHorizontal: paddingHorizontal,
                    width: width,
                    currentDate: currentDate),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: _batasWaktuIsRunning
          ? FloatingActionButtonLocation.miniStartDocked
          : FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: _batasWaktuIsRunning
          ? TextButton.icon(
              onPressed: () async {
                if (!_doubleTapTimer.isActive) {
                  _doubleTapTimer = Timer(const Duration(seconds: 3), () {});
                  var snackBar = const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Tekan sekali lagi untuk menghentikan !',
                    ),
                    duration: Duration(seconds: 3),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  return;
                }
                buttonStartStopHandle(
                  context: context,
                );
              },
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Colors.red,
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.stop_circle,
                color: Colors.white,
              ),
              label: const Text(
                "Hentikan batas waktu",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : TextButton.icon(
              onPressed: () async {
                if (_bataspenggunaan != null) {
                  if (!_doubleTapTimer.isActive) {
                    _doubleTapTimer = Timer(const Duration(seconds: 3), () {});
                    var snackBar = const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Tekan sekali lagi untuk memulai !',
                      ),
                      duration: Duration(seconds: 3),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }

                  String batasWaktu = _bataspenggunaan!.batasWaktu;

                  int hours = int.parse(batasWaktu.split(":")[0]);
                  int minutes = int.parse(batasWaktu.split(":")[1]);

                  startTimer();
                  buttonStartStopHandle(
                    context: context,
                    hours: hours,
                    minutes: minutes,
                    seconds: 0,
                  );
                } else {
                  var snackBar = const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Mohon atur batas waktu terlebih dahulu !',
                    ),
                    duration: Duration(seconds: 3),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  // snackBar = const SnackBar(
                  //   behavior: SnackBarBehavior.floating,
                  //   content: Text(
                  //     'Silahkan masuk ke menu `Batas Waktu`',
                  //   ),
                  //   duration: Duration(seconds: 4),
                  // );

                  // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  WidgetUtil().parseHexColor(primaryColor),
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
              label: const Text(
                "Mulai batas waktu",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Future<void> buttonStartStopHandle({
    required BuildContext context,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) async {
    if (hours == 0 && minutes == 0 && seconds == 0) {
      FlutterBackgroundService().invoke('stopService');

      stopService();

      const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Service berhasil dihentikan !',
        ),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _timer.cancel();
      });
    } else {
      await Preferences.setLockTime(
              hours: hours, minutes: minutes, seconds: seconds)
          .then(
        (e) {
          // ============================================
          Aktivitas aktivitas = Aktivitas(
            judul: _bataspenggunaan!.nama,
            deskripsi: _bataspenggunaan!.deskripsi,
            waktu: 0,
            tanggal: DateTime.now().toIso8601String(),
          );

          Preferences.setTempAktivitas(aktivitas: aktivitas);

          // ============================================
          BackgroundService.instance.init();
          BackgroundService().start();

          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            content: const Text(
              'Service berhasil dijalankan !',
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: "batal",
              onPressed: () {
                buttonStartStopHandle(context: context);
              },
            ),
          );
          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          setState(() {
            _batasWaktuIsRunning = true;
          });
        },
      );
    }
  }

  void stopService() {
    updateStatusAktifBatasPenggunaan(dbKidztime, false);

    setState(() {
      _bataspenggunaan = null;
      _batasWaktuIsRunning = false;
    });

    Timer(const Duration(seconds: 3), () {
      refreshDaftarAktivitas(dbKidztime);
    });
  }
}
