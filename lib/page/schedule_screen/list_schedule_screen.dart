import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/jadwalPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
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

  @override
  void initState() {
    super.initState();
    refreshJadwal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtil().getAppBar(),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        color: WidgetUtil().parseHexColor(darkColor),
        child: TextButton.icon(
          onPressed: () async {
            final result = await Get.toNamed("/schedule-page");
            if (result != null && result == "added") {
              refreshJadwal();
              print(result);
            }
          },
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: const Text(
            "Tambah jadwal baru",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWidget(
            titleScreen: "Jadwal Tersimpan",
            callback: () {
              Get.back(
                result: jadwalAktif,
              );
            },
            hasBackButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          hintText: "Pencarian", // Placeholder
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        autofocus: false,
                        controller: searchController,
                        onChanged: (value) {
                          List<Jadwalpenggunaan> temp = [];

                          if (timerSearch.isActive) {
                            timerSearch.cancel();
                          }
                          print(listJadwal);

                          timerSearch =
                              Timer(const Duration(milliseconds: 500), () {
                            if (value == "") {
                              temp = listJadwal;
                            } else {
                              for (var i = 0; i < listJadwal.length; i++) {
                                var item = listJadwal[i];
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
                            resultSearch = temp;
                            setState(() {});
                          });
                        },
                      ),
                      Positioned(
                        right: searchController.text != "" ? 0 : -100,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              searchController.text = "";
                            });
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: resultSearch.length,
                      itemBuilder: (context, index) {
                        var item = resultSearch[index];

                        return Dismissible(
                          key: Key(item.id.toString()),
                          onDismissed: (direction) {
                            handleDeleteJadwal(index, context);
                          },
                          direction: item.statusAktif
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
                                    item.statusAktif
                                        ? darkColor
                                        : primaryColor),
                                width: 4,
                              ),
                              right: BorderSide(
                                color: WidgetUtil().parseHexColor(
                                    item.statusAktif
                                        ? darkColor
                                        : primaryColor),
                                width: 4,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.hari,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: WidgetUtil().parseHexColor(
                                          item.statusAktif
                                              ? darkColor
                                              : primaryColor,
                                        ),
                                      ),
                                      child: Text(
                                        item.statusAktif
                                            ? "Sedang Aktif"
                                            : "Tidak aktif",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Waktu Mulai: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Icon(Icons.access_time),
                                            Text(
                                              item.waktuMulai,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                8), // Add vertical space between "Waktu Mulai" and "Waktu Akhir"
                                        Row(
                                          children: [
                                            const Text("Waktu Akhir: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Icon(Icons.access_time),
                                            Text(
                                              item.waktuAkhir,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      children: [
                                        if (!item.statusAktif)
                                          IconButton.filledTonal(
                                            color: Colors.red,
                                            onPressed: () {
                                              handleDeleteJadwal(
                                                  index, context);
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                            ),
                                          ),
                                        if (!item.statusAktif)
                                          IconButton.filledTonal(
                                            color: WidgetUtil()
                                                .parseHexColor(darkColor),
                                            onPressed: () async {
                                              final result = await Get.toNamed(
                                                "/time-limit",
                                                arguments: item,
                                              );
                                              refreshJadwal();
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                            ),
                                          ),
                                        if (!item.statusAktif)
                                          IconButton.filledTonal(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            onPressed: () {
                                              handleActivationJadwal(
                                                  item, context);
                                            },
                                            icon: const Text(
                                              "Aktifkan",
                                            ),
                                          )
                                        else
                                          IconButton.filledTonal(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            onPressed: () {
                                              updateStatusAktifJadwal(
                                                      dbKidztime, false)
                                                  .then((e) {
                                                refreshJadwal();
                                              });
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
                                    )
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
          )
        ],
      ),
    );
  }

  void handleActivationJadwal(Jadwalpenggunaan item, BuildContext context) {
    Jadwalpenggunaan updateItem = Jadwalpenggunaan(
      id: item.id,
      hari: item.hari,
      waktuMulai: item.waktuMulai,
      waktuAkhir: item.waktuAkhir,
      statusAktif: true,
    );
    updateStatusAktifJadwal(dbKidztime, true).then((e) {
      refreshJadwal();
    });
  }

  Future<void> handleDeleteJadwal(int index, BuildContext context) async {
    var result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus jadwal ini?"),
        actions: [
          TextButton(
            onPressed: () {
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

        // Example: Additional logic for active schedules if needed
        // (Modify based on your app's requirements)
        jadwalAktif = null;
        for (var i = 0; i < jadwalPenggunaan.length; i++) {
          var item = jadwalPenggunaan[i];
          if (item.statusAktif) {
            jadwalAktif = item;
          }
        }

        setState(() {});
        print("jadwalAktif ${jadwalAktif?.hari}");
      });
    });
  }
}
