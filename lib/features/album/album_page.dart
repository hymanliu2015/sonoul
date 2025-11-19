import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/aoo_colors.dart';
import 'package:sonoul/features/album/album_controller.dart';
import 'package:sonoul/routes/app_routes.dart';

class AlbumPage extends StatelessWidget {
  final AlbumController controller = Get.put(AlbumController());

  AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Album'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.createSingle),
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.songs.length,
        itemBuilder: (context, index) {
          final song = controller.songs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song['cover_url'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
              title: Text(
                song['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(song['artist']),
              trailing: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
              onTap: () => controller.openSongDetail(song),
            ),
          );
        },
      )),
    );
  }
}
