import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_cached_image.dart';
import 'package:sonoul/features/album/album_controller.dart';
import 'package:sonoul/routes/app_routes.dart';

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
        actions: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.createSingle),
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
              return _buildEmptyState();
            }

            final hasProcessing = controller.songs
                .any((s) => s['status'] == 'pending' || s['status'] == 'processing');

            return RefreshIndicator(
              onRefresh: controller.fetchSongs,
              color: AppColors.greenLight,
              backgroundColor: AppColors.greenDeep,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.songs.length + (hasProcessing ? 1 : 0),
                itemBuilder: (context, index) {
                  if (hasProcessing && index == 0) {
                    return _buildProcessingCard();
                  }

                  final realIndex = hasProcessing ? index - 1 : index;
                  final song = controller.songs[realIndex];
                  return _buildSongCard(song, controller);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.createSingle),
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

  Widget _buildSongCard(Map<String, dynamic> song, AlbumController controller) {
    final status = song['status'] as String?;
    final isPlayable = status != 'pending' && 
                       (status != 'processing' || _isTimedOut(song['created_at']));

    return GestureDetector(
      onTap: isPlayable ? () => controller.openSongDetail(song) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildCoverImage(song),
                    if (song['video_url'] != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textOnDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        song['created_at'] != null
                            ? DateTime.parse(song['created_at']).toString().split(' ')[0]
                            : 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(status),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(song),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => controller.deleteSong(song['id']),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'album_status_pending'.tr;
        break;
      case 'processing':
        color = Colors.blue;
        text = 'album_status_processing'.tr;
        break;
      case 'completed':
        color = AppColors.greenLight;
        text = 'album_status_ready'.tr;
        break;
      case 'failed':
        color = Colors.red;
        text = 'album_status_failed'.tr;
        break;
      default:
        color = Colors.grey;
        text = status ?? 'album_status_unknown'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Map<String, dynamic> song) {
    final status = song['status'] as String?;

    if (status == 'pending') {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.hourglass_empty,
          color: Colors.orange,
          size: 28,
        ),
      );
    } else if (status == 'processing') {
      if (_isTimedOut(song['created_at'])) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 28,
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(8),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenLight),
          ),
        ),
      );
    } else if (status == 'failed') {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.error,
          color: Colors.red,
          size: 28,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.greenLight, AppColors.greenPrimary],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.greenPrimary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildCoverImage(Map<String, dynamic> song) {
    final url = song['cover_url'] as String?;
    final fallbackUrl = 'https://picsum.photos/seed/${song['id'] ?? 'default'}/200';

    return CustomCachedImage(
      imageUrl: url,
      fallbackUrl: fallbackUrl,
      fit: BoxFit.cover,
      placeholderIcon: Icons.music_note,
      placeholderIconSize: 24,
    );
  }

  bool _isTimedOut(String? createdAt) {
    if (createdAt == null) return false;
    final created = DateTime.parse(createdAt);
    final now = DateTime.now();
    return now.difference(created).inMinutes > 10;
  }
}
