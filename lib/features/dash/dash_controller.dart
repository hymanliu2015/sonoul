import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  String get userEmail => _authController.currentUser?.email ?? 'User';
  
  final RxString singerName = ''.obs;
  final RxString singerAvatar = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSingerInfo();
  }

  void loadSingerInfo() {
    singerName.value = SpUtil.getString('singer_name') ?? 'Virtual Singer';
    singerAvatar.value = SpUtil.getString('singer_avatar') ?? '';
  }

  void goToCreateSingle() {
    Get.toNamed(AppRoutes.createSingle);
  }

  void goToAlbum() {
    Get.toNamed(AppRoutes.album);
  }
  
  void goToMember() {
    Get.toNamed(AppRoutes.member);
  }

  void logout() {
    _authController.logout();
  }
}