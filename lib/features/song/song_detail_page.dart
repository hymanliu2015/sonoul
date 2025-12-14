import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/song/song_detail_controller.dart';

class SongDetailPage extends StatelessWidget {
  final SongDetailController controller = Get.put(SongDetailController());

  SongDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.song['title'] ?? 'Unknown Title'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareSong,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(controller.song['cover_url'] ?? 'https://via.placeholder.com/300'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              controller.song['title'] ?? 'Unknown Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              controller.song['artist'] ?? 'Unknown Artist',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Obx(() => Column(
              children: [
                Slider(
                  min: 0,
                  max: controller.duration.value.inSeconds.toDouble(),
                  value: controller.position.value.inSeconds.toDouble().clamp(0, controller.duration.value.inSeconds.toDouble()),
                  onChanged: controller.seek,
                  activeColor: AppColors.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(controller.position.value)),
                      Text(_formatDuration(controller.duration.value)),
                    ],
                  ),
                ),
              ],
            )),
            const SizedBox(height: 20),
            Obx(() => IconButton(
              iconSize: 80,
              icon: Icon(
                controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: AppColors.primary,
              ),
              onPressed: controller.togglePlay,
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
