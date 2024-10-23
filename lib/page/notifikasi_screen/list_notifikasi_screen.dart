import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/notifikasi.dart'; // Ensure your Notifikasi model reflects the new structure
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ListNotifikasiScreen extends StatefulWidget {
  const ListNotifikasiScreen({super.key});

  @override
  State<ListNotifikasiScreen> createState() => _ListNotifikasiScreenState();
}

class _ListNotifikasiScreenState extends State<ListNotifikasiScreen> {
  late TextEditingController searchController = TextEditingController();
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  late List<Notifikasi> listNotifikasi = [];
  late List<Notifikasi> resultSearch = [];
  late Timer timerSearch = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    refreshNotifikasi();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: listNotifikasi);
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
                    const SizedBox(height: 120),
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
                            List<Notifikasi> temp = [];

                            if (timerSearch.isActive) {
                              timerSearch.cancel();
                            }

                            timerSearch =
                                Timer(const Duration(milliseconds: 500), () {
                              if (value.isEmpty) {
                                temp = listNotifikasi;
                              } else {
                                for (var item in listNotifikasi) {
                                  if (item.judul
                                          .toUpperCase()
                                          .contains(value.toUpperCase()) ||
                                      item.detail
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
                                resultSearch = listNotifikasi;
                              });
                            },
                            icon: const Icon(Icons.cancel),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 30),
                        itemCount: resultSearch.length,
                        itemBuilder: (context, index) {
                          var item = resultSearch[index];

                          return Dismissible(
                            key: Key(item.id.toString()),
                            onDismissed: (direction) {
                              handleDeleteNotifikasi(index, context);
                            },
                            direction: DismissDirection.startToEnd,
                            child: CardWidget(
                              verticalMargin: 10,
                              horizontalMargin: 0,
                              verticalPadding: 15,
                              horizontalPadding: 10,
                              border: Border(
                                top: BorderSide(
                                  color:
                                      WidgetUtil().parseHexColor(primaryColor),
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Notifikasi",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black),
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
                                        "Waktu: ${item.waktu} menit",
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text("Judul: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(item.judul),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text("Detail: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(item.detail),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton.filledTonal(
                                        color: WidgetUtil()
                                            .parseHexColor(darkColor),
                                        onPressed: () async {
                                          await Get.toNamed(
                                            "/notification-page",
                                            arguments: item,
                                          );

                                          refreshNotifikasi();
                                        },
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton.filledTonal(
                                        color: Colors.red,
                                        onPressed: () {
                                          handleDeleteNotifikasi(
                                            index,
                                            context,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                        ),
                                      ),
                                      IconButton.filledTonal(
                                        color: WidgetUtil()
                                            .parseHexColor(darkColor),
                                        onPressed: () {
                                          _showNotification(item);
                                        },
                                        icon: const Row(
                                          children: [
                                            Text("Trial "),
                                            Icon(
                                              Icons.volume_up_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
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
              titleScreen: "Notifikasi",
              callback: () {
                Get.back(result: listNotifikasi);
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
              final result = await Get.toNamed(
                  "/notification-page"); // Adjust the route as needed
              if (result != null && result == "added") {
                refreshNotifikasi();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Tambah Notifikasi Baru",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void refreshNotifikasi() {
    dbKidztime.then((db) {
      fetchNotifikasisOrderByWaktuDesc(Future.value(db)).then((notifikasi) {
        setState(() {
          listNotifikasi = notifikasi;
          resultSearch = notifikasi;
        });
        print(notifikasi);
      });
    });
  }

  void _showNotification(Notifikasi notif) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '912',
      'com.binus.kidztime',
      channelDescription: 'Notification for Kidztime Apps',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
      notif.id,
      notif.judul,
      notif.detail,
      platformChannelSpecifics,
      payload: 'Notification for ${listNotifikasi.first.judul}',
    );
  }

  void handleDeleteNotifikasi(int index, BuildContext context) async {
    Notifikasi tempRemove = resultSearch[index];

    // Remove the item from the list
    setState(() {
      resultSearch.removeAt(index);
    });

    // Handle the deletion, and add logic for undoing the deletion if needed
    Timer timerDelete = Timer(const Duration(seconds: 4), () {
      deleteNotifikasiById(dbKidztime, tempRemove.id ?? 0);
    });

    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: const Text('Notifikasi waktu berhasil dihapus!'),
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
}
