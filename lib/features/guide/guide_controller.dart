import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuideController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _hasSeenGuideKey = 'has_seen_guide';

  @override
  void onReady() {
    super.onReady();
    _redirectIfNeeded();
  }

  Future<void> _redirectIfNeeded() async {
    final bool hasSeenGuide = SpUtil.getBool(_hasSeenGuideKey, defValue: false) ?? false;
    final bool isLoggedIn = _supabase.auth.currentUser != null;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dash);
      return;
    }

    if (hasSeenGuide) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void finishGuide() async {
    await SpUtil.putBool(_hasSeenGuideKey, true);
    final bool isLoggedIn = _supabase.auth.currentUser != null;
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dash);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
