import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/features/singer/singer_model.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  String get userEmail => _authController.currentUser?.email ?? 'Guest';
  bool get isLoggedIn => _authController.currentUser != null;
  
  final RxList<Singer> singers = <Singer>[].obs;
  final RxInt currentSingerIndex = 0.obs;
  final RxBool isLoading = false.obs;

  final RxBool isPremium = false.obs;
  final SupabaseSongService _songService = Get.put(SupabaseSongService());

  // Helper to get current singer safely
  Singer? get currentSinger => singers.isNotEmpty ? singers[currentSingerIndex.value] : null;

  @override
  void onInit() {
    super.onInit();
    fetchSingers();
    checkSubscription();
  }

  Future<void> checkSubscription() async {
    if (!isLoggedIn) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response != null) {
        final endDate = DateTime.parse(response['end_date']);
        if (endDate.isAfter(DateTime.now())) {
          isPremium.value = true;
        } else {
          isPremium.value = false;
        }
      } else {
        isPremium.value = false;
      }
    } catch (e) {
      debugPrint("Error checking subscription: $e");
      isPremium.value = false;
    }
  }

  Future<void> fetchSingers() async {
    if (!isLoggedIn) return;

    try {
      isLoading.value = true;
      
      final res = await _supabase.functions.invoke(
        'api_singers',
        method: HttpMethod.get,
      );

      final data = res.data;
      if (data != null && data['data'] != null) {
        final List<dynamic> list = data['data'];
        singers.value = list.map((e) => Singer.fromJson(e)).toList();
      }
      
    } catch (e) {
      debugPrint("Error fetching singers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addMockSinger(String name, String avatar) {
    fetchSingers();
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
      if (!isPremium.value && singers.length >= 2) {
        ToastUtils.shotToast('Free limit reached (Max 2 singers). Upgrade to create more!');
        Get.toNamed(AppRoutes.member);
        return;
      }
      Get.toNamed(AppRoutes.singer);
    }
  }

  Future<void> goToCreateSingle() async {
    if (requireAuth()) {
      if (singers.isEmpty) {
         ToastUtils.shotToast('Please create a singer first');
         Get.toNamed(AppRoutes.singer);
         return;
      }
      
      // Limit check: Max 5 songs for free users
      if (!isPremium.value) {
        final songCount = await _songService.getUserSongCount();
        if (songCount >= 5) {
          ToastUtils.shotToast('Free limit reached (Max 5 songs). Upgrade to create more!');
          Get.toNamed(AppRoutes.member);
          return;
        }
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