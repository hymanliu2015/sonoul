import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sonoul/common/config/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sonoul/utils/review_util.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'dart:ui';

class SettingsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  final RxString appVersion = ''.obs;
  final RxString currentLocaleCode = ''.obs;
  final RxString currentLanguageLabel = ''.obs;

  static const String _localeKey = 'app_locale';
  static const String _systemLocaleCode = 'system';

  static const List<LocaleOption> supportedLocales = [
    LocaleOption(code: _systemLocaleCode, labelKey: 'settings_language_system'),
    LocaleOption(code: 'en_US', label: 'English', locale: Locale('en', 'US')),
    LocaleOption(code: 'zh_CN', label: '简体中文', locale: Locale('zh', 'CN')),
    LocaleOption(code: 'zh_TW', label: '繁體中文', locale: Locale('zh', 'TW')),
    LocaleOption(code: 'es_ES', label: 'Español', locale: Locale('es', 'ES')),
    LocaleOption(code: 'pt_PT', label: 'Português', locale: Locale('pt', 'PT')),
    LocaleOption(code: 'de_DE', label: 'Deutsch', locale: Locale('de', 'DE')),
    LocaleOption(code: 'it_IT', label: 'Italiano', locale: Locale('it', 'IT')),
    LocaleOption(code: 'fr_FR', label: 'Français', locale: Locale('fr', 'FR')),
    LocaleOption(code: 'ja_JP', label: '日本語', locale: Locale('ja', 'JP')),
    LocaleOption(code: 'ko_KR', label: '한국어', locale: Locale('ko', 'KR')),
    LocaleOption(code: 'ru_RU', label: 'Русский', locale: Locale('ru', 'RU')),
    LocaleOption(code: 'ar_SA', label: 'العربية', locale: Locale('ar', 'SA')),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    _loadCurrentLocale();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      appVersion.value = '1.0.0';
    }
  }

  void _loadCurrentLocale() {
    final storedCode = SpUtil.getString(_localeKey, defValue: '') ?? '';
    final LocaleOption? option = storedCode.isEmpty
        ? _optionByCode(_systemLocaleCode)
        : _optionByCode(storedCode) ??
        _optionByLocale(Get.locale) ??
        _optionByLocale(Get.deviceLocale) ??
        supportedLocales.first;
    currentLocaleCode.value = option?.code ?? "";
    currentLanguageLabel.value = option?.labelValue ?? "";
  }

  void setLocale(String code) {
    final option = _optionByCode(code);
    if (option == null) return;
    if (option.code == _systemLocaleCode) {
      SpUtil.remove(_localeKey);
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null) {
        Get.updateLocale(deviceLocale);
      }
    } else {
      SpUtil.putString(_localeKey, option.code);
      Get.updateLocale(option.locale);
    }
    currentLocaleCode.value = option.code;
    currentLanguageLabel.value = option.labelValue;
  }

  LocaleOption? _optionByCode(String code) {
    if (code.isEmpty) return null;
    for (final option in supportedLocales) {
      if (option.code == code) return option;
    }
    return null;
  }

  LocaleOption? _optionByLocale(Locale? locale) {
    if (locale == null) return null;
    for (final option in supportedLocales) {
      if (option.locale.languageCode == locale.languageCode &&
          option.locale.countryCode == locale.countryCode) {
        return option;
      }
    }
    return null;
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

class LocaleOption {
  final String code;
  final String? labelKey;
  final String? label;
  final Locale locale;

  const LocaleOption({
    required this.code,
    this.labelKey,
    this.label,
    this.locale = const Locale('en', 'US'),
  });

  String get labelValue => labelKey != null ? labelKey!.tr : (label ?? code);
}
