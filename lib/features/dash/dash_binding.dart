
import 'package:get/get.dart';
import 'dash_controller.dart';

class DashBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(DashController());
  }

}