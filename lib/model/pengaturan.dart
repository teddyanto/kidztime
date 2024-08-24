import 'dart:async';

import 'package:sqflite/sqflite.dart';

const tableName = "Pengaturan";

class Pengaturan {
  final int id;
  final String nama;
  final String deskripsi;
  final String sandi;

  Pengaturan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.sandi,
  });

  // Convert a Pengaturan into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {'id': id, 'nama': nama, 'deskripsi': deskripsi, 'sandi': sandi};
  }

  // Implement toString to make it easier to see information about
  // each Pengaturan when using the print statement.
  @override
  String toString() {
    return 'Pengaturan{id: $id, nama: $nama, deskripsi: $deskripsi, sandi: $sandi}';
  }
}

// Define a function that inserts pengaturan into the database
Future<void> insertPengaturan(
  Future<Database> database,
  Pengaturan pengaturan,
) async {
  // Get a reference to the database.
  final db = await database;

  // Insert the pengaturan into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same pengaturan is inserted twice.
  //
  // In this case, replace any previous data.
  await db
      .insert(
    tableName,
    pengaturan.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  )
      .then((e) {
    return true;
  });
}

// A method that retrieves all the pengaturan from the dogs table.
Future<List<Pengaturan>> getPengaturan(Database database) async {
  // Get a reference to the database.
  final db = database;

  // Query the table for all the pengaturan.
  final List<Map<String, Object?>> pengaturanMaps = await db.query(tableName);

  // Convert the list of each pengaturan fields into a list of `pengaturan` objects.
  return [
    for (final {
          'id': id as int,
          'nama': nama as String,
          'deskripsi': deskripsi as String,
          'sandi': sandi as String,
        } in pengaturanMaps)
      Pengaturan(id: id, nama: nama, deskripsi: deskripsi, sandi: sandi),
  ];
}
