import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            height: height,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 100,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rangkuman penggunaan"),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        height: 20,
                        width: width * .3,
                        child: const Placeholder(),
                      ),
                    ]),
                const SizedBox(
                  height: 120,
                  child: Placeholder(),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Detail penggunaan"),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: listAktivitas.length,
                    itemBuilder: (context, index) {
                      var item = listAktivitas[index];

                      int jam = (item.waktu / 3600).floor();
                      int menit = (item.waktu % 3600 / 60).floor();
                      int detik = item.waktu % 60;

                      int tanggal = DateTime.parse(item.tanggal).day;
                      int bulan = DateTime.parse(item.tanggal).month;
                      int tahun = DateTime.parse(item.tanggal).year;

                      int jamAct = DateTime.parse(item.tanggal).hour;
                      int menitAct = DateTime.parse(item.tanggal).minute;

                      String tanggalFormatted =
                          "${tahun.toString()}-${bulan.toString().padLeft(2, "0")}-${tanggal.toString().padLeft(2, "0")} ${jamAct.toString().padLeft(2, "0")}:${menitAct.toString().padLeft(2, "0")} WIB";

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
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 5,
                                  children: [
                                    const Icon(Icons.access_time, size: 18),
                                    Text(
                                      '$jam jam $menit menit $detik detik',
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
                                    const Icon(Icons.calendar_month, size: 18),
                                    Text(
                                      tanggalFormatted,
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
              ],
            ),
          ),
          WidgetUtil().getAppBarV2(
            titleScreen: "Aktivitas",
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
}