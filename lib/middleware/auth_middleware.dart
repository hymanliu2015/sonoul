
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMiddleware extends GetMiddleware{

  @override
  RouteSettings? redirect(String? route) {
    // 1. Auth Check
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // 2. Guide Check
    final hasSeenGuide = SpUtil.getBool('has_seen_guide', defValue: false) ?? false;
    if (!hasSeenGuide) {
      return const RouteSettings(name: AppRoutes.guide);
    }

    // 3. Singer Check
    final hasCreatedSinger = SpUtil.getBool('has_created_singer', defValue: false) ?? false;
    if (!hasCreatedSinger) {
      return const RouteSettings(name: AppRoutes.singer);
    }

    return null;
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    debugPrint('Page build started for: $page');
    return super.onPageBuildStart(page);
  }

  @override
  Widget onPageBuilt(Widget page) {
    debugPrint('Page built: $page');
    return super.onPageBuilt(page);
  }

  @override
  void onPageDispose() {
    debugPrint('Page disposed');
    super.onPageDispose();
  }
}