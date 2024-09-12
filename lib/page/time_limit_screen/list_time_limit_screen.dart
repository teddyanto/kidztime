import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/batasPenggunaan.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ListTimeLimitScreen extends StatefulWidget {
  const ListTimeLimitScreen({super.key});

  @override
  State<ListTimeLimitScreen> createState() => _ListTimeLimitScreenState();
}

class _ListTimeLimitScreenState extends State<ListTimeLimitScreen> {
  late TextEditingController searchController = TextEditingController();
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  late List<Bataspenggunaan> listBatasPenggunaan = [];

  late List<Bataspenggunaan> resultSearch = [];
  late Timer timerSearch = Timer(Duration.zero, () {});
  late Bataspenggunaan? batasanPenggunaanAktif;

  @override
  void initState() {
    super.initState();

    refreshBatasPenggunaan();
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
              final result = await Get.toNamed("/time-limit");
              if (result != null && result == "added") {
                refreshBatasPenggunaan();
                print(result);
              }
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              "Tambah batasan baru",
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
              titleScreen: "Time Limit Saved",
              callback: () {
                Get.back(
                  result: batasanPenggunaanAktif,
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
                                Radius.circular(
                                  10.0,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  10.0,
                                ),
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          autofocus: false,
                          controller: searchController,
                          onChanged: (value) {
                            List<Bataspenggunaan> temp = [];

                            if (timerSearch.isActive) {
                              timerSearch.cancel();
                            }
                            print(listBatasPenggunaan);

                            timerSearch =
                                Timer(const Duration(milliseconds: 500), () {
                              if (value == "") {
                                print("masuk sini");
                                temp = listBatasPenggunaan;
                              } else {
                                print("masuk sini 2");
                                for (var i = 0;
                                    i < listBatasPenggunaan.length;
                                    i++) {
                                  var item = listBatasPenggunaan[i];
                                  print(value);
                                  if (item.nama
                                          .toUpperCase()
                                          .contains(value.toUpperCase()) ||
                                      item.deskripsi
                                          .toUpperCase()
                                          .contains(value.toUpperCase())) {
                                    temp.add(item);
                                  }
                                }
                              }
                              print(temp);
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
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 50,
                        ),
                        child: ListView.builder(
                          itemCount: resultSearch.length,
                          itemBuilder: (context, index) {
                            var item = resultSearch[index];

                            return Dismissible(
                              key: Key(item.id.toString()),
                              onDismissed: (direction) {
                                handleDeleteBatasPengguna(index, context);
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
                                          : primaryColor,
                                    ),
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: WidgetUtil().parseHexColor(
                                      item.statusAktif
                                          ? darkColor
                                          : primaryColor,
                                    ),
                                    width: 4,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
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
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Text("Deskripsi : "),
                                    Text(
                                      item.deskripsi,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 3,
                                          children: [
                                            const Icon(Icons.alarm),
                                            Text(
                                              item.batasWaktu,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Icon(Icons.alarm_add),
                                            Text(
                                              item.batasToleransi,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Wrap(
                                          children: [
                                            if (!item.statusAktif)
                                              IconButton.filledTonal(
                                                color: Colors.red,
                                                onPressed: () {
                                                  handleDeleteBatasPengguna(
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
                                                  final result =
                                                      await Get.toNamed(
                                                    "/time-limit",
                                                    arguments: item,
                                                  );
                                                  refreshBatasPenggunaan();
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                ),
                                              ),
                                            if (!item.statusAktif)
                                              IconButton.filledTonal(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                                onPressed: () {
                                                  handleActivationBatasWaktu(
                                                      item, context);
                                                },
                                                icon: const Text(
                                                  "Aktifkan",
                                                ),
                                              )
                                            else
                                              IconButton.filledTonal(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                                onPressed: () {
                                                  updateStatusAktifBatasPenggunaan(
                                                          dbKidztime, false)
                                                      .then((e) {
                                                    refreshBatasPenggunaan();
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
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  void handleActivationBatasWaktu(Bataspenggunaan item, BuildContext context) {
    Bataspenggunaan updateItem = Bataspenggunaan(
      id: item.id,
      nama: item.nama,
      deskripsi: item.deskripsi,
      batasWaktu: item.batasWaktu,
      batasToleransi: item.batasToleransi,
      statusAktif: true,
    );

    updateStatusAktifBatasPenggunaan(dbKidztime, false).then((e) {
      insertOrUpdateBatasPenggunaan(dbKidztime, updateItem).then((e) {
        refreshBatasPenggunaan();
      });
    });
  }

  void handleDeleteBatasPengguna(int index, BuildContext context) {
    Bataspenggunaan tempRemove = resultSearch[index];

    // Remove the item from the list
    setState(() {
      resultSearch.removeAt(index);
    });

    // Handle the deletion, and add logic for undoing the deletion if needed
    Timer timerDelete = Timer(const Duration(seconds: 4), () {
      deleteBatasPenggunaanById(dbKidztime, tempRemove.id ?? 0);
    });

    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: const Text('Batas waktu berhasil dihapus!'),
      action: SnackBarAction(
        label: "batal",
        onPressed: () {
          // Reinsert the item if the action is canceled
          setState(() {
            resultSearch.insert(index, tempRemove);
          });
          timerDelete.cancel();
        },
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void refreshBatasPenggunaan() {
    dbKidztime.then((e) {
      getBatasPenggunaan(e).then((batasPenggunaan) {
        listBatasPenggunaan = batasPenggunaan;
        resultSearch = batasPenggunaan;
        batasanPenggunaanAktif = null;

        for (var i = 0; i < batasPenggunaan.length; i++) {
          var item = batasPenggunaan[i];
          if (item.statusAktif) {
            batasanPenggunaanAktif = item;
          }
        }
        setState(() {});
        print("batasanPenggunaanAktif ${batasanPenggunaanAktif?.nama}");
      });
    });
  }
}
