import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No songs yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.createSingle),
                  child: const Text('Create your first song'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchSongs,
          child: ListView.builder(
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
                      song['cover_url'] ?? 'https://picsum.photos/200',
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
                    song['title'] ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(song['created_at'] != null 
                      ? DateTime.parse(song['created_at']).toString().split(' ')[0] 
                      : 'Unknown Date'),
                  trailing: song['status'] == 'processing'
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_fill, size: 32),
                  onTap: song['status'] == 'processing'
                      ? null
                      : () => controller.openSongDetail(song),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
