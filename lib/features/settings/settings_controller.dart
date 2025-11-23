import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final InAppReview _inAppReview = InAppReview.instance;
  
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
          ShareParams(text: 'Check out Sonoul - Your AI Virtual Singer App! Create amazing songs with AI-powered voices.')
      );
    } catch (e) {
      ToastUtils.shotToast('Failed to share app');
    }
  }

  Future<void> rateApp() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        ToastUtils.shotToast('Rating not available on this device');
      }
    } catch (e) {
      ToastUtils.shotToast('Failed to open rating');
    }
  }

  Future<void> openWebsite() async {
    final url = Uri.parse('https://sonoul.app');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ToastUtils.shotToast('Cannot open website');
      }
    } catch (e) {
      ToastUtils.shotToast('Failed to open website');
    }
  }

  Future<void> contactSupport() async {
    final url = Uri.parse('mailto:support@sonoul.app?subject=Sonoul Support Request');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ToastUtils.shotToast('Cannot open email client');
      }
    } catch (e) {
      ToastUtils.shotToast('Failed to open email');
    }
  }

  Future<void> openPrivacyPolicy() async {
    final url = Uri.parse('https://sonoul.app/privacy');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ToastUtils.shotToast('Cannot open privacy policy');
      }
    } catch (e) {
      ToastUtils.shotToast('Failed to open privacy policy');
    }
  }

  Future<void> openTermsOfService() async {
    final url = Uri.parse('https://sonoul.app/terms');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ToastUtils.shotToast('Cannot open terms of service');
      }
    } catch (e) {
      ToastUtils.shotToast('Failed to open terms');
    }
  }

  void logout() {
    _authController.logout();
  }

  void deleteAccount() {
    _authController.deleteAccount();
  }
}
