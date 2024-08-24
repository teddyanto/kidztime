import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const VERSION = 1;

class DBKidztime {
  Future<Database> getDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'kidztime.db'),
      version: VERSION,
    );

    return database;
  }
}

Future<void> databaseInitialize() async {
  openDatabase(
    join(await getDatabasesPath(), 'kidztime.db'),
    onCreate: (db, version) async {
      await db
          .execute("CREATE TABLE Pengaturan ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "nama TEXT, "
              "deskripsi TEXT, "
              "sandi TEXT)")
          .then((value) {
        print("Table Pengaturan berhasil dibuat !");
      });

      await db
          .execute("CREATE TABLE Batas_penggunaan ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "nama TEXT, "
              "deskripsi TEXT, "
              "batas_waktu TIME, "
              "batas_toleransi TIME, "
              "status_aktif BOOLEAN)")
          .then((value) {
        print("Table Batas_penggunaan berhasil dibuat !");
      });

      await db
          .execute("CREATE TABLE Aktivitas ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "judul TEXT, "
              "deskripsi TEXT, "
              "waktu DATETIME)")
          .then((value) {
        print("Table Aktivitas berhasil dibuat !");
      });

      await db
          .execute("CREATE TABLE Notifikasi ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "judul TEXT, "
              "detail TEXT, "
              "waktu DATETIME)")
          .then((value) {
        print("Table Notifikasi berhasil dibuat !");
      });

      await db
          .execute("CREATE TABLE Jadwal_penggunaan ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "hari TEXT, "
              "waktu_mulai TIME, "
              "waktu_akhir TIME, "
              "status_aktif BOOLEAN)")
          .then((value) {
        print("Table Jadwal_penggunaan berhasil dibuat !");
      });
    },
    onOpen: (db) {
      // Actions to perform when the database is opened
    },
    version: VERSION,
  );
}
