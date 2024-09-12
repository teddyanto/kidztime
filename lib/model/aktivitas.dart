import 'dart:async';

import 'package:sqflite/sqflite.dart';

const tableName = "Aktivitas";

class Aktivitas {
  int? id;
  final String judul;
  final String deskripsi;
  final int waktu;
  final String tanggal;

  Aktivitas({
    id,
    required this.judul,
    required this.deskripsi,
    required this.waktu,
    required this.tanggal,
  });

  // Convert an Aktivitas into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'waktu': waktu,
      'tanggal': tanggal,
    };
  }

  // Implement toString to make it easier to see information about
  // each Aktivitas when using the print statement.
  @override
  String toString() {
    return 'Aktivitas{id: $id, judul: $judul, deskripsi: $deskripsi, waktu: $waktu, tanggal: $tanggal}';
  }
}

// Define a function that inserts aktivitas into the database
Future<void> insertAktivitas(
  Future<Database> database,
  Aktivitas aktivitas,
) async {
  // Get a reference to the database.
  final db = await database;

  // Insert the aktivitas into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same aktivitas is inserted twice.
  //
  // In this case, replace any previous data.
  await db
      .insert(
    tableName,
    aktivitas.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  )
      .then((e) {
    print("Data insert in the database: ${aktivitas.toString()}");
  });
}

// A method that retrieves all the aktivitas from the Aktivitas table.
Future<List<Aktivitas>> getAktivitas(Database database) async {
  // Get a reference to the database.
  final db = database;

  // Query the table for all the aktivitas.
  final List<Map<String, Object?>> aktivitasMaps = await db.query(
    tableName,
    orderBy: 'id DESC',
  );

  // Convert the list of each aktivitas fields into a list of `Aktivitas` objects.
  return [
    for (final {
          'id': id as int,
          'judul': judul as String,
          'deskripsi': deskripsi as String,
          'waktu': waktu as int,
          'tanggal': tanggal as String,
        } in aktivitasMaps)
      Aktivitas(
        id: id,
        judul: judul,
        deskripsi: deskripsi,
        waktu: waktu,
        tanggal: tanggal,
      ),
  ];
}
