import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_appbar.dart';
import 'package:sonoul/components/custom_box.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/profile/profile_controller.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbar(
        title: CustomText(
          text: 'Profile',
          textFontSize: 18,
          fontWeight: FontWeight.bold,
          textColor: AppColors.textPrimary,
        ),
        backgroundColor: AppColors.background,
        actions: [
           // Settings button moved to body or keep here? 
           // User said "Settings icon put in personal center page", so maybe in the list or top right.
           // Let's put it in the list as per common pattern, or top right.
           // "以前是设置图标，设置图标放个人中心页" -> "Previously it was settings icon, put settings icon in profile page"
           // I'll put a settings button in the list.
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => CustomText(
                  text: controller.userEmail.value,
                  textFontSize: 18,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.textPrimary,
                )),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Membership Card
          Obx(() {
            final dashController = Get.find<DashController>();
            final isPremium = dashController.isPremium.value;
            
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPremium 
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)] // Gold gradient for premium
                      : [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple gradient for free
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isPremium ? const Color(0xFFFFD700) : const Color(0xFF667eea)).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPremium ? Icons.diamond : Icons.workspace_premium,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomText(
                          text: isPremium ? 'Premium Member' : 'Upgrade to Premium',
                          textFontSize: 18,
                          fontWeight: FontWeight.bold,
                          textColor: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: isPremium ? 'Active' : 'Free',
                          textFontSize: 12,
                          fontWeight: FontWeight.bold,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: isPremium 
                        ? 'Enjoy unlimited song generations and exclusive features'
                        : 'Unlock unlimited song generations and exclusive features',
                    textFontSize: 14,
                    textColor: Colors.white70,
                  ),
                  if (!isPremium) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.member),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Upgrade Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          CustomBox(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: controller.goToSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: CustomText(
                text: title,
                textFontSize: 16,
                textColor: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
