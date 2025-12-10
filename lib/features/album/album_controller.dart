import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';
import 'package:sonoul/features/dash/dash_controller.dart';

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
      
      String? singerId;
      if (Get.isRegistered<DashController>()) {
        final dashController = Get.find<DashController>();
        if (dashController.currentSinger != null) {
          singerId = dashController.currentSinger!.id;
        }
      }
      
      final userSongs = await _songService.getUserSongs(singerId: singerId);
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
