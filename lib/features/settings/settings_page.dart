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
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          _buildListTile(
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Share Sonoul with friends',
            onTap: controller.shareApp,
          ),
          _buildListTile(
            icon: Icons.star_rate,
            title: 'Rate App',
            subtitle: 'Rate us on the app store',
            onTap: controller.rateApp,
          ),
          const Divider(),
          _buildSectionHeader('Support'),
          _buildListTile(
            icon: Icons.language,
            title: 'Website',
            subtitle: 'Visit our website',
            onTap: controller.openWebsite,
          ),
          _buildListTile(
            icon: Icons.email,
            title: 'Contact Support',
            subtitle: 'Get help from our team',
            onTap: controller.contactSupport,
          ),
          const Divider(),
          _buildSectionHeader('Legal'),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: controller.openPrivacyPolicy,
          ),
          _buildListTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: controller.openTermsOfService,
          ),
          const Divider(),
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.logout,
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
          ),
          const SizedBox(height: 20),
          Obx(() => Center(
            child: Text(
              'Version ${controller.appVersion.value}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
