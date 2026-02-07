import 'package:sonoul/common/lang/app_translations.dart';
import 'package:sonoul/common/res/app_themes.dart';
import 'package:sonoul/routes/app_pages.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/analytics_service.dart';
import 'package:sonoul/services/init_service.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  final startRoute = _resolveStartRoute();
  final startLocale = _resolveStartLocale();
  runApp(MyApp(startRoute: startRoute, startLocale: startLocale));
}

class MyApp extends StatelessWidget {
  final String startRoute;
  final Locale? startLocale;

  const MyApp({super.key, required this.startRoute, required this.startLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: startRoute,
      getPages: AppPages.routes,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      locale: startLocale ?? Get.deviceLocale,
      translations: AppTranslations(),
      fallbackLocale: const Locale("en", "US"),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: child!,
        );
      },
    );
  }
}

Future<void> initServices() async {
  await Get.putAsync(() => InitService().init());
  await Get.putAsync(() => AnalyticsService().init());
}

String _resolveStartRoute() {
  final bool hasSeenGuide = SpUtil.getBool('has_seen_guide', defValue: false) ?? false;
  final bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;

  if (isLoggedIn) {
    return AppRoutes.dash;
  }
  if (hasSeenGuide) {
    return AppRoutes.login;
  }
  return AppRoutes.guide;
}

Locale? _resolveStartLocale() {
  final String code = SpUtil.getString('app_locale', defValue: '') ?? '';
  if (code.isEmpty) {
    return Get.deviceLocale;
  }
  final parts = code.split('_');
  if (parts.isEmpty) return Get.deviceLocale;
  if (parts.length == 1) return Locale(parts[0]);
  return Locale(parts[0], parts[1]);
}
