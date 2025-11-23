import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/features/dash/singer_model.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;

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
    if (!isLoggedIn) {
      _setDemoSinger();
      return;
    }

    try {
      isLoading.value = true;
      final user = _authController.currentUser;
      
      // Fetch singers from Supabase
      final response = await _supabase
          .from('singers')
          .select()
          .eq('user_id', user!.id)
          .order('created_at', ascending: true);
      
      final List<dynamic> data = response as List<dynamic>;
      
      if (data.isNotEmpty) {
        singers.value = data.map((json) => Singer.fromJson(json)).toList();
      } else {
        // Fallback to local storage if DB is empty but flag is set (legacy support or offline)
        final savedName = SpUtil.getString('singer_name');
        final savedAvatar = SpUtil.getString('singer_avatar');
        final hasCreated = SpUtil.getBool('has_created_singer', defValue: false) ?? false;

        if (hasCreated && savedName != null) {
           singers.value = [
             Singer(id: 'local', name: savedName, avatarUrl: savedAvatar ?? '')
           ];
        } else {
           // Should ideally not happen if we force creation, but handle it
           singers.clear();
        }
      }
    } catch (e) {
      debugPrint('Error loading singers: $e');
      // Fallback for demo/testing if DB fails
       final savedName = SpUtil.getString('singer_name');
       if (savedName != null) {
          singers.value = [
             Singer(id: 'local', name: savedName, avatarUrl: SpUtil.getString('singer_avatar') ?? '')
           ];
       }
    } finally {
      isLoading.value = false;
    }
  }

  void _setDemoSinger() {
    // For guests, maybe show a demo singer or empty state
    // Per requirement, we might force login/creation, but for safety:
    singers.clear();
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
      if (singers.isEmpty) {
         ToastUtils.shotToast('Please create a singer first');
         Get.toNamed(AppRoutes.singer);
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