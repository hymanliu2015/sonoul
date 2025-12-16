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
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    song = Get.arguments as Map<String, dynamic>;
    
    // Always init Audio (Master)
    _initializeAudio();

    // Check Video (Visual/Background)
    final videoUrl = song['video_url'];
    if (videoUrl != null && videoUrl.toString().isNotEmpty) {
      _initializeVideo(videoUrl.toString());
    }
  }

  Future<void> _initializeVideo(String url) async {
    try {
      debugPrint('SongDetailController: Initializing background video: $url');
      videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoController!.initialize();
      await videoController!.setVolume(0); // Mute video so it doesn't clash with audio
      await videoController!.setLooping(true); // Loop video like a canvas
      await videoController!.play(); // Auto-play
      isVideoInitialized.value = true;
    } catch (e) {
      debugPrint('SongDetailController: Error initializing video: $e');
      // Just ignore video failure, audio is main.
    }
  }

  void _initializeAudio() {
    debugPrint('SongDetailController: Initializing audio mode');
    _audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });
    
    _audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      // Sync video play state with audio? 
      // User said "Video auto play", maybe independent?
      // Let's keep video looping independently for now, unless user pauses?
      if (videoController != null && videoController!.value.isInitialized) {
         if (state == PlayerState.playing) {
           videoController!.play();
         } else {
           videoController!.pause();
         }
      }
    });

    // Pre-load audio
    final audioUrl = song['audio_url'];
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        _audioPlayer.setSourceUrl(audioUrl);
      } catch (e) {
         debugPrint('SongDetailController: Error setting audio source: $e');
      }
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    videoController?.dispose();
    super.onClose();
  }

  Future<void> togglePlay() async {
    // Only controls Audio
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      final audioUrl = song['audio_url'];
      if (audioUrl != null && audioUrl.isNotEmpty) {
         try {
           await _audioPlayer.play(UrlSource(audioUrl));
         } catch (e) {
           Get.snackbar('Error', 'Could not play audio');
         }
      } else {
        Get.snackbar('Error', 'Audio URL is missing');
      }
    }
  }

  void seek(double value) {
    // Only seeks Audio
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void shareSong() {
    final title = song['title'] ?? 'Unknown Title';
    final artist = song['artist'] ?? 'Unknown Artist';
    final audioUrl = song['audio_url'] ?? '';
    SharePlus.instance.share(ShareParams(text: 'Check out my new song "$title" by $artist! Listen here: $audioUrl'));
  }
}
