import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sonoul/common/config/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sonoul/utils/review_util.dart';

class SettingsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      appVersion.value = '1.0.0';
    }
  }

  Future<void> shareApp() async {
    try {
      SharePlus.instance.share(
          ShareParams(text: 'share_content'.tr)
      );
    } catch (e) {
      ToastUtils.shotToast('toast_share_failed'.tr);
    }
  }

  Future<void> rateApp() async {
    await ReviewUtils.rateAppWithFeedback();
  }

  Future<void> openWebsite() async {
    final url = Uri.parse('https://sonoul.app');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ToastUtils.shotToast('toast_open_website_failed'.tr);
      }
    } catch (e) {
      ToastUtils.shotToast('toast_open_website_error'.tr);
    }
  }

  Future<void> contactSupport() async {
    final url = Uri.parse('mailto:starcodehero@outlook.com?subject=Sonoul Support Request');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ToastUtils.shotToast('toast_open_email_failed'.tr);
      }
    } catch (e) {
      ToastUtils.shotToast('toast_open_email_error'.tr);
    }
  }

  Future<void> openPrivacyPolicy() async {
    final url = Uri.parse(AppConfig.privacyPolicy);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ToastUtils.shotToast('toast_open_privacy_failed'.tr);
      }
    } catch (e) {
      ToastUtils.shotToast('toast_open_privacy_error'.tr);
    }
  }

  Future<void> openTermsOfService() async {
    final url = Uri.parse(AppConfig.termsOfUse);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ToastUtils.shotToast('toast_open_terms_failed'.tr);
      }
    } catch (e) {
      ToastUtils.shotToast('toast_open_terms_error'.tr);
    }
  }

  void logout() {
    _authController.logout();
  }

  void deleteAccount() {
    _authController.deleteAccount();
  }
}
