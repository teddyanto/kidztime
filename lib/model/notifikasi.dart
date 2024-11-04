import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';

// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const tableName = "Notifikasi";

class Notifikasi {
  final int? id;
  final String judul;
  final String detail;
  final int waktu;

  Notifikasi({
    this.id,
    required this.judul,
    required this.detail,
    required this.waktu,
  });

  Map<String, Object?> toMap() {
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

// Check if a record with the same name exists.
  final List<Map<String, dynamic>> existingRecords = await db.query(
    tableName,
    where: 'id = ?',
    whereArgs: [
      notifikasi.id,
    ],
  );

  if (existingRecords.isNotEmpty) {
    // If a record with the same name exists, update it.
    await db.update(
      tableName,
      notifikasi.toMap(),
      where: 'id = ?',
      whereArgs: [notifikasi.id],
    ).then((e) {
      print("Data updated in the database: ${notifikasi.toString()}");
    });
  } else {
    // If no record with the same name exists, insert a new one.
    await db
        .insert(
      tableName,
      notifikasi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    )
        .then((e) {
      print("Data added to the database: ${notifikasi.toString()}");
    });
  }
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

Future<List<Notifikasi>> fetchNotifikasisOrderByWaktuDesc(
    Future<Database> database) async {
  final db = await database;

  final List<Map<String, dynamic>> maps = await db.query(
    tableName,
    orderBy: 'waktu DESC',
  );

  return List.generate(maps.length, (i) {
    return Notifikasi(
      id: maps[i]['id'],
      judul: maps[i]['judul'],
      detail: maps[i]['detail'],
      waktu: maps[i]['waktu'], // Fetch as integer
    );
  });
}

Future<void> deleteNotifikasiById(Future<Database> database, int id) async {
  final db = await database;

  await db.delete(
    tableName,
    where: 'id = ?',
    whereArgs: [
      id,
    ],
  );
}
