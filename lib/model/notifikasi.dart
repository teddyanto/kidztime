import 'package:sqflite/sqflite.dart';

class Notifikasi {
  final int id;
  final String judul;
  final String detail;
  final String waktu;

  Notifikasi({
    required this.id,
    required this.judul,
    required this.detail,
    required this.waktu,
  });

  Map<String, Object> toMap() {
    return {
      'id': id,
      'judul': judul,
      'detail': detail,
      'waktu': waktu,
    };
  }

  @override
  String toString() {
    return 'Notifikasi{id: $id, judul: $judul, detail: $detail, waktu: $waktu}';
  }
}

Future<void> insertNotifikasi(
  Future<Database> database,
  Notifikasi notifikasi,
) async {
  final db = await database;
  await db
      .insert(
    'Notifikasi',
    notifikasi.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  )
      .then((e) {
    print('Notifikasi berhasil ditambahkan ${notifikasi.toString()}');
  });
}
