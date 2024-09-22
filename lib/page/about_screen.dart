import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/utils/colors.dart';
import 'package:kidztime/utils/png_assets.dart';
import 'package:kidztime/utils/widget_util.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage(logo), // Ganti dengan path logo aplikasi
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Center(
                    child: Text(
                      'KidzTime',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Center(
                    child: Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    'Tentang Aplikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'KidzTime adalah aplikasi yang membantu orang tua mengatur waktu penggunaan perangkat untuk anak-anak mereka. Dengan fitur seperti kunci layar, batas penggunaan, dan kontrol orang tua, KidzTime mempromosikan kebiasaan penggunaan perangkat yang sehat.',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    'Dikembangkan oleh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Teddyanto Idrus Jamallulail',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.link,
                              color: WidgetUtil().parseHexColor(
                                darkColor,
                              ),
                            ),
                            onTap: () {
                              _launchUrl(
                                "https://www.linkedin.com/in/teddyanto-ij-074a18228/",
                              );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.email,
                              color: WidgetUtil().parseHexColor(
                                darkColor,
                              ),
                            ),
                            onTap: () {
                              _launchEmail("teddyanto.jamallulail@binus.ac.id");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Annisa Hakimi Nasry',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.link,
                              color: WidgetUtil().parseHexColor(
                                darkColor,
                              ),
                            ),
                            onTap: () {
                              _launchUrl(
                                "https://www.linkedin.com/in/annisahakiminasry/",
                              );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.email,
                              color: WidgetUtil().parseHexColor(
                                darkColor,
                              ),
                            ),
                            onTap: () {
                              _launchEmail("annisa.nasry@binus.ac.id");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Container(
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border(
                        left: BorderSide(
                          color: WidgetUtil().parseHexColor(darkColor),
                          width: 3,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Aplikasi ini dikembangkan sebagai bagian dari tugas akhir atau skripsi untuk memenuhi persyaratan gelar Sarjana Komputer.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    "• Terima kasih telah menggunakan aplikasi kami •\nTeddy & Annisa",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .35,
                      child: Image.asset(
                        iconBinus,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    "",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
          WidgetUtil().getAppBarV2(
            titleScreen: "About",
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

  // Fungsi untuk membuka aplikasi email
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': '[KidzTime]',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _launchUrl(String urlParam) async {
    final Uri url = Uri.parse(urlParam);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      WidgetUtil().showToast(msg: "Could not launch $url");
    }
  }
}
