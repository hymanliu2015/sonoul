import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class SongDetailController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? videoController;
  
  late Map<String, dynamic> song;
  RxBool isPlaying = false.obs;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  RxBool isVideoInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    song = Get.arguments as Map<String, dynamic>;
    
    final videoUrl = song['video_url'];
    if (videoUrl != null && videoUrl.toString().isNotEmpty) {
      _initializeVideo(videoUrl);
    } else {
      _initializeAudio();
    }
  }

  Future<void> _initializeVideo(String url) async {
    try {
      videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoController!.initialize();
      isVideoInitialized.value = true;
      duration.value = videoController!.value.duration;

      videoController!.addListener(() {
        final value = videoController!.value;
        isPlaying.value = value.isPlaying;
        position.value = value.position;
        if (value.duration > Duration.zero) {
           duration.value = value.duration;
        }
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
      // Fallback to audio if video fails?
      _initializeAudio();
    }
  }

  void _initializeAudio() {
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
    videoController?.dispose();
    super.onClose();
  }

  Future<void> togglePlay() async {
    if (videoController != null && videoController!.value.isInitialized) {
      if (videoController!.value.isPlaying) {
        await videoController!.pause();
      } else {
        await videoController!.play();
      }
    } else {
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
  }

  void seek(double value) {
    final position = Duration(seconds: value.toInt());
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.seekTo(position);
    } else {
      _audioPlayer.seek(position);
    }
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
