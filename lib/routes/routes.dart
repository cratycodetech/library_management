import 'package:get/get.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../bindings/auth_binding.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';

  static List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: AuthBinding(),
    ),
  ];
}
