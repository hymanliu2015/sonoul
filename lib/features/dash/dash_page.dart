import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_cached_image.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/features/profile/profile_page.dart';
import 'package:sonoul/features/album/components/song_list_item.dart';

class DashPage extends StatelessWidget {
  final DashController controller = Get.put(DashController());

  DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Obx(() {
        return IndexedStack(
          index: controller.currentTab.value,
          children: [
            _buildHomeTab(),
            ProfilePage(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentTab.value,
            onTap: controller.changeTab,
            backgroundColor: const Color(0xFF0A1F1B),
            selectedItemColor: AppColors.greenLight,
            unselectedItemColor: Colors.white.withValues(alpha: 0.6),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_filled),
                ),
                label: 'dash_tab_home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person),
                ),
                label: 'dash_tab_profile'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 78,
        title: Obx(() {
          if (controller.isPremium.value) {
            return ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.goldStart, AppColors.goldEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                'dash_title'.tr,
                style: const TextStyle(
                  color: Colors.white, // Required for ShaderMask
                  fontSize: 24, // Slightly larger
                  fontWeight: FontWeight.w900, // Extra bold
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: AppColors.goldEnd,
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            );
          }
          return Text(
            'dash_title'.tr,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          );
        }),
        leading: Obx(() {
          if (controller.singers.isEmpty) {
            return const SizedBox.shrink();
          }
          final currentSinger = controller.currentSinger;
          return GestureDetector(
            onTap: () => _showSwitchSingerBottomSheet(Get.context!),
            child: Container(
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.greenLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (currentSinger != null)
                     CustomCachedImage(
                       imageUrl: currentSinger.avatarUrl,
                       width: 24,
                       height: 24,
                       borderRadius: BorderRadius.circular(12),
                       placeholderIconSize: 14,
                     )
                   else
                     const Icon(Icons.person, size: 24, color: Colors.white),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textOnDark,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }),
        actions: [
          GestureDetector(
            onTap: controller.goToCreateSingle,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greenPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.greenLight.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.greenLight,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.greenDeep, Color(0xFF0A1F1B), Color(0xFF051512)],
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.greenLight,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'dash_loading_singers'.tr,
                      style: const TextStyle(
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

            final singer = controller.currentSinger;
            if (singer == null) {
              return const SizedBox.shrink();
            }

            return _buildSingerPage(singer.name, singer.avatarUrl);
          }),
        ),
      ),
    );
  }

  Widget _buildSingerPage(String name, String avatarUrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
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
          // Album Header
          _buildAlbumHeader(),
          const SizedBox(height: 16),
          // Album list
          _buildAlbumList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSingerAvatar(String name, String avatarUrl) {
    return Container(
      width: 260,
      height: 260,
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
            CustomCachedImage(
              imageUrl: avatarUrl,
              fit: BoxFit.cover,
              placeholderIcon: Icons.person_outline,
              placeholderIconSize: 80,
            ),
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

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () => _showShareBottomSheet(Get.context!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share_rounded, size: 18, color: AppColors.greenLight),
            const SizedBox(width: 8),
            Text(
              'dash_share'.tr,
              style: const TextStyle(
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

  Widget _buildAlbumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'dash_my_album'.tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnDark,
          ),
        ),
        GestureDetector(
          onTap: controller.goToAlbum,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'dash_more'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumList() {
    return Obx(() {
      if (controller.isSongsLoading.value && controller.songs.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
            ),
          ),
        );
      }

      if (controller.songs.isEmpty) {
        return _buildEmptyAlbumState();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.songs.length > 10 ? 10 : controller.songs.length,
        itemBuilder: (context, index) {
          final song = controller.songs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SongListItem(
              song: song,
              onTap: () => controller.openSongDetail(song),
              onDelete: () => controller.deleteSong(song['id']),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyAlbumState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 48,
              color: AppColors.greenLight.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'album_empty_title'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'album_empty_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: controller.goToCreateSingle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'album_create_song'.tr,
                    style: const TextStyle(
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

  Widget _buildEmptySingerState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.greenLight.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 56,
              color: AppColors.greenLight.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'dash_no_singer'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'dash_create_first_singer_hint'.tr,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'dash_create_singer'.tr,
                    style: const TextStyle(
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
            colors: [Color(0xFF1A3D35), AppColors.greenDeep],
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
            Text(
              'dash_share_singer_title'.tr,
              style: const TextStyle(
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  // Singer Avatar
                  CustomCachedImage(
                    imageUrl: singer.avatarUrl,
                    width: 70,
                    height: 70,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                          'dash_singer_role'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.music_note_rounded,
                              size: 14,
                              color: AppColors.greenLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'dash_includes_random_song'.tr,
                              style: const TextStyle(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'dash_share_now'.tr,
                      style: const TextStyle(
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

  void _showSwitchSingerBottomSheet(BuildContext context) {
    if (controller.singers.isEmpty) return;

    // Use a local variable to hold temporary selection state when BottomSheet is open
    int tempSelectedIndex = controller.currentSingerIndex.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A3D35), AppColors.greenDeep],
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
                // Header (Cancel/Title/Switch)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'dash_cancel'.tr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'dash_switch_singer_title'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.changeActiveSinger(tempSelectedIndex);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'dash_switch'.tr,
                          style: const TextStyle(
                            color: AppColors.greenLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Singer List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.singers.length,
                    itemBuilder: (context, index) {
                      final singer = controller.singers[index];
                      final isSelected = tempSelectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.greenLight.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.greenLight
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomCachedImage(
                                imageUrl: singer.avatarUrl,
                                width: 48,
                                height: 48,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  singer.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.greenLight,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Create Singer Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      controller.goToCreateSinger();
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'dash_create_singer'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Safe Area padding for bottom
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }
}
