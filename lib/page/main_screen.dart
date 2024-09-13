import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/model/batasPenggunaan.dart';
import 'package:kidztime/model/pengaturan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
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
  late bool _batasWaktuIsRunning = false;
  late Timer _tick;
  late DateTime _dateTimeLeft = DateTime(0, 0, 0, 0, 0, 0);
  late Bataspenggunaan? _bataspenggunaan;

  String nama = "user_name";
  String temp = "";

  @override
  void initState() {
    super.initState();

    _bataspenggunaan = null;

    // Try to stop whatever already running
    // FlutterBackgroundService().invoke("stopService");

    // TESTING AJA, BISA DIPAKE BUAT MUNCULIN APA GITU
    Preferences.getTemp().then((e) {});

    dbKidztime.then((e) {
      getPengaturan(e).then((pengaturan) {
        for (Pengaturan element in pengaturan) {
          nama = element.nama;
        }
      });

      getAktivitas(e).then((aktivitas) {
        daftarAktivitas = aktivitas;
      });

      getBatasPenggunaan(e).then((batasPenggunaan) {
        for (var i = 0; i < batasPenggunaan.length; i++) {
          var item = batasPenggunaan[i];
          if (item.statusAktif) {
            _bataspenggunaan = item;
          }
        }
      }).then((e) {
        final service = FlutterBackgroundService();
        service.isRunning().then((isRunning) {
          if (isRunning) {
            Preferences.getLockTime().then((lockTime) {
              Duration remainingDuration = lockTime.difference(DateTime.now());
              // Get total hours, minutes, and seconds
              int totalHours = remainingDuration.inHours;
              int totalMinutes = remainingDuration.inMinutes;
              int totalSeconds = remainingDuration.inSeconds;

              // Extract hours, minutes, and seconds
              int hours = totalHours;
              int minutes = totalMinutes %
                  60; // Remaining minutes after converting to hours
              int seconds = totalSeconds %
                  60; // Remaining seconds after converting to minutes

              print("Masuk ke getLockTime $remainingDuration");
              _dateTimeLeft = DateTime(0, 0, 0, hours, minutes, seconds);
              startTick(context);
            });
          } else {
            refreshBatasPenggunaan();
          }
        });
      });

      setState(() {});
    });
  }

  void refreshDaftarAktivitas(Future<Database> database) async {
    final db = await database;

    getAktivitas(db).then((data) {
      setState(() {
        daftarAktivitas = data;
      });
    });
  }

  void refreshBatasPenggunaan() {
    if (_bataspenggunaan != null) {
      String batasWaktu = _bataspenggunaan!.batasWaktu;

      int hours = int.parse(batasWaktu.split(":")[0]);
      int minutes = int.parse(batasWaktu.split(":")[1]);
      _dateTimeLeft = DateTime(0, 0, 0, hours, minutes);
    } else {
      _dateTimeLeft = DateTime(0);
    }

    setState(() {});
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeaderMainWidget(
                paddingHorizontal: paddingHorizontal,
                width: width,
                currentDate: currentDate),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            title: "Atur Batas Waktu",
                            callBack: () async {
                              final result =
                                  await Get.toNamed("/list-time-limit");
                              _bataspenggunaan = result;
                              refreshBatasPenggunaan();
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu2,
                            title: "Atur Jadwal Penggunaan",
                            callBack: () {
                              Get.toNamed('/schedule-page');
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu3,
                            title: "Lihat Aktivitas Gawai",
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
                        ],
                      ),
                      Wrap(
                        children: [
                          if (_batasWaktuIsRunning)
                            Wrap(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    buttonStartStopHandle(
                                      context: context,
                                    );
                                  },
                                  icon: const Row(
                                    children: [
                                      FittedBox(
                                          child: Text("Hentikan batas waktu")),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.stop_circle,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    FlutterBackgroundService()
                                        .invoke("setAsForeground");
                                  },
                                  icon: const Row(
                                    children: [
                                      FittedBox(
                                          child: Text("Service ForeGround")),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.slideshow,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    FlutterBackgroundService()
                                        .invoke("setAsBackground");
                                  },
                                  icon: const Row(
                                    children: [
                                      FittedBox(
                                          child: Text("Service BackGround")),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.hide_image_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            IconButton(
                              onPressed: () async {
                                if (_bataspenggunaan != null) {
                                  String batasWaktu =
                                      _bataspenggunaan!.batasWaktu;

                                  int hours =
                                      int.parse(batasWaktu.split(":")[0]);
                                  int minutes =
                                      int.parse(batasWaktu.split(":")[1]);

                                  _dateTimeLeft =
                                      DateTime(0, 0, 0, hours, minutes);

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

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);

                                  snackBar = const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'Silahkan masuk ke menu `Atur Batas Waktu`',
                                    ),
                                    duration: Duration(seconds: 4),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              icon: Row(
                                children: [
                                  FittedBox(
                                    child: Text(
                                      "Mulai batas waktu",
                                      style: TextStyle(
                                        color: _bataspenggunaan == null
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.play_circle,
                                  ),
                                ],
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              Get.toNamed("/times-up");
                            },
                            icon: const Row(
                              children: [
                                FittedBox(child: Text("Kunci device manual")),
                                Icon(Icons.lock)
                              ],
                            ),
                          ),
                        ],
                      ),

                      BatasWaktuBarWidget(
                        width: width,
                        aktif: _batasWaktuIsRunning,
                        timeLeft: _dateTimeLeft,
                      ),
                      // Dummy, deleted on production
                      /*
                      TextButton(
                        onPressed: () async {
                          WidgetUtil().showToast(
                            msg: "Berhasil menambah data aktivitas",
                          );
                          setState(() {
                            Aktivitas baru = Aktivitas(
                              id: daftarAktivitas.length,
                              judul: "Data baru ${daftarAktivitas.length}",
                              deskripsi:
                                  "Ini adaalah deksripsi agak panjang sih tapi yaudah lah ya",
                              waktu: Random().nextInt(10000) + 120,
                              tanggal:
                                  "${year.toString()}-${monthIndex.toString().padLeft(2, "0")}-${day.toString().padLeft(2, "0")}",
                            );
                            daftarAktivitas.insert(0, baru);
                          });
                        },
                        child: Container(
                          width: width,
                          padding: const EdgeInsets.all(5.0),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                10,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Tambah data aktivitas penggunaan",
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          /**
                           * Ini ga kepake sebenernya
                           * 
                           * Jadi intinya background service itu bisa jadi 2 macem
                           * 
                           * taroh di background 
                           * tidak keliatan oleh user (tidak ada notif)
                           * 
                           * sama di foreground
                           * keliatan sama user, ada notif di atasnya
                           * 
                           * Tapi fungsi yg kita pake harus dijadiin background
                           * Jadi kalo di cek di kelas `BackgroundService`
                           * ini di set default "isForegroundMode: false",
                           * biar otomatis di background
                           * 
                           */
                          FlutterBackgroundService().invoke("setAsBackground");
                        },
                        child: const Text(
                          "Set AsBackground",
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          FlutterBackgroundService().invoke("setAsForeground");
                        },
                        child: const Text(
                          "Set AsForeground",
                        ),
                      ),
                      */
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    // Karena kalo kosong semua anggap saja mematikan, bukan menjalankan
    if (hours == 0 && minutes == 0 && seconds == 0) {
      const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Service berhasil dibatalkan !',
        ),
        duration: Duration(seconds: 2),
      );

      stopService();
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      /**
       * Ini logic buat jalanin background service
       * Jadi diisi dulu nilai sharedpreference nya pake
       * "await Preferences.setLockTime"
       * isinya jam, menit, detik berapa lama akan dimainkan
       * 
       * Terus nilai balikkannya jalanin background service
       * 
       * Trial 20 Detik 
       */
      //
      await Preferences.setLockTime(
              hours: hours, minutes: minutes, seconds: seconds)
          .then(
        (e) {
          BackgroundService.instance.init();
          BackgroundService().start();

          startTick(context);

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
        },
      );
    }
  }

  void startTick(BuildContext context) {
    _batasWaktuIsRunning = true;

    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      print("_dateTimeLeft $_dateTimeLeft");
      print("DateTime(0) ${DateTime(0, 0, 0)}");

      if (_dateTimeLeft == DateTime(0, 0, 0)) {
        stopService();

        const snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Service telah selesai !',
          ),
          duration: Duration(seconds: 2),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        _dateTimeLeft = _dateTimeLeft.subtract(const Duration(seconds: 1));
      }

      setState(() {});
    });
  }

  void stopService() {
    FlutterBackgroundService().invoke("stopService");
    DateTime currentTime = DateTime(0);

    // Add new aktivitas
    String batasWaktu = _bataspenggunaan!.batasWaktu;

    int hours = int.parse(batasWaktu.split(":")[0]);
    int minutes = int.parse(batasWaktu.split(":")[1]);

    DateTime totalTime = DateTime(0, 0, 0, hours, minutes);
    Duration alreadyRunning = totalTime.difference(_dateTimeLeft);

    Aktivitas aktivitas = Aktivitas(
      judul: _bataspenggunaan!.nama,
      deskripsi: _bataspenggunaan!.deskripsi,
      waktu: alreadyRunning.inSeconds,
      tanggal: DateTime.now().toIso8601String(),
    );

    insertAktivitas(dbKidztime, aktivitas);

    _batasWaktuIsRunning = false;
    _dateTimeLeft = currentTime;
    _tick.cancel();
    _bataspenggunaan = null;

    Preferences.setLockTime(hours: 0, minutes: 0, seconds: 0);
    updateStatusAktifBatasPenggunaan(dbKidztime, false);
    refreshDaftarAktivitas(dbKidztime);

    setState(() {});
  }
}

class BatasWaktuBarWidget extends StatelessWidget {
  const BatasWaktuBarWidget({
    super.key,
    required this.width,
    required this.aktif,
    required this.timeLeft,
  });

  final double width;
  final bool aktif;

  final DateTime timeLeft;

  @override
  Widget build(BuildContext context) {
    int hours = timeLeft.hour;
    int minutes = timeLeft.minute;
    int seconds = timeLeft.second;

    String timeFormatted = [
      hours.toString().padLeft(2, "0"),
      minutes.toString().padLeft(2, "0"),
      seconds.toString().padLeft(2, "0"),
    ].join(":");

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: width,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: aktif ? Colors.red : Colors.grey,
            borderRadius: const BorderRadius.all(
              Radius.circular(
                5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Batas waktu sedang berjalan ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () => {
                  WidgetUtil().customeDialog(
                    context: context,
                    title: "Informasi",
                    detail: [],
                    okButtonText: "Ok",
                    okButtonFunction: () {
                      Navigator.of(context).pop();
                    },
                  )
                },
                splashColor: WidgetUtil().parseHexColor(darkColor),
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FittedBox(
            child: Text(
              timeFormatted,
              style: const TextStyle(
                fontSize: 400,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class DaftarMenuMainWidget extends StatelessWidget {
  const DaftarMenuMainWidget({
    super.key,
    required this.padding,
    required this.listMenuWidget,
  });

  final List<MenuWidget> listMenuWidget;
  final double padding;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double spacing = 10;
    int axisCount = 3;
    int row = (listMenuWidget.length / axisCount).ceil();

    double height = (width - (padding * 2)) - (spacing * (axisCount - 1));
    height = height / axisCount * row;
    height = height + (spacing * (row - 1));

    return SizedBox(
      width: width,
      height: height,
      child: GridView.count(
        primary: false,
        crossAxisCount: axisCount,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(0),
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        children: listMenuWidget.map(
          (MenuWidget widget) {
            return widget;
          },
        ).toList(),
      ),
    );
  }
}

class AktivitasTerakhirWidget extends StatelessWidget {
  const AktivitasTerakhirWidget({
    super.key,
    required this.daftarAktivitas,
  });

  final List<Aktivitas> daftarAktivitas;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: daftarAktivitas.isEmpty
            ? [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 10,
                  ),
                  child: Text(
                    "Belum ada aktivitas penggunaan",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ]
            : List.generate(
                daftarAktivitas.length > 5 ? 5 : daftarAktivitas.length,
                (index) => AktivitasPenggunanWidget(
                  dataAktivitas: daftarAktivitas[index],
                  onclick: () {},
                ),
              ),
      ),
    );
  }
}

class GreetingMainWidget extends StatelessWidget {
  const GreetingMainWidget({
    super.key,
    required this.nama,
  });

  final String nama;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          "Selamat Datang, ",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          "$nama ❤",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

class HeaderMainWidget extends StatelessWidget {
  const HeaderMainWidget({
    super.key,
    required this.paddingHorizontal,
    required this.width,
    required this.currentDate,
  });

  final double paddingHorizontal;
  final double width;
  final String currentDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        paddingHorizontal,
        50,
        paddingHorizontal,
        15,
      ),
      color: WidgetUtil().parseHexColor(primaryColor),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      right: 30,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: WidgetUtil().parseHexColor(darkColor),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      "KidzTime",
                      style: TextStyle(
                        color: WidgetUtil().parseHexColor(darkColor),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: WidgetUtil().parseHexColor(darkColor),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                width: 70,
                child: Hero(
                  tag: 'apps-icon',
                  child: Image.asset(
                    logo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "Aplikasi Pengendalian Gawai\nMengatur dan Mengendalikan Penggunaan Gawai Anak dengan Mudah",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: WidgetUtil().parseHexColor(darkColor),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.callBack,
  });

  final double width;
  final String icon;
  final String title;
  final Function callBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WidgetUtil().parseHexColor(primaryColor),
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        splashColor: WidgetUtil().parseHexColor(darkColor),
        onTap: () {
          callBack();
        },
        child: Container(
          padding: const EdgeInsets.all(
            5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: WidgetUtil().parseHexColor(darkColor),
              width: 3,
            ),
          ),
          child: SizedBox(
            width: width * .22,
            height: width * .22,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  width: width * .11,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubTitleWidget extends StatelessWidget {
  const SubTitleWidget({
    super.key,
    required this.teks,
  });

  final String teks;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: WidgetUtil().parseHexColor(primaryColor),
          ),
        ),
      ),
      child: Text(
        teks,
        style: TextStyle(
          color: WidgetUtil().parseHexColor(primaryColor),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AktivitasPenggunanWidget extends StatelessWidget {
  const AktivitasPenggunanWidget({
    super.key,
    required this.dataAktivitas,
    required this.onclick,
  });

  final Aktivitas dataAktivitas;
  final Function onclick;

  @override
  Widget build(BuildContext context) {
    DateTime tanggal = DateTime.parse(dataAktivitas.tanggal);

    String formattedTanggal =
        "${tanggal.day.toString().padLeft(2, "0")}/${tanggal.month.toString().padLeft(2, "0")}";

    int jam = (dataAktivitas.waktu / 3600).floor();
    int menit = (dataAktivitas.waktu % 3600 / 60).floor();
    int detik = dataAktivitas.waktu % 60;

    return InkWell(
      onTap: () {
        WidgetUtil().showToast(msg: "Aktivitas penggunaan click");
        onclick();
      },
      child: CardWidget(
        verticalMargin: 10,
        horizontalMargin: 10,
        verticalPadding: 10,
        horizontalPadding: 10,
        isFullWidth: false,
        child: SizedBox(
          width: 185,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      dataAktivitas.judul,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WidgetUtil().parseHexColor(darkColor),
                      ),
                    ),
                  ),
                  Text(
                    formattedTanggal,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                dataAktivitas.deskripsi,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, //
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "$jam jam $menit menit $detik detik",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
