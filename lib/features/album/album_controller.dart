import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';

class AlbumController extends GetxController {
  final SupabaseSongService _songService = Get.put(SupabaseSongService());
  
  final RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // 当前专辑对应的虚拟歌手（可为空，表示所有歌手）
  late final String? singerId;
  late final String? singerName;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    singerId = args != null ? args['singerId'] as String? : null;
    singerName = args != null ? args['singerName'] as String? : null;

    fetchSongs();
    
    // Listen for real-time song updates
    _songService.onSongGenerated.listen((updatedSong) {
      if (updatedSong != null) {
        debugPrint('AlbumController: Received song update: ${updatedSong['title']} - ${updatedSong['status']}');
        
        // Optimistic update: Find and update the song locally
        final index = songs.indexWhere((s) => s['id'] == updatedSong['id']);
        if (index != -1) {
          songs[index] = updatedSong;
          songs.refresh(); // Notify listeners of update
        } else {
          // If song not found (e.g. new song), add to top or refresh
          // For now, simple insert at top as list is ordered by created_at desc
          songs.insert(0, updatedSong);
        }
      }
    });
  }

  Future<void> fetchSongs({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      debugPrint(
        'AlbumController: Fetching songs for current user, singerId=$singerId (loading: $showLoading)',
      );
      
      // 按当前虚拟歌手过滤歌曲；如果 singerId 为空，则为用户全部歌曲
      final userSongs = await _songService.getUserSongs(singerId: singerId);
      debugPrint('AlbumController: Fetched ${userSongs.length} songs');
      songs.assignAll(userSongs);
    } catch (e) {
      debugPrint('AlbumController: Error fetching songs: $e');
      Get.snackbar('Error', 'Failed to load songs: $e');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void openSongDetail(Map<String, dynamic> song) {
    Get.toNamed(AppRoutes.songDetail, arguments: song);
  }

  Future<void> deleteSong(String songId) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Song'),
        content: const Text('Are you sure you want to delete this song?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                isLoading.value = true;
                await _songService.deleteSong(songId);
                songs.removeWhere((s) => s['id'] == songId);
                Get.snackbar('Success', 'Song deleted');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete song');
              } finally {
                isLoading.value = false;
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
