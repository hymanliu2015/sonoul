import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class SongDetailController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? videoController;
  
  final RxMap<String, dynamic> song = <String, dynamic>{}.obs;
  List<Map<String, dynamic>> playlist = [];
  final RxInt currentIndex = (-1).obs;

  final RxBool isPlaying = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  
  final RxBool isVideoInitialized = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is Map<String, dynamic> && args.containsKey('playlist')) {
      song.value = args['song'];
      playlist = (args['playlist'] as List).cast<Map<String, dynamic>>();
      currentIndex.value = playlist.indexWhere((s) => s['id'] == song['id']);
      debugPrint('SongDetailController: Playlist received. Length: ${playlist.length}, Current Index: ${currentIndex.value}');
    } else {
      // Fallback for direct song opening (without playlist)
      debugPrint('SongDetailController: No playlist received, using fallback');
      final Map<String, dynamic> singleSong = args is Map<String, dynamic> ? args : {};
      song.value = singleSong;
      playlist = [singleSong];
      currentIndex.value = 0;
    }
    
    if (currentIndex.value == -1 && playlist.isNotEmpty) {
      debugPrint('SongDetailController: Warning: Current song not found in playlist. Defaulting to 0.');
      currentIndex.value = 0;
      song.value = playlist[0];
    }
    
    // Always init Audio (Master)
    _initializeAudio();

    // Check Video (Visual/Background)
    _loadCurrentSongMedia();
  }

  Future<void> _loadCurrentSongMedia() async {
    // Reset states
    position.value = Duration.zero;
    duration.value = Duration.zero;
    isPlaying.value = false;
    isVideoInitialized.value = false;
    
    // Cleanup previous video if any
    if (videoController != null) {
      await videoController!.dispose();
      videoController = null;
    }
    
    // Setup Audio
    final audioUrl = song['audio_url'];
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        debugPrint('SongDetailController: Setting audio source: $audioUrl');
        await _audioPlayer.setSourceUrl(audioUrl);
        await _audioPlayer.resume(); // Auto-play on switch
      } catch (e) {
         debugPrint('SongDetailController: Error setting audio source: $e');
      }
    } else {
      debugPrint('SongDetailController: Audio URL is empty for current song');
    }

    // Setup Video
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
      
      if (videoController != null && videoController!.value.isInitialized) {
         if (state == PlayerState.playing) {
           videoController!.play();
         } else {
           videoController!.pause();
         }
      }
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    videoController?.dispose();
    super.onClose();
  }

  Future<void> togglePlay() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      final audioUrl = song['audio_url'];
      if (audioUrl != null && audioUrl.isNotEmpty) {
         try {
           if (_audioPlayer.source == null) {
              await _audioPlayer.setSourceUrl(audioUrl);
           }
           await _audioPlayer.resume();
         } catch (e) {
           Get.snackbar('Error', 'error_play_audio'.tr);
         }
      } else {
        Get.snackbar('Error', 'error_audio_url_missing'.tr);
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
    SharePlus.instance.share(ShareParams(text: 'song_share_text'.trParams({
      'title': title,
      'artist': artist,
      'url': audioUrl,
    })));
  }

  // Playlist Navigation
  void playNext() {
    debugPrint('SongDetailController: playNext called. Current index: ${currentIndex.value}, Total songs: ${playlist.length}');
    if (playlist.isEmpty || currentIndex.value >= playlist.length - 1) {
      debugPrint('SongDetailController: Cannot play next (at end or empty)');
      return;
    }
    
    currentIndex.value++;
    song.value = playlist[currentIndex.value];
    debugPrint('SongDetailController: Switched to next song: ${song['title']} (Index: ${currentIndex.value})');
    _loadCurrentSongMedia();
  }

  void playPrevious() {
    debugPrint('SongDetailController: playPrevious called. Current index: ${currentIndex.value}');
    if (playlist.isEmpty || currentIndex.value <= 0) {
      debugPrint('SongDetailController: Cannot play previous (at start or empty)');
      return;
    }
    
    currentIndex.value--;
    song.value = playlist[currentIndex.value];
    debugPrint('SongDetailController: Switched to previous song: ${song['title']} (Index: ${currentIndex.value})');
    _loadCurrentSongMedia();
  }

  bool get hasNext => currentIndex.value < playlist.length - 1;
  bool get hasPrevious => currentIndex.value > 0;
}
