
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware{

  @override
  RouteSettings? redirect(String? route) {
   // final authService = Get.find<AuthService>();
   //
   //  bool isAuthenticated = authService.isLogin.value;
   //
   //  if (!isAuthenticated) {
   //    return RouteSettings(name: AppRoutes.auth);
   //  }
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