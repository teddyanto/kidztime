import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<void> setTemp({required String text}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("temp", text);
  }

  static Future<String> getTemp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    return pref.getString("temp") ?? "";
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
  }

  static Future<DateTime> getLockTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? lockTimeString = pref.getString("locktime");

    if (lockTimeString == null) {
      // If no lock time is set, return null
      return DateTime.now();
    }

    DateTime lockTime = DateTime.parse(lockTimeString);
    return lockTime;
  }
}
