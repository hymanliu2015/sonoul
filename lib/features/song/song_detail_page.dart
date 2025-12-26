import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_cached_image.dart';
import 'package:sonoul/features/song/song_detail_controller.dart';
import 'package:video_player/video_player.dart';

class SongDetailPage extends StatelessWidget {
  final SongDetailController controller = Get.put(SongDetailController());

  SongDetailPage({super.key});

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
        title: const Text(
          'Now Playing',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: controller.shareSong,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenLight.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(Icons.share_rounded, color: AppColors.greenLight, size: 20),
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
            colors: [
              AppColors.greenDeep,
              Color(0xFF0A1F1B),
              Color(0xFF051512),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() => Column(
              children: [
                const SizedBox(height: 20),
                // Cover / Video
                _buildMediaSection(context),
                const SizedBox(height: 32),
                // Song Title & Artist
                _buildSongInfo(),
                const SizedBox(height: 40),
                // Progress Bar
                _buildProgressBar(),
                const SizedBox(height: 32),
                // Playback Controls
                _buildPlaybackControls(),
                const SizedBox(height: 40),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    if (controller.isVideoInitialized.value && controller.videoController != null) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenPrimary.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: controller.videoController!.value.aspectRatio,
                child: VideoPlayer(controller.videoController!),
              ),
              // Border overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.greenLight.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Cover Image with glow effect
    return Container(
      width: 280,
      height: 280,
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
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomCachedImage(
              imageUrl: controller.song['cover_url'],
              fallbackUrl: 'https://picsum.photos/seed/${controller.song['id'] ?? 'default'}/300',
              fit: BoxFit.cover,
              placeholderIcon: Icons.music_note_rounded,
              placeholderIconSize: 80,
            ),
            // Subtle gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            // Border
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

  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          controller.song['title'] ?? 'Unknown Title',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnDark,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          controller.song['artist'] ?? 'AI Generated',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        // Tags / Style
        if (controller.song['style'] != null && controller.song['style'].toString().isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: (controller.song['style'] as String)
                .split(',')
                .take(3)
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.greenPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.greenLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        tag.trim(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.greenLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.greenLight,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: AppColors.greenLight,
              overlayColor: AppColors.greenLight.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 0,
              max: controller.duration.value.inSeconds.toDouble(),
              value: controller.position.value.inSeconds
                  .toDouble()
                  .clamp(0, controller.duration.value.inSeconds.toDouble()),
              onChanged: controller.seek,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(controller.position.value),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(controller.duration.value),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        GestureDetector(
          onTap: controller.hasPrevious ? controller.playPrevious : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: controller.hasPrevious ? 0.08 : 0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.skip_previous_rounded,
              color: Colors.white.withValues(alpha: controller.hasPrevious ? 0.8 : 0.2),
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Play/Pause
        GestureDetector(
          onTap: controller.togglePlay,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.greenLight, AppColors.greenPrimary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenPrimary.withValues(alpha: 0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              controller.isPlaying.value
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Next
        GestureDetector(
          onTap: controller.hasNext ? controller.playNext : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: controller.hasNext ? 0.08 : 0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.skip_next_rounded,
              color: Colors.white.withValues(alpha: controller.hasNext ? 0.8 : 0.2),
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
