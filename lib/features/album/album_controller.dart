import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';

class AlbumController extends GetxController {
  // Mock data for now
  final RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[
    {
      'title': 'Summer Vibes',
      'artist': 'Virtual Singer',
      'cover_url': 'https://picsum.photos/200?random=1',
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'tags': ['Pop', 'Summer'],
    },
    {
      'title': 'Neon Dreams',
      'artist': 'Virtual Singer',
      'cover_url': 'https://picsum.photos/200?random=2',
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'tags': ['Electronic', 'Cyberpunk'],
    },
  ].obs;

  void openSongDetail(Map<String, dynamic> song) {
    Get.toNamed(AppRoutes.songDetail, arguments: song);
  }
}
