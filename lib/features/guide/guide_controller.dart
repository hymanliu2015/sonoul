import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';

class GuideController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();

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
    await SpUtil.putBool('has_seen_guide', true);
    Get.offAllNamed(AppRoutes.dash);
  }
}
