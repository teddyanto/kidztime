import 'package:get/get.dart';
import 'package:kidztime/page/about_screen.dart';
import 'package:kidztime/page/activity_screen.dart';
import 'package:kidztime/page/ads_screen.dart';
import 'package:kidztime/page/guidance_screen.dart';
import 'package:kidztime/page/lock_screen.dart';
import 'package:kidztime/page/main_screen.dart';
import 'package:kidztime/page/schedule_screen/list_schedule_screen.dart';
import 'package:kidztime/page/schedule_screen/schedule_screen.dart';
import 'package:kidztime/page/setup_screen.dart';
import 'package:kidztime/page/time_limit_screen/list_time_limit_screen.dart';
import 'package:kidztime/page/time_limit_screen/time_limit_screen.dart';
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
        name: '/list-time-limit',
        page: () => const ListTimeLimitScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/time-limit',
        page: () => const TimeLimitScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/list-schedule',
        page: () => const ListScheduleScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/schedule-page',
        page: () => ScheduleScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/activity-page',
        page: () => const ActivityHistoryScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/ads-page',
        page: () => const AdsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/how-to-page',
        page: () => const GuidanceScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: '/about-page',
        page: () => const AboutScreen(),
        transition: Transition.rightToLeft,
      ),
    ];
  }
}
