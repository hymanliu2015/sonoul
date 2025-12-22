import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_appbar.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/dash/dash_controller.dart';

class DashPage extends StatelessWidget {
  final DashController controller = Get.put(DashController());

  DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppbar(
        title: const Text(
          'Sonoul',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit', // Assuming a nice font, or default
          ),
        ),
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
                      return Column(
                        children: [
                          // Top Section: Virtual Singer Display
                          Expanded(
                            flex: 4,
                            child: _buildSingerDisplay(singer.name, singer.avatarUrl),
                          ),
                          
                          // Bottom Section: Action Buttons (Compact)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCompactActionButton(
                                  icon: Icons.mic_rounded,
                                  title: 'Create New Song',
                                  color: AppColors.primary,
                                  onTap: controller.goToCreateSingle,
                                ),
                                const SizedBox(height: 8),
                                _buildCompactActionButton(
                                  icon: Icons.album_rounded,
                                  title: 'My Album',
                                  color: AppColors.secondary,
                                  onTap: controller.goToAlbum,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              ],
            );
          }),
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
                color: Colors.black.withValues(alpha: 0.1),
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
          // Page Indicator Dots
          // if (controller.singers.length > 1)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 16),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: List.generate(controller.singers.length, (index) {
          //         return Obx(() => Container(
          //           margin: const EdgeInsets.symmetric(horizontal: 4),
          //           width: 8,
          //           height: 8,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: controller.currentSingerIndex.value == index
          //                 ? AppColors.primary
          //                 : Colors.grey.shade300,
          //           ),
          //         ));
          //       }),
          //     ),
          //   ),
          // 3D-like Avatar Container
          Container(
            width: 280,
            height: 350, // Taller for full body or bust shot
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: (avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : const NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=default'), // Fallback
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
          const SizedBox(height: 16),
          // Share Button
          GestureDetector(
            onTap: () => _showShareBottomSheet(Get.context!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const CustomText(
                    text: 'Share',
                    textFontSize: 14,
                    textColor: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    final singer = controller.currentSinger;
    if (singer == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: 'Share Your Singer',
              textFontSize: 20,
              fontWeight: FontWeight.bold,
              textColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 24),
            // Singer Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Singer Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: (singer.avatarUrl.isNotEmpty)
                            ? NetworkImage(singer.avatarUrl)
                            : const NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=default'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Singer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: singer.name,
                          textFontSize: 18,
                          fontWeight: FontWeight.bold,
                          textColor: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 4),
                        const CustomText(
                          text: 'Virtual Singer',
                          textFontSize: 12,
                          textColor: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.music_note_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            const CustomText(
                              text: 'Includes random song',
                              textFontSize: 12,
                              textColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Share Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                controller.shareSingerWithSong();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    CustomText(
                      text: 'Share Now',
                      textFontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                text: title,
                textFontSize: 15,
                fontWeight: FontWeight.w600,
                textColor: AppColors.textPrimary,
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
          ],
        ),
      ),
    );
  }
}

