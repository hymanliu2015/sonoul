import 'package:sonoul/features/dash/dash_binding.dart';
import 'package:sonoul/features/dash/dash_page.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages{

  static const initial = AppRoutes.dash;

  static final routes = [
    GetPage(
        name: AppRoutes.dash,
        page: () => DashPage(),
      binding: DashBinding(),
    ),
  ];
}