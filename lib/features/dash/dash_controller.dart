import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/features/dash/singer_model.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:sonoul/utils/toast_util.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  String get userEmail => _authController.currentUser?.email ?? 'Guest';
  bool get isLoggedIn => _authController.currentUser != null;
  
  final RxList<Singer> singers = <Singer>[].obs;
  final RxInt currentSingerIndex = 0.obs;
  final RxBool isLoading = false.obs;

  // Helper to get current singer safely
  Singer? get currentSinger => singers.isNotEmpty ? singers[currentSingerIndex.value] : null;

  @override
  void onInit() {
    super.onInit();
    loadSingers();
  }

  Future<void> loadSingers() async {
    // Mock data: Start with 1 singer as requested
    if (singers.isNotEmpty) return; // Don't reload if we already have data (dynamic additions)
    
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); 
    
    singers.value = [
      Singer(
        id: '1', 
        name: 'Hatsune Miku', 
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Miku'
      ),
    ];
    
    isLoading.value = false;
  }

  void addMockSinger(String name, String avatar) {
    final newSinger = Singer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatarUrl: avatar,
    );
    singers.add(newSinger);
    // Auto-scroll to the new singer
    Future.delayed(const Duration(milliseconds: 100), () {
      currentSingerIndex.value = singers.length - 1;
    });
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
      // Limit check: Max 2 singers for free users
      if (singers.length >= 2) {
        ToastUtils.shotToast('Free limit reached (Max 2 singers). Upgrade to create more!');
        Get.toNamed(AppRoutes.member);
        return;
      }
      Get.toNamed(AppRoutes.singer);
    }
  }

  void goToCreateSingle() {
    if (requireAuth()) {
      if (singers.isEmpty) {
         ToastUtils.shotToast('Please create a singer first');
         Get.toNamed(AppRoutes.singer);
         return;
      }
      
      // Limit check: Max 5 songs for free users
      final createdSongs = SpUtil.getInt('created_song_count', defValue: 0) ?? 0;
      if (createdSongs >= 5) {
        ToastUtils.shotToast('Free limit reached (Max 5 songs). Upgrade to create more!');
        Get.toNamed(AppRoutes.member);
        return;
      }
      
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

  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  void logout() {
    _authController.logout();
  }
  
  void onPageChanged(int index) {
    currentSingerIndex.value = index;
  }
}