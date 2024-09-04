import 'package:get/get.dart';
import 'package:kidztime/page/lock_screen.dart';
import 'package:kidztime/page/main_screen.dart';
import 'package:kidztime/page/setup_screen.dart';
import 'package:kidztime/page/time_limit.dart';
import 'package:kidztime/splash_screen.dart';

class Routes {
  List<GetPage<dynamic>> get() {
    return [
      GetPage(
        name: '/',
        page: () => const SplashScreenPage(),
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
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/main-menu',
        page: () => const MainMenuPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/time-limit',
        page: () => TimeLimitScreen(),
        transition: Transition.fadeIn,
      ),
    ];
  }
}
