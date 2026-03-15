import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/album/album_controller.dart';
import 'package:sonoul/features/album/components/song_list_item.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final shouldRefresh = args != null && args['refresh'] == true;

    if (shouldRefresh && Get.isRegistered<AlbumController>()) {
      Get.delete<AlbumController>();
    }

    final controller = Get.put(AlbumController());

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
          controller.singerName != null && controller.singerName!.isNotEmpty
              ? "${controller.singerName}${'album_page_title_suffix'.tr}"
              : "album_page_title".tr,
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
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
            if (controller.isLoading.value) {
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
                    Text(
                      'album_loading'.tr,
                      style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.songs.isEmpty) {
              return _buildEmptyState(controller);
            }

            final hasProcessing = controller.songs
                .any((s) => s['status'] == 'pending' || s['status'] == 'processing');

            return RefreshIndicator(
              onRefresh: () => controller.fetchSongs(showLoading: false),
              color: AppColors.greenLight,
              backgroundColor: AppColors.greenDeep,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.songs.length + (hasProcessing ? 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    if (hasProcessing && index == 0) {
                      return _buildProcessingCard();
                    }

                    final realIndex = hasProcessing ? index - 1 : index;

                    if (realIndex == controller.songs.length) {
                      return Obx(() {
                        if (controller.isLoadingMore.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
                              ),
                            ),
                          );
                        } else if (!controller.hasMore.value && controller.songs.isNotEmpty) {
                          return  Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'album_no_more'.tr, 
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      });
                    }

                    final song = controller.songs[realIndex];
                    return SongListItem(
                      song: song,
                      onTap: () => controller.openSongDetail(song),
                      onDelete: () => controller.deleteSong(song['id']),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AlbumController controller) {
    return Center(
      child: Padding(
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
              'album_empty_title'.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'album_empty_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.greenPrimary.withValues(alpha: 0.2),
            AppColors.greenDark.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greenLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greenLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.greenLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'album_creating_title'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'album_creating_desc'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
