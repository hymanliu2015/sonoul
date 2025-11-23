import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_appbar.dart';
import 'package:sonoul/components/custom_box.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/settings/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbar(
        title: CustomText(
          text: 'Settings',
          textFontSize: 18,
          fontWeight: FontWeight.bold,
          textColor: AppColors.textPrimary,
        ),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('General'),
          _buildSection([
            _buildSettingItem(
              icon: Icons.share_rounded,
              title: 'Share App',
              subtitle: 'Share Sonoul with friends',
              onTap: controller.shareApp,
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.star_rate_rounded,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              onTap: controller.rateApp,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSection([
            _buildSettingItem(
              icon: Icons.language_rounded,
              title: 'Website',
              subtitle: 'Visit our website',
              onTap: controller.openWebsite,
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.email_rounded,
              title: 'Contact Support',
              subtitle: 'Get help from our team',
              onTap: controller.contactSupport,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Legal'),
          _buildSection([
            _buildSettingItem(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: controller.openPrivacyPolicy,
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.description_rounded,
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              onTap: controller.openTermsOfService,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          _buildSection([
            _buildSettingItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.logout();
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              iconColor: Colors.red,
              textColor: Colors.red,
              showArrow: false,
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.delete_forever_rounded,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteAccount();
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              iconColor: Colors.red,
              textColor: Colors.red,
              showArrow: false,
            ),
          ]),
          const SizedBox(height: 32),
          Obx(() => Center(
            child: CustomText(
              text: 'Version ${controller.appVersion.value}',
              textColor: AppColors.textSecondary,
              textFontSize: 12,
            ),
          )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: CustomText(
        text: title,
        textFontSize: 14,
        fontWeight: FontWeight.bold,
        textColor: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return CustomBox(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.textSecondary.withValues(alpha: 0.1),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    textFontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: textColor ?? AppColors.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: subtitle,
                    textFontSize: 12,
                    textColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
