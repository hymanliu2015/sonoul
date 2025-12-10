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
      final userSongs = await _songService.getUserSongs();
      songs.assignAll(userSongs);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load songs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openSongDetail(Map<String, dynamic> song) {
    Get.toNamed(AppRoutes.songDetail, arguments: song);
  }
}
