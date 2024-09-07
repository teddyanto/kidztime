import 'package:get/get.dart';
import 'package:kidztime/page/lock_screen.dart';
import 'package:kidztime/page/main_screen.dart';
import 'package:kidztime/page/setup_screen.dart';
import 'package:kidztime/page/time_limit_screen.dart';
import 'package:kidztime/schedule_screen.dart';
import 'package:kidztime/splash_screen.dart';
import 'package:kidztime/times_up_screen.dart';

class Routes {
  List<GetPage<dynamic>> get() {
    return [
      GetPage(
        name: '/',
        // page: () => const TestScreen(),
        page: () => const SplashScreenPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/times-up',
        page: () => const TimesUpScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/lock-page',
        page: () => const LockPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/setup-page',
        page: () => Setupscreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/main-menu',
        page: () => const MainMenuPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/time-limit',
        page: () => TimeLimitScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/schedule-page',
        page: () => ScheduleScreen(),
        transition: Transition.fadeIn,
      ),
    ];
  }
}
