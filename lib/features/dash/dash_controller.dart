import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/routes/app_routes.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  String get userEmail => _authController.currentUser?.email ?? 'User';

  void goToCreateSingle() {
    Get.toNamed(AppRoutes.createSingle);
  }

  void goToAlbum() {
    Get.toNamed(AppRoutes.album);
  }

  void logout() {
    _authController.logout();
  }
}