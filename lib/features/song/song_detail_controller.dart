import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class SongDetailController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  late Map<String, dynamic> song;
  RxBool isPlaying = false.obs;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    song = Get.arguments as Map<String, dynamic>;
    
    _audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });
    
    _audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> togglePlay() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      final audioUrl = song['audio_url'];
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await _audioPlayer.play(UrlSource(audioUrl));
      } else {
        Get.snackbar('Error', 'Audio URL is missing');
      }
    }
  }

  void seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void shareSong() {
    final title = song['title'] ?? 'Unknown Title';
    final artist = song['artist'] ?? 'Unknown Artist';
    final audioUrl = song['audio_url'] ?? '';
    
    SharePlus.instance.share(
        ShareParams(text: 'Check out my new song "$title" by $artist! Listen here: $audioUrl')
    );
  }
}
