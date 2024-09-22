import 'package:flutter/material.dart';
import 'package:kidztime/model/aktivitas.dart';
import 'package:kidztime/page/widget/card_widget.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';

class BatasWaktuBarWidget extends StatefulWidget {
  const BatasWaktuBarWidget({
    super.key,
    required this.remainingTime,
    required this.aktif,
  });

  final int remainingTime;
  final bool aktif;
  @override
  State<BatasWaktuBarWidget> createState() => _BatasWaktuBarWidgetState();
}

class _BatasWaktuBarWidgetState extends State<BatasWaktuBarWidget> {
  @override
  Widget build(BuildContext context) {
    int hours = (widget.remainingTime / 3600).floor();
    int minutes = ((widget.remainingTime % 3600) / 60).floor();
    int seconds = (widget.remainingTime % 60).floor();

    String remainingTimeFormatted = [
      hours.toString().padLeft(2, "0"),
      minutes.toString().padLeft(2, "0"),
      seconds.toString().padLeft(2, "0"),
    ].join(":");

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.aktif ? Colors.red : Colors.grey,
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
              remainingTimeFormatted,
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
    int axisCount = 4;
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
        40,
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
              width: 2,
            ),
          ),
          child: SizedBox(
            width: width,
            height: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  width: width * .11,
                ),
                const SizedBox(
                  height: 5,
                ),
                FittedBox(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: MediaQuery.of(context).size.width * .02,
                    ),
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
