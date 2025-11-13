
import 'package:sonoul/common/res/aoo_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sonoul/utils/sp_util.dart';

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

    return this;
  }

}