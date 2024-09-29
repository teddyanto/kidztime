import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidztime/utils/widget_util.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final List<Map<String, dynamic>> daftarGuidance = [
      {
        "question": "Bagaimana aplikasi bekerja?",
        "answer": [
          "Cukup dengan mengaktifkan batasan waktu lalu mulai perhitungan batasan waktu, maka device akan otomatis terkunci ketika batasan waktu sudah tercapai / habis.",
        ],
      },
      {
        "question": "Ada berapa jenis batasan waktu yang ada?",
        "answer": [
          "Secara umum dibagi menjadi dua, batasan waktu tidak terjadwal atau batasan waktu terjadwal.",
          [
            "• Batasan waktu tidak terjadwal bisa diaktifkan kapan saja, melalui menu 'Batas waktu (1)'.",
            "• Batasan waktu terjadwal hanya dapat diaktifkan sesuai dengan jadwal yang sudah ditetapkan pada hari dan waktu tertentu yang diatur pada menu 'Jadwal Penggunaan (2)'.",
          ],
        ],
      },
      {
        "question": "Bagaimana cara membuat batasan waktu?",
        "answer": [
          "Anda dapat membuat batasan waktu melalui menu Batas Waktu. Dengan detail sebagai berikut:",
          [
            "1. Masuk menu Batas Waktu",
            "2. Tekan tombol Tambah batasan baru (ada di bawah)",
            "3. Masukkan data batasan waktu sesuai kebutuhan. (Anda dapat mengaktifkan batasan waktu dengan memilih status aktif)",
            "4. Tekan tombol simpan, pastikan data sudah sesuai lalu konfirmasi",
            "5. Aplikasi menampilkan daftar batas waktu yang sudah dibuat. Cari batas waktu yg sudah anda buat",
            "6. Tekan aktifkan (Jika batas waktu sudah diaktifkan, maka tombol yang muncul adalah 'Nonaktifkan')",
            "7. Selesai."
          ],
        ]
      },
      {
        "question": "Bagaimana cara membuat batasan waktu terjadwal ?",
        "answer": [
          "Anda dapat membuat batasan waktu terjadwal melalui menu Jadwal Penggunaan. Dengan detail sebagai berikut:",
          [
            "1. Masuk menu Jadwal Penggunaan",
            "2. Tekan tombol Tambah jadwal baru (ada di bawah)",
            "3. Masukkan data penjadwalan sesuai kebutuhan.",
            "4. Tekan tombol Simpan Jadwal, pastikan data sudah sesuai lalu konfirmasi",
            "5. Selesai"
          ],
          "Batasan waktu terjadwal hanya dapat diaktifkan pada waktu yang sudah ditentukan"
        ],
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: daftarGuidance.length,
                    itemBuilder: (context, index) {
                      var question = daftarGuidance[index]['question']!;
                      var answer = daftarGuidance[index]['answer']!;
                      return GuidanceWidget(
                          nomor: index + 1, question: question, answer: answer);
                    },
                  ),
                ),
              ],
            ),
          ),
          WidgetUtil().getAppBarV2(
            titleScreen: "Guidance",
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

class GuidanceWidget extends StatelessWidget {
  const GuidanceWidget({
    super.key,
    required this.nomor,
    required this.question,
    required this.answer,
  });

  final int nomor;
  final String question;
  final dynamic answer;

  @override
  Widget build(BuildContext context) {
    double level = 1;
    List<Widget> itterateAnswer(arr, level) {
      List<Widget> tempWidget = [];

      for (var arrItem in arr) {
        if (arrItem is List) {
          tempWidget.addAll(itterateAnswer(arrItem, level + 1));
        } else {
          tempWidget.add(_answerWidget(arrItem, level));
        }
      }
      return tempWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$nomor. $question",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: itterateAnswer(answer, level),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Container _answerWidget(answer, double level) {
    return Container(
      padding: EdgeInsets.only(left: 12 * level),
      margin: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Text(
        answer,
        textAlign: level == 1 ? TextAlign.justify : null,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
