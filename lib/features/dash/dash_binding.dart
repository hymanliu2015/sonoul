
import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/features/member/member_controller.dart';

class DashBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(DashController());
    Get.put(MemberController());
  }

}