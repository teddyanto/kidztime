import 'package:sqflite/sqflite.dart';

const tableName = "Jadwal_penggunaan";

class Jadwalpenggunaan {
  int? id;
  final String hari;
  final String waktuMulai;
  final String waktuAkhir;
  final bool statusAktif;

  Jadwalpenggunaan({
    this.id,
    required this.hari,
    required this.waktuMulai,
    required this.waktuAkhir,
    required this.statusAktif,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'hari': hari,
      'waktu_mulai': waktuMulai,
      'waktu_akhir': waktuAkhir,
      'status_aktif': statusAktif ? 1 : 0
    };
  }

  // Convert a Map into a Jadwalpenggunaan instance
  factory Jadwalpenggunaan.fromMap(Map<String, dynamic> map) {
    return Jadwalpenggunaan(
      id: map['id'] as int?,
      hari: map['hari'] as String,
      waktuMulai: map['waktu_mulai'] as String,
      waktuAkhir: map['waktu_akhir'] as String,
      statusAktif:
          (map['status_aktif'] as int) == 1, // Convert integer to boolean
    );
  }

  @override
  String toString() {
    return 'Jadwalpenggunaan{id: $id, hari: $hari, waktuMulai: $waktuMulai, waktuAkhir: $waktuAkhir, statusAktif: $statusAktif}';
  }
}

Future<void> updateJadwalPenggunaan(
    Future<Database> database, Jadwalpenggunaan jadwalPenggunaan) async {
  final db = await database; // Await to get the actual Database instance
  await db.update(
    'Jadwal_penggunaan',
    jadwalPenggunaan.toMap(),
    where: 'id = ?',
    whereArgs: [jadwalPenggunaan.id],
  );
}

Future<int> insertJadwalPenggunaan(
    Future<Database> database, Jadwalpenggunaan jadwalpenggunaan) async {
  final db = await database; // Await to get the actual Database instance
  return await db.insert(
    'Jadwal_penggunaan',
    jadwalpenggunaan.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Jadwalpenggunaan?> getJadwalByHari(
    Future<Database> database, String? hari) async {
  final db = await database; // Await to get the actual Database instance
  final List<Map<String, dynamic>> maps = await db.query(
    'Jadwal_penggunaan',
    where: 'hari = ?',
    whereArgs: [hari],
  );

  if (maps.isNotEmpty) {
    return Jadwalpenggunaan.fromMap(maps.first);
  }
  return null;
}

Future<void> deleteJadwalPenggunaan(Future<Database> database, int id) async {
  final db = await database;
  await db.delete(
    'Jadwal_penggunaan',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<List<Jadwalpenggunaan>> getAllJadwalPenggunaan(Database database) async {
  final db = database;
  final List<Map<String, Object?>> maps = await db.query(tableName);

  return [
    for (final map in maps)
      Jadwalpenggunaan(
        id: map['id'] as int?,
        hari: map['hari'] as String,
        waktuMulai: map['waktu_mulai'] as String,
        waktuAkhir: map['waktu_akhir'] as String,
        statusAktif: (map['status_aktif'] as int) == 1,
      )
  ];
}

Future<void> updateStatusAktifJadwal(
  Future<Database> dbKidztime,
  bool statusAktif,
) async {
  final db = await dbKidztime;
  int statusAktifValue = statusAktif ? 1 : 0;
  int count = await db.update(
    tableName,
    {'status_aktif': statusAktifValue},
  );
  print('Updated $count records');
}
