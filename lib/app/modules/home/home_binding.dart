import 'package:get/get.dart';
import 'home_controller.dart';

/// Dependency injection binding for the Home module
/// Registers the HomeController with GetX dependency injection system
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization of HomeController
    // Controller will be created only when first accessed
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
