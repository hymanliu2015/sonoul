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
      await _audioPlayer.play(UrlSource(song['audio_url']));
    }
  }

  void seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void shareSong() {
    SharePlus.instance.share(
        ShareParams(text: 'Check out my new song "${song['title']}" by ${song['artist']}! Listen here: ${song['audio_url']}')
    );
  }
}
