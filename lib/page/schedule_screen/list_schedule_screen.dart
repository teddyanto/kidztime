import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/batasPenggunaan.dart';
import 'package:kidztime/model/jadwalPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ListScheduleScreen extends StatefulWidget {
  const ListScheduleScreen({super.key});

  @override
  State<ListScheduleScreen> createState() => _ListScheduleScreenState();
}

class _ListScheduleScreenState extends State<ListScheduleScreen> {
  late TextEditingController searchController = TextEditingController();
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  late List<Jadwalpenggunaan> listJadwal = [];
  late List<Jadwalpenggunaan> resultSearch = [];
  late Timer timerSearch = Timer(Duration.zero, () {});
  late Jadwalpenggunaan? jadwalAktif;
  late String currentDayName;
  late int currentTime;
  late bool batasWaktuIsRunning;

  @override
  void initState() {
    super.initState();

    DateTime date = DateTime.now();
    int dayIndex = date.weekday;
    int hourIndex = date.hour;
    int minuteIndex = date.minute;
    currentTime = (hourIndex * 60) + minuteIndex;
    currentDayName = WidgetUtil().getDayName(dayIndex);

    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;

      setState(() {
        batasWaktuIsRunning = args['batasWaktuIsRunning'];
      });
    }

    refreshJadwal();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: jadwalAktif);

        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: height,
              width: width,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 120,
                    ),
                    Stack(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            hintText: "Pencarian",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          controller: searchController,
                          onChanged: (value) {
                            List<Jadwalpenggunaan> temp = [];

                            if (timerSearch.isActive) {
                              timerSearch.cancel();
                            }

                            timerSearch =
                                Timer(const Duration(milliseconds: 500), () {
                              if (value.isEmpty) {
                                temp = listJadwal;
                              } else {
                                for (var item in listJadwal) {
                                  if (item.hari
                                          .toUpperCase()
                                          .contains(value.toUpperCase()) ||
                                      item.waktuMulai
                                          .toUpperCase()
                                          .contains(value.toUpperCase())) {
                                    temp.add(item);
                                  }
                                }
                              }

                              setState(() {
                                resultSearch = temp;
                              });
                            });
                          },
                        ),
                        Positioned(
                          right: searchController.text.isNotEmpty ? 0 : -100,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.text = "";
                                resultSearch = listJadwal;
                              });
                            },
                            icon: const Icon(Icons.cancel),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 30,
                        ),
                        itemCount: resultSearch.length,
                        itemBuilder: (context, index) {
                          // var entry =
                          //     groupJadwal(resultSearch).entries.elementAt(index);
                          // var items = entry.value;

                          // // Use the first item for display purposes
                          // var item = items.first;
                          var item = resultSearch[index];
                          var days = item.hari.split(",");
                          int waktuMulaiJam =
                              int.parse(item.waktuMulai.split(":")[0]);
                          int waktuMulaiMenit =
                              int.parse(item.waktuMulai.split(":")[1]);

                          int finalWaktuMulai =
                              (waktuMulaiJam * 60) + waktuMulaiMenit;

                          int waktuAkhirJam =
                              int.parse(item.waktuAkhir.split(":")[0]);
                          int waktuAkhirMenit =
                              int.parse(item.waktuAkhir.split(":")[1]);

                          int finalWaktuAkhir =
                              (waktuAkhirJam * 60) + waktuAkhirMenit;

                          bool canBeActivated = false;
                          if (finalWaktuMulai <= currentTime &&
                              finalWaktuAkhir >= currentTime &&
                              item.hari.contains(currentDayName)) {
                            canBeActivated = true;
                          }

                          return Dismissible(
                            key: Key(item.id.toString()),
                            onDismissed: (direction) {
                              handleDeleteJadwal(index, context);
                            },
                            direction: (item.statusAktif || batasWaktuIsRunning)
                                ? DismissDirection.none
                                : DismissDirection.startToEnd,
                            child: CardWidget(
                              verticalMargin: 10,
                              horizontalMargin: 0,
                              verticalPadding: 15,
                              horizontalPadding: 10,
                              border: Border(
                                top: BorderSide(
                                  color: WidgetUtil().parseHexColor(
                                    item.statusAktif ? darkColor : primaryColor,
                                  ),
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Jadwal Harian",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: item.statusAktif
                                              ? Colors.black
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: WidgetUtil().parseHexColor(
                                            item.statusAktif
                                                ? darkColor
                                                : primaryColor,
                                          ),
                                        ),
                                        child: Text(
                                          item.statusAktif
                                              ? "Sedang Aktif"
                                              : "Tidak Aktif",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Colors.black54),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Mulai: ${item.waktuMulai} - Akhir: ${item.waktuAkhir}",
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  getDays(days),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!item.statusAktif)
                                        IconButton.filledTonal(
                                          color: Colors.red,
                                          onPressed: () {
                                            if (!batasWaktuIsRunning) {
                                              handleDeleteJadwal(
                                                  index, context);
                                            } else {
                                              infoBatasWaktuIsRunning();
                                            }
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                      if (!item.statusAktif)
                                        IconButton.filledTonal(
                                          color: WidgetUtil()
                                              .parseHexColor(darkColor),
                                          onPressed: () async {
                                            if (!batasWaktuIsRunning) {
                                              final result = await Get.toNamed(
                                                "/schedule-page",
                                                arguments: item,
                                              );
                                              refreshJadwal();
                                            } else {
                                              infoBatasWaktuIsRunning();
                                            }
                                          },
                                          icon: const Icon(Icons.edit),
                                        ),
                                      if (!item.statusAktif && canBeActivated)
                                        IconButton.filledTonal(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          onPressed: () {
                                            if (!batasWaktuIsRunning) {
                                              handleActivationJadwal(
                                                  item, context);
                                            } else {
                                              infoBatasWaktuIsRunning();
                                            }
                                          },
                                          icon: const Text("Aktifkan"),
                                        )
                                      else if (item.statusAktif)
                                        IconButton.filledTonal(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          onPressed: () {
                                            if (!batasWaktuIsRunning) {
                                              updateStatusAktifJadwal(
                                                      dbKidztime, false)
                                                  .then((e) {
                                                refreshJadwal();
                                              });
                                            } else {
                                              infoBatasWaktuIsRunning();
                                            }
                                          },
                                          icon: const Text(
                                            "Nonaktifkan",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WidgetUtil().getAppBarV2(
              titleScreen: "Jadwal Tersimpan",
              callback: () {
                Get.back(result: jadwalAktif);
              },
              context: context,
              hasBackButton: true,
            )
          ],
        ),
        bottomSheet: Container(
          width: MediaQuery.of(context).size.width,
          color: WidgetUtil().parseHexColor(darkColor),
          child: TextButton.icon(
            onPressed: () async {
              final result = await Get.toNamed("/schedule-page");
              if (result != null && result == "added") {
                refreshJadwal();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Tambah jadwal baru",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Wrap getDays(days) {
    List<String> day = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return Wrap(
      spacing: 3.0,
      runSpacing: 3.0,
      children: List.generate(7, (i) {
        bool hasSchedule =
            days.any((e) => e.toString().toUpperCase() == day[i].toUpperCase());

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: hasSchedule
                ? WidgetUtil().parseHexColor(darkColor)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            day[i],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasSchedule ? Colors.white : Colors.black54,
            ),
          ),
        );
      }),
    );
  }

  Map<String, List<Jadwalpenggunaan>> groupJadwal(
      List<Jadwalpenggunaan> jadwals) {
    Map<String, List<Jadwalpenggunaan>> groupedJadwals = {};

    for (var jadwal in jadwals) {
      String key = "${jadwal.waktuMulai}-${jadwal.waktuAkhir}";

      if (!groupedJadwals.containsKey(key)) {
        groupedJadwals[key] = [];
      }
      groupedJadwals[key]!.add(jadwal);
    }

    return groupedJadwals;
  }

  void handleActivationJadwal(Jadwalpenggunaan item, BuildContext context) {
    Jadwalpenggunaan updateItem = Jadwalpenggunaan(
      id: item.id,
      hari: item.hari,
      waktuMulai: item.waktuMulai,
      waktuAkhir: item.waktuAkhir,
      statusAktif: true,
    );

    updateStatusAktifJadwal(dbKidztime, false).then((e) {
      updateJadwalPenggunaan(dbKidztime, updateItem).then((e) {
        refreshJadwal();
      });
    });

    updateStatusAktifBatasPenggunaan(dbKidztime, false);
  }

  Future<void> handleDeleteJadwal(int index, BuildContext context) async {
    Jadwalpenggunaan tempRemove = resultSearch[index];

// Remove the item from the list
    setState(() {
      resultSearch.removeAt(index);
    });

    var result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus jadwal ini?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                resultSearch.insert(index, tempRemove);
              });

              Navigator.pop(context, false);
            },
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (result) {
      if (resultSearch[index].id != null) {
        await deleteJadwalPenggunaan(dbKidztime, resultSearch[index].id!);
      }
      refreshJadwal();
    }
  }

  void refreshJadwal() {
    dbKidztime.then((db) {
      getAllJadwalPenggunaan(db).then((jadwalPenggunaan) {
        listJadwal = jadwalPenggunaan;
        resultSearch = jadwalPenggunaan;
        jadwalAktif = null;

        for (var i = 0; i < listJadwal.length; i++) {
          var item = listJadwal[i];
          if (item.statusAktif) {
            jadwalAktif = item;
          }
        }

        print("batasanPenggunaanAktif ${jadwalAktif?.id}");

        setState(() {});
      });
    });
  }

  void infoBatasWaktuIsRunning() {
    var snackBar = const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Aktifitas tidak bisa dilakukan sekarang, batas waktu sedang berjalan !',
      ),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
