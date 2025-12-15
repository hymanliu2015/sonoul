import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';

class AlbumController extends GetxController {
  final SupabaseSongService _songService = Get.put(SupabaseSongService());
  
  final RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    try {
      isLoading.value = true;
      debugPrint('AlbumController: Fetching all songs for current user');
      
      // Fetch all songs for user (no singer filter)
      final userSongs = await _songService.getUserSongs();
      debugPrint('AlbumController: Fetched ${userSongs.length} songs');
      songs.assignAll(userSongs);
    } catch (e) {
      debugPrint('AlbumController: Error fetching songs: $e');
      Get.snackbar('Error', 'Failed to load songs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openSongDetail(Map<String, dynamic> song) {
    Get.toNamed(AppRoutes.songDetail, arguments: song);
  }
}
