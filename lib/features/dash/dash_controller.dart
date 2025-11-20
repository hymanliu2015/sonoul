import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:sonoul/utils/toast_util.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  String get userEmail => _authController.currentUser?.email ?? 'Guest';
  bool get isLoggedIn => _authController.currentUser != null;
  
  final RxString singerName = ''.obs;
  final RxString singerAvatar = ''.obs;
  final RxBool hasRealSinger = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSingerInfo();
  }

  void loadSingerInfo() {
    if (isLoggedIn) {
      final savedName = SpUtil.getString('singer_name');
      final savedAvatar = SpUtil.getString('singer_avatar');
      final hasCreated = SpUtil.getBool('has_created_singer', defValue: false) ?? false;
      
      if (hasCreated && savedName != null) {
        singerName.value = savedName;
        singerAvatar.value = savedAvatar ?? '';
        hasRealSinger.value = true;
      } else {
        _setDemoSinger();
      }
    } else {
      _setDemoSinger();
    }
  }

  void _setDemoSinger() {
    singerName.value = 'Demo Singer';
    singerAvatar.value = 'https://api.dicebear.com/7.x/avataaars/png?seed=demo';
    hasRealSinger.value = false;
  }

  bool requireAuth() {
    if (!isLoggedIn) {
      ToastUtils.shotToast('Please login first');
      Get.toNamed(AppRoutes.login);
      return false;
    }
    return true;
  }

  void goToCreateSinger() {
    if (requireAuth()) {
      Get.toNamed(AppRoutes.singer);
    }
  }

  void goToCreateSingle() {
    if (requireAuth()) {
      Get.toNamed(AppRoutes.createSingle);
    }
  }

  void goToAlbum() {
    if (requireAuth()) {
      Get.toNamed(AppRoutes.album);
    }
  }
  
  void goToMember() {
    Get.toNamed(AppRoutes.member);
  }

  void logout() {
    _authController.logout();
  }
}