import 'package:sqflite/sqflite.dart';

const tableName = "Batas_penggunaan";

class Bataspenggunaan {
  final int? id;
  final String nama;
  final String deskripsi;
  final String batasWaktu;
  final String batasToleransi;
  final bool statusAktif;

  Bataspenggunaan({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.batasWaktu,
    required this.batasToleransi,
    required this.statusAktif,
  });

  // Convert a batas penggunaan into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'batas_waktu': batasWaktu,
      'batas_toleransi': batasToleransi,
      'status_aktif': statusAktif ? 1 : 0
    };
  }

  // Implement toString to make it easier to see information about
  // each Batas Penggunaan when using the print statement.
  @override
  String toString() {
    return 'Bataspenggunaan{id: $id, nama: $nama, deskripsi: $deskripsi, batasWaktu: $batasWaktu, batasToleransi: $batasToleransi, statusAktif: $statusAktif}';
  }
}

//Function to insert batas penggunaan to database
Future<void> insertOrUpdateBatasPenggunaan(
  Future<Database> database,
  Bataspenggunaan bataspenggunaan,
) async {
  // Get a reference to the database.
  final db = await database;

  // Check if a record with the same name exists.
  final List<Map<String, dynamic>> existingRecords = await db.query(
    tableName,
    where: 'id = ?',
    whereArgs: [
      bataspenggunaan.id,
    ],
  );

  if (existingRecords.isNotEmpty) {
    // If a record with the same name exists, update it.
    await db.update(
      tableName,
      bataspenggunaan.toMap(),
      where: 'id = ?',
      whereArgs: [bataspenggunaan.id],
    ).then((e) {
      print("Data updated in the database: ${bataspenggunaan.toString()}");
    });
  } else {
    // If no record with the same name exists, insert a new one.
    await db
        .insert(
      tableName,
      bataspenggunaan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    )
        .then((e) {
      print("Data added to the database: ${bataspenggunaan.toString()}");
    });
  }
}

// A method that retrieves all the batas penggunaan from the table.
Future<List<Bataspenggunaan>> getBatasPenggunaan(Database database) async {
  final db = database;

  final List<Map<String, Object?>> batasPenggunaanMaps =
      await db.query(tableName);

  return [
    for (final map in batasPenggunaanMaps)
      Bataspenggunaan(
        id: map['id'] as int?,
        nama: map['nama'] as String,
        deskripsi: map['deskripsi'] as String,
        batasWaktu: map['batas_waktu'] as String,
        batasToleransi: map['batas_toleransi'] as String,
        statusAktif: (map['status_aktif'] as int) == 1,
      )
  ];
}

// Function to delete batas penggunaan by id
Future<void> deleteBatasPenggunaanById(
    Future<Database> database, int id) async {
  // Get a reference to the database.
  final db = await database;

  // Delete the record from the database.
  await db.delete(
    tableName,
    where: 'id = ?',
    whereArgs: [id],
  ).then((_) {
    print("Data with id $id has been deleted from the database.");
  });
}

Future<void> updateStatusAktifBatasPenggunaan(
  Future<Database> database,
  bool statusAktif,
) async {
  // Get a reference to the database.
  final db = await database;

  // Convert the boolean value to integer (0 or 1).
  int statusAktifValue = statusAktif ? 1 : 0;

  // Update all records in the table to have the new statusAktif value.
  int count = await db.update(
    tableName,
    {
      'status_aktif': statusAktifValue,
    },
  );

  print("Updated $count records in the database to statusAktif: $statusAktif.");
}
