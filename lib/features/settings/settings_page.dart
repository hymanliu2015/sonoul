import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/settings/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greenLight.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textOnDark, size: 18),
          ),
        ),
        title: Text(
          'settings_title'.tr,
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.greenDeep,
              Color(0xFF0A1F1B),
              Color(0xFF051512),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader('settings_general'.tr),
              _buildSection([
                Obx(
                  () => _buildSettingItem(
                    icon: Icons.translate_rounded,
                    title: 'settings_language'.tr,
                    subtitle: controller.currentLanguageLabel.value.isNotEmpty
                        ? controller.currentLanguageLabel.value
                        : 'settings_language_subtitle'.tr,
                    onTap: () => _showLanguageSheet(context),
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.share_rounded,
                  title: 'settings_share_app'.tr,
                  subtitle: 'settings_share_app_subtitle'.tr,
                  onTap: controller.shareApp,
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.star_rate_rounded,
                  title: 'settings_rate_app'.tr,
                  subtitle: 'settings_rate_app_subtitle'.tr,
                  onTap: controller.rateApp,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('settings_support'.tr),
              _buildSection([
                _buildSettingItem(
                  icon: Icons.language_rounded,
                  title: 'settings_website'.tr,
                  subtitle: 'settings_website_subtitle'.tr,
                  onTap: controller.openWebsite,
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.email_rounded,
                  title: 'settings_contact_support'.tr,
                  subtitle: 'settings_contact_support_subtitle'.tr,
                  onTap: controller.contactSupport,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('settings_legal'.tr),
              _buildSection([
                _buildSettingItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'settings_privacy_policy'.tr,
                  subtitle: 'settings_privacy_policy_subtitle'.tr,
                  onTap: controller.openPrivacyPolicy,
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.description_rounded,
                  title: 'settings_terms_of_service'.tr,
                  subtitle: 'settings_terms_of_service_subtitle'.tr,
                  onTap: controller.openTermsOfService,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('settings_account'.tr),
              _buildSection([
                _buildSettingItem(
                  icon: Icons.logout_rounded,
                  title: 'settings_logout'.tr,
                  subtitle: 'settings_logout_subtitle'.tr,
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: Text('settings_logout'.tr, style: const TextStyle(color: Colors.white)),
                        content: Text(
                          'settings_logout_confirm_content'.tr,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('settings_cancel'.tr, style: const TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.logout();
                            },
                            child: Text('settings_logout'.tr, style: const TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  showArrow: false,
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.delete_forever_rounded,
                  title: 'settings_delete_account'.tr,
                  subtitle: 'settings_delete_account_subtitle'.tr,
                  onTap: () {
                    Get.dialog(
                      _DeleteAccountDialog(
                        onDeleteConfirmed: () {
                          controller.deleteAccount();
                        },
                      ),
                    );
                  },
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  showArrow: false,
                ),
              ]),
              const SizedBox(height: 32),
              Obx(
                () => Center(
                  child: Text(
                    '${'settings_version'.tr} ${controller.appVersion.value}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.greenLight.withValues(alpha: 0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // For hit test
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.greenLight).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.greenLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1D1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'settings_language'.tr,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: SettingsController.supportedLocales.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (context, index) {
                      final option = SettingsController.supportedLocales[index];
                      return Obx(
                        () => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            option.labelValue,
                            style: const TextStyle(
                              color: AppColors.textOnDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: controller.currentLocaleCode.value == option.code
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.greenLight,
                                )
                              : null,
                          onTap: () {
                            controller.setLocale(option.code);
                            Get.back();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onDeleteConfirmed;

  const _DeleteAccountDialog({required this.onDeleteConfirmed});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  double _progress = 0.0;
  bool _isHolding = false;
  static const int _holdDurationSeconds = 5;

  void _startHolding() {
    setState(() {
      _isHolding = true;
      _progress = 0.0;
    });
    _animateProgress();
  }

  void _stopHolding() {
    setState(() {
      _isHolding = false;
      _progress = 0.0;
    });
  }

  void _animateProgress() async {
    const totalSteps = 50;
    const stepDuration = Duration(milliseconds: 100);

    for (int i = 0; i < totalSteps && _isHolding; i++) {
      await Future.delayed(stepDuration);
      if (_isHolding && mounted) {
        setState(() {
          _progress = (i + 1) / totalSteps;
        });

        if (_progress >= 1.0) {
          Get.back();
          widget.onDeleteConfirmed();
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title:  Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Text(
            'settings_delete_account'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings_delete_account_confirm_content'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'settings_hold_to_delete_hint'.trParams({'seconds': '$_holdDurationSeconds'}),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('settings_cancel'.tr, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onLongPressStart: (_) => _startHolding(),
          onLongPressEnd: (_) => _stopHolding(),
          onLongPressCancel: _stopHolding,
          child: Container(
            width: 130,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.redAccent.withValues(alpha: 0.1),
              border: Border.all(color: Colors.redAccent, width: 1),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.redAccent.withValues(alpha: 0.3),
                    ),
                    minHeight: 44,
                  ),
                ),
                Center(
                  child: Text(
                    _isHolding
                        ? '${(_holdDurationSeconds * (1 - _progress)).ceil()}s...'
                        : 'settings_hold_to_delete'.tr,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
