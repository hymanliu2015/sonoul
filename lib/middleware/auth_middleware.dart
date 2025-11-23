
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMiddleware extends GetMiddleware{

  @override
  RouteSettings? redirect(String? route) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const RouteSettings(name: AppRoutes.login);
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