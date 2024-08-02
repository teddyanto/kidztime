import 'package:get/get.dart';
import 'package:kidztime/page/lock.dart';
import 'package:kidztime/page/main_menu.dart';
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
        name: '/main-menu',
        page: () => const MainMenuPage(),
        transition: Transition.fadeIn,
      ),
    ];
  }
}
