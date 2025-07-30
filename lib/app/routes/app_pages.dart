import 'package:get/get.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
