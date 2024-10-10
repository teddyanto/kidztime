import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/database.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  _ActivityHistoryScreenState createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final Future<Database> dbKidztime = DBKidztime().getDatabase();
  late List<Aktivitas> listAktivitas = [];
  late List<ChartData> dataChart = [];

  DateTimeRange? _selectedDates;

  int bulanIni = 0;
  double avgBulanIni = 0;

  List<int> mingguIni = [0, 0];
  double avgMingguIni = 0;

  double avgJangkauanIni = 0;

  @override
  void initState() {
    super.initState();

    DateTime currentDate = DateTime.now();

    _selectedDates = DateTimeRange(
      start: DateTime(currentDate.year, currentDate.month, 1),
      end: DateTime(currentDate.year, currentDate.month,
          DateTime(currentDate.year, currentDate.month + 1, 0).day),
    );

    bulanIni = currentDate.month;

    DateTime dateTemp = currentDate
        .subtract(Duration(days: currentDate.weekday))
        .add(const Duration(days: 1));

    int tanggal = dateTemp.day;
    int bulan = dateTemp.month;
    int tahun = dateTemp.year;

    mingguIni[0] = int.parse(
        "$tahun${bulan.toString().padLeft(2, "0")}${tanggal.toString().padLeft(2, "0")}");

    dateTemp = currentDate
        .subtract(Duration(days: currentDate.weekday))
        .add(const Duration(days: 7));

    tanggal = dateTemp.day;
    bulan = dateTemp.month;
    tahun = dateTemp.year;

    mingguIni[1] = int.parse(
        "$tahun${bulan.toString().padLeft(2, "0")}${tanggal.toString().padLeft(2, "0")}");

    _initializeData(_selectedDates!.start, _selectedDates!.end);
  }

  Future<void> _initializeData(DateTime start, DateTime end) async {
    final database = await dbKidztime; // Get the database instance
    // insertDummyData(database); // Insert dummy data for testing

    final aktivitas = await getAktivitasRange(
      database,
      start,
      end,
    );
    setState(() {
      listAktivitas = aktivitas;
    });
    _rearrangeChart();
  }

  void _rearrangeChart() {
    Map<String, double> temp = {};
    dataChart.clear();

    int countBulanIni = 0;
    double tempAvgBulanIni = 0;

    int countMingguIni = 0;
    double tempAvgMingguIni = 0;

    double tempAvgJangkauanIni = 0;

    for (Aktivitas item in listAktivitas) {
      int tanggal = DateTime.parse(item.tanggal).day;
      int bulan = DateTime.parse(item.tanggal).month;
      int tahun = DateTime.parse(item.tanggal).year;

      int fullTanggal = int.parse(
          "$tahun${bulan.toString().padLeft(2, "0")}${tanggal.toString().padLeft(2, "0")}");

      String stanggal =
          "${tanggal.toString().padLeft(2, "0")}/${bulan.toString().padLeft(2, "0")}";
      double menit = (item.waktu / 60);

      if (temp[stanggal] == null) {
        temp[stanggal] = menit;
      } else {
        double currentTime = temp[stanggal] ?? 0;
        temp[stanggal] = currentTime + menit;
      }

      if (bulanIni == bulan) {
        countBulanIni++;
        tempAvgBulanIni += menit;
      }

      if (fullTanggal >= mingguIni[0] && fullTanggal <= mingguIni[1]) {
        countMingguIni++;
        tempAvgMingguIni += menit;
      }

      tempAvgJangkauanIni += menit;
    }

    setState(() {
      avgBulanIni = tempAvgBulanIni / countBulanIni;
      avgMingguIni = tempAvgMingguIni / countMingguIni;
      avgJangkauanIni = tempAvgJangkauanIni / listAktivitas.length;
    });

    temp.forEach((index, value) {
      dataChart.add(ChartData(index, value));
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
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showSelectDatePicker,
                    child: Container(
                      padding: const EdgeInsets.all(
                        3,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: WidgetUtil().parseHexColor(darkColor),
                          ),
                        ),
                      ),
                      child: Text(
                        '${_formatDateToString(_selectedDates?.start)}'
                        ' s/d '
                        '${_formatDateToString(_selectedDates?.end)}',
                        softWrap: true,
                        style: TextStyle(
                          color: WidgetUtil().parseHexColor(darkColor),
                        ),
                      ),
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rangkuman penggunaan"),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Card(
                  child: Container(
                    color: Colors.blueGrey.shade300,
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: width * .5,
                          child: SfCartesianChart(
                            // Initialize category axis
                            primaryYAxis: const NumericAxis(
                              // Define the Y-axis with a title (legend)
                              title: AxisTitle(
                                text: 'Dalam menit', // Label for the Y-axis
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            primaryXAxis: const CategoryAxis(),
                            series: <ColumnSeries<ChartData, String>>[
                              ColumnSeries<ChartData, String>(
                                  // Bind data source
                                  dataSource: dataChart,
                                  xValueMapper: (ChartData data, _) =>
                                      data.date,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value),
                            ],
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Wrap(
                          children: [
                            AverageWidget(
                              title: "Bulan ini",
                              menit: avgBulanIni,
                            ),
                            AverageWidget(
                              title: "Minggu ini",
                              menit: avgMingguIni,
                            ),
                            AverageWidget(
                              title: "Jangkauan ini",
                              menit: avgJangkauanIni,
                            ),
                          ],
                        ),
                        const Text(
                          "Rata-rata penggunaan (dalam menit)",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
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

  String _formatDateToString(DateTime? date) {
    if (date == null) return '-';

    return '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';
  }

  Future _showSelectDatePicker() async {
    final result = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDates,
      firstDate: DateTime(2000), // tanggal awal yang diperbolehkan di pilih
      lastDate: DateTime(2100), // tanggal akhir yang diperbolehkan di pilih
    );

    if (result != null) {
      setState(() {
        _selectedDates = result;
        _initializeData(_selectedDates!.start, _selectedDates!.end);
      });
    }
  }
}

class AverageWidget extends StatelessWidget {
  AverageWidget({
    super.key,
    required this.menit,
    required this.title,
  });

  double menit;
  String title;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: WidgetUtil().parseHexColor(darkColor),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              menit.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.date, this.value);
  final String date;
  final double value;
}
