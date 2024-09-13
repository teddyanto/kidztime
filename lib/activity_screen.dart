import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/page/widget/header_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ActivityHistoryScreen extends StatefulWidget {
  ActivityHistoryScreen({super.key});

  @override
  _ActivityHistoryScreenState createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  late List<Aktivitas> listAktivitas = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final database = await dbKidztime; // Get the database instance
    // insertDummyData(database); // Insert dummy data for testing

    final aktivitas = await getAktivitas(database);
    setState(() {
      listAktivitas = aktivitas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtil().getAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWidget(
            titleScreen: "Aktivitas",
            callback: () {
              Get.back();
            },
            hasBackButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: ListView.builder(
                itemCount: listAktivitas.length,
                itemBuilder: (context, index) {
                  var item = listAktivitas[index];

                  return CardWidget(
                    verticalMargin: 10,
                    horizontalMargin: 0,
                    verticalPadding: 15,
                    horizontalPadding: 10,
                    border: Border(
                      top: BorderSide(
                        color: WidgetUtil().parseHexColor(primaryColor),
                        width: 4,
                      ),
                      right: BorderSide(
                        color: WidgetUtil().parseHexColor(primaryColor),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                item.judul,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Display the description
                        const Text(
                          "Deskripsi :",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          item.deskripsi,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Display the time and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 5,
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                Text(
                                  '${item.waktu} minutes',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 5,
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                Text(
                                  item.tanggal,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
