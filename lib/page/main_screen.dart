import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:kidztime/background_service.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/model/pengaturan.dart';
import 'package:kidztime/page/setup_screen.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  String nama = "user_name";
  late List<Aktivitas> daftarAktivitas = [];

  @override
  void initState() {
    // TODO: implement initState
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
            Container(
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    ),
                    const SubTitleWidget(
                        teks: "(5) Aktivitas Penggunaan Terakhir"),
                    SingleChildScrollView(
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
                                daftarAktivitas.length > 5
                                    ? 5
                                    : daftarAktivitas.length,
                                (index) => AktivitasPenggunanWidget(
                                  dataAktivitas: daftarAktivitas[index],
                                  onclick: () {},
                                ),
                              ),
                      ),
                    ),
                    const SubTitleWidget(teks: "Menu"),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: width * .05,
                        runSpacing: width * .05,
                        children: [
                          MenuWidget(
                            width: width,
                            icon: iconMenu1,
                            title: "Atur Batas Waktu",
                            callBack: () {
                              print("Clicked");
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu2,
                            title: "Atur Jadwal Penggunaan",
                            callBack: () {
                              print("Clicked");
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu3,
                            title: "Lihat Aktivitas Gawai",
                            callBack: () {
                              print("Clicked");
                            },
                          ),
                          MenuWidget(
                            width: width,
                            icon: iconMenu4,
                            title: "Pengaturan Aplikasi",
                            callBack: () {
                              Get.to(
                                () => Setupscreen(),
                                transition: Transition.rightToLeft,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Dummy, deleted on production
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
                    TextButton(
                      onPressed: () async {
                        final service = FlutterBackgroundService();
                        var isRunning = await service.isRunning();
                        isRunning
                            ? FlutterBackgroundService().invoke("stopService")
                            : BackgroundService().start();
                      },
                      child: const Text(
                        "Start / Stop",
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
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
    List<String> splittedTanggal = dataAktivitas.tanggal.split("-");
    String formattedTanggal = "${splittedTanggal[2]}/${splittedTanggal[1]}";

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
                  Text(
                    dataAktivitas.judul,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WidgetUtil().parseHexColor(darkColor),
                    ),
                  ),
                  Text(
                    formattedTanggal,
                    style: const TextStyle(
                      fontSize: 14,
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
