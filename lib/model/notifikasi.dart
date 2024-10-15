import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';

// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Notifikasi {
  final int id;
  final String judul;
  final String detail;
  final int waktu;

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

Future<void> insertOrUpdateNotifikasi(
  Future<Database> database,
  Notifikasi notifikasi,
) async {
  final db = await database;

  await db
      .insert(
    'Notifikasi',
    notifikasi.toMap(),
    conflictAlgorithm:
        ConflictAlgorithm.replace, // This ensures it replaces if it exists
  )
      .then((_) {
    print('Notifikasi berhasil ditambahkan: ${notifikasi.toString()}');
  });
}

Future<List<Notifikasi>> fetchNotifikasis(Future<Database> database) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('Notifikasi');

  return List.generate(maps.length, (i) {
    return Notifikasi(
      id: maps[i]['id'],
      judul: maps[i]['judul'],
      detail: maps[i]['detail'],
      waktu: maps[i]['waktu'], // Fetch as integer
    );
  });
}
