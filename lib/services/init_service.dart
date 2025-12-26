
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sonoul/common/config/config.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InitService extends GetxService {

  Future<InitService> init() async {

    // 禁止横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);

    // Android 状态栏配置
    if (GetPlatform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: AppColors.tranColor,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.tranColor,
      );
      SystemChrome.setSystemUIOverlayStyle(style);
    }

    // 初始化 SharedPreferences
    await SpUtil.getInstance();

    // 初始化 Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey:AppConfig.supabaseAnonKey,
    );

    await initPlatformState();

    await initAmplitude();

    return this;
  }

  Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug); // 开发阶段开启日志

    PurchasesConfiguration configuration;
    if (GetPlatform.isAndroid) {
      configuration = PurchasesConfiguration(AppConfig.subAndroidKey);
    } else {
      configuration = PurchasesConfiguration(AppConfig.subIOSKey);
    }

    // 重要：将 RevenueCat 的 App User ID 关联到 Supabase 的 User ID
    final supabase = Supabase.instance.client;
    configuration.appUserID = supabase.auth.currentUser?.id;
    await Purchases.configure(configuration);
  }

  Future<void> initAmplitude() async {
    // Create and initailize the instance
    final Amplitude amplitude = Amplitude(Configuration(
      apiKey: AppConfig.amplitudeKey,
    ));

    // Wait until the SDK is initialized
    await amplitude.isBuilt;

    // Track an event
    amplitude.track(BaseEvent(
      'APP_INIT',
      eventProperties: {'打开app': 'init'},
    ));

    // Send events to the server
    amplitude.flush();
  }


}