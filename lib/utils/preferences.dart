import 'package:kidztime/model/aktivitas.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<void> setTemp({required String text}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("temp", text);
    print("setTemp called: $text");
  }

  static Future<String> getTemp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String temp = pref.getString("temp") ?? "";
    print("getTemp called: $temp");
    return temp;
  }

  static Future<void> setLockTime({
    required int hours,
    required int minutes,
    required int seconds,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String lockTime = DateTime.now()
        .add(Duration(hours: hours, minutes: minutes, seconds: seconds))
        .toIso8601String();

    pref.setString("locktime", lockTime);
    print("setLockTime called: $lockTime");
  }

  static Future<DateTime> getLockTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? lockTimeString = pref.getString("locktime");
    if (lockTimeString == null) {
      print("getLockTime called: No lock time set");
      return DateTime.now();
    }

    DateTime lockTime = DateTime.parse(lockTimeString);
    print("getLockTime called: $lockTimeString");
    return lockTime;
  }

  static Future<void> setTempAktivitas({
    required Aktivitas aktivitas,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("aktivitas_judul", aktivitas.judul);
    pref.setString("aktivitas_deskripsi", aktivitas.deskripsi);
    pref.setString("aktivitas_tanggal", aktivitas.tanggal);
  }

  static Future<Aktivitas> getTempAktivitas() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Get JSON string from SharedPreferences
    String? aktivitasJudul = pref.getString("aktivitas_judul");
    String? aktivitasDeskripsi = pref.getString("aktivitas_deskripsi");
    String? aktivitasTanggal = pref.getString("aktivitas_tanggal");

    Aktivitas aktivitas = Aktivitas(
      judul: aktivitasJudul ?? "",
      deskripsi: aktivitasDeskripsi ?? "",
      waktu: 0,
      tanggal: aktivitasTanggal ?? "",
    );
    return aktivitas;
  }
}
