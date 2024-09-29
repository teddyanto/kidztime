import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/svg_assets.dart';
import 'package:kidztime/utils/widget_util.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  _AdsScreenState createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> wellcomes = [
    {
      "image": greetings,
      "title": "Selamat Datang",
      "description":
          "Pantau dan batasi penggunaan gawai anak dengan mudah. Fitur kontrol kami memastikan anak tetap aman dari akses yang tidak sesuai, sambil membantu menjaga keseimbangan waktu layar yang sehat."
    },
    {
      "image": ads4,
      "title": "Amankan Gawai",
      "description":
          "Lindungi gawai anak dari akses yang tidak diinginkan dan pastikan penggunaannya tetap aman dengan fitur kontrol yang mudah dan efektif."
    },
    {
      "image": ads1,
      "title": "Atur Batas Waktu",
      "description":
          "Tetapkan batas waktu harian yang sehat untuk penggunaan gawai, bantu anak mengelola waktu mereka dengan lebih baik."
    },
    {
      "image": ads3,
      "title": "Atur Jadwal Penggunaan",
      "description":
          "Buat jadwal penggunaan gawai yang fleksibel dan sesuai dengan rutinitas harian anak agar tetap seimbang antara bermain dan belajar."
    },
    {
      "image": ads2,
      "title": "Lihat Aktivitas Penggunaan",
      "description":
          "Pantau waktu penggunaan gawai secara keseluruhan. Cek berapa lama waktu yang telah digunakan, serta lihat rata-rata penggunaan mingguan dan bulanan."
    },
  ];

  final CarouselSliderController _corouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // No back button
        actions: [
          TextButton(
            onPressed: () async {
              WidgetUtil().customeDialog(
                context: context,
                title: "",
                detail: [
                  const Center(child: Text("Apakah anda yakin ?")),
                ],
                okButtonText: "Ya",
                okButtonFunction: () {
                  Navigator.of(context).pop();
                  Get.toNamed(
                    '/setup-page',
                    arguments: {
                      'from': 'splash_screen',
                    },
                  );
                },
                cancelButtonText: "Tidak",
              );
            },
            child: Text(
              "Skip",
              style: TextStyle(
                color: WidgetUtil().parseHexColor(primaryColor),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        height: height,
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                itemCount: wellcomes.length,
                carouselController: _corouselController,
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  reverse: false,
                  viewportFraction: .96,
                  initialPage: _currentIndex,
                  aspectRatio: 2 / 3,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIdx) {
                  return Column(
                    children: [
                      SvgPicture.asset(
                        wellcomes[index]["image"]!,
                        height: height * .4,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        wellcomes[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: WidgetUtil().parseHexColor(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          wellcomes[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  wellcomes.length,
                  (index) => Icon(
                    Icons.circle,
                    size: 13,
                    color: index == _currentIndex
                        ? Colors.grey
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: width,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            TextButton(
              onPressed: _currentIndex == 0
                  ? null // Disable back button if on first slide
                  : () {
                      setState(() {
                        _currentIndex--;
                        _corouselController.previousPage();
                      });
                    },
              child: Text(
                "Back",
                style: TextStyle(
                  color: _currentIndex == 0
                      ? null
                      : WidgetUtil().parseHexColor(primaryColor),
                ),
              ),
            ),
            // Next button
            TextButton(
              onPressed: () {
                if (_currentIndex == wellcomes.length - 1) {
                  Get.toNamed(
                    '/setup-page',
                    arguments: {
                      'from': 'splash_screen',
                    },
                  );
                } else {
                  setState(() {
                    _currentIndex++;
                    _corouselController.nextPage();
                  });
                }
              },
              child: Text(
                _currentIndex == wellcomes.length - 1 ? "Finish" : "Next",
                style: TextStyle(
                  color: WidgetUtil().parseHexColor(primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
