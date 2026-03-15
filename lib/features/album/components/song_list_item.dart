import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_cached_image.dart';

class SongListItem extends StatelessWidget {
  final Map<String, dynamic> song;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SongListItem({
    super.key,
    required this.song,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = song['status'] as String?;
    final isPlayable = status != 'pending' &&
        (status != 'processing' || _isTimedOut(song['created_at']));

    return GestureDetector(
      onTap: isPlayable ? onTap : null,
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
                    song['title'] ?? 'song_detail_title_unknown'.tr,
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
                            ? DateTime.parse(song['created_at'])
                                .toString()
                                .split(' ')[0]
                            : 'album_status_unknown'.tr,
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
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
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
    final fallbackUrl =
        'https://picsum.photos/seed/${song['id'] ?? 'default'}/200';

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
