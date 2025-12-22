import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/dash/dash_controller.dart';

class DashPage extends StatelessWidget {
  final DashController controller = Get.put(DashController());

  DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Sonoul',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: GestureDetector(
          onTap: controller.goToProfile,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greenLight.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.textOnDark, size: 20),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: controller.goToCreateSinger,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greenPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenLight.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(Icons.add, color: AppColors.greenLight, size: 20),
            ),
          ),
        ],
      ),
      body: Container(
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
          child: Obx(() {
            // 首次加载且没有缓存数据时显示 loading
            if (controller.isLoading.value && controller.singers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Loading your singers...',
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

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
                      return _buildSingerPage(singer.name, singer.avatarUrl, index);
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

  Widget _buildSingerPage(String name, String avatarUrl, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Page Indicator
          if (controller.singers.length > 1)
            _buildPageIndicator(index),
          const SizedBox(height: 20),
          // Singer Avatar with glow effect
          _buildSingerAvatar(name, avatarUrl),
          const SizedBox(height: 24),
          // Singer Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnDark,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // Share Button
          _buildShareButton(),
          const SizedBox(height: 32),
          // Action Cards
          _buildActionCards(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.singers.length, (index) {
        final isActive = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive 
                ? AppColors.greenLight 
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildSingerAvatar(String name, String avatarUrl) {
    return Container(
      width: 260,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenPrimary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppColors.greenLight.withValues(alpha: 0.2),
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Avatar Image
            avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                  )
                : _buildAvatarPlaceholder(),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Border glow effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.greenLight.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.greenDark,
            AppColors.greenDeep,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 80,
          color: AppColors.greenLight,
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () => _showShareBottomSheet(Get.context!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.share_rounded,
              size: 18,
              color: AppColors.greenLight,
            ),
            const SizedBox(width: 8),
            const Text(
              'Share',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greenLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        _buildGlassActionCard(
          icon: Icons.mic_rounded,
          title: 'Create New Song',
          subtitle: 'Generate AI music with your singer',
          gradientColors: [AppColors.greenLight, AppColors.greenPrimary],
          onTap: controller.goToCreateSingle,
        ),
        const SizedBox(height: 16),
        _buildGlassActionCard(
          icon: Icons.album_rounded,
          title: 'My Album',
          subtitle: 'View all your generated songs',
          gradientColors: [AppColors.greenMain, AppColors.greenDark],
          onTap: controller.goToAlbum,
        ),
      ],
    );
  }

  Widget _buildGlassActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySingerState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.greenLight.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenPrimary.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              size: 64,
              color: AppColors.greenLight.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Virtual Singer Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first AI singer to start\ngenerating amazing music!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: controller.goToCreateSinger,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.greenLight, AppColors.greenPrimary],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greenPrimary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Create Singer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3D35),
              AppColors.greenDeep,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: AppColors.greenLight.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Share Your Singer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 24),
            // Singer Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  // Singer Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: (singer.avatarUrl.isNotEmpty)
                            ? NetworkImage(singer.avatarUrl)
                            : const NetworkImage(
                                'https://api.dicebear.com/7.x/avataaars/png?seed=default'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: AppColors.greenLight.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Singer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          singer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Virtual Singer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 14,
                              color: AppColors.greenLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Includes random song',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.greenLight,
                              ),
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
                  gradient: const LinearGradient(
                    colors: [AppColors.greenLight, AppColors.greenPrimary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greenPrimary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Share Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
}
