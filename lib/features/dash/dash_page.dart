import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/dash/dash_controller.dart';

class DashPage extends StatelessWidget {
  final DashController controller = Get.put(DashController());

  DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textPrimary, width: 1.5),
            ),
            child: const Icon(Icons.person, color: AppColors.textPrimary),
          ),
          onPressed: controller.goToProfile,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textPrimary, width: 1.5),
                ),
                child: const Icon(Icons.add, color: AppColors.textPrimary),
              ),
              onPressed: controller.goToCreateSinger,
              tooltip: 'Create My Singer',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Section: Virtual Singer Display (PageView)
              Expanded(
                flex: 4, // Increased space for singer
                child: Obx(() {
                  if (controller.singers.isEmpty) {
                    return Center(child: _buildEmptySingerState());
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: controller.singers.length,
                          onPageChanged: controller.onPageChanged,
                          itemBuilder: (context, index) {
                            final singer = controller.singers[index];
                            return _buildSingerDisplay(singer.name, singer.avatarUrl);
                          },
                        ),
                      ),
                      // Page Indicator
                      if (controller.singers.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(controller.singers.length, (index) {
                            return Obx(() => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.currentSingerIndex.value == index
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            ));
                          }),
                        ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ),
              
              // Bottom Section: Action Buttons
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.mic_rounded,
                          title: 'Create New Song',
                          subtitle: 'Write lyrics & generate music',
                          color: AppColors.primary,
                          onTap: controller.goToCreateSingle,
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          icon: Icons.album_rounded,
                          title: 'My Album',
                          subtitle: 'Listen to your collection',
                          color: AppColors.secondary,
                          onTap: controller.goToAlbum,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySingerState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        const CustomText(
          text: 'No Virtual Singer Yet',
          textFontSize: 20,
          fontWeight: FontWeight.bold,
          textColor: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        const CustomText(
          text: 'Tap the + button to create one!',
          textFontSize: 14,
          textColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildSingerDisplay(String name, String avatarUrl) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D-like Avatar Container
          Container(
            width: 280,
            height: 350, // Taller for full body or bust shot
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomText(
            text: name,
            textFontSize: 28,
            fontWeight: FontWeight.bold,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CustomText(
              text: 'Virtual Singer',
              textFontSize: 12,
              textColor: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    textFontSize: 18,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: subtitle,
                    textFontSize: 13,
                    textColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
