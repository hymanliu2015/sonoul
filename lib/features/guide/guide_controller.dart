import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/utils/sp_util.dart';

class GuideController extends GetxController {
  void finishGuide() async {
    await SpUtil.putBool('has_seen_guide', true);
    Get.offAllNamed(AppRoutes.dash);
  }
}
