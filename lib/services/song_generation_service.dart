import 'package:get/get.dart';
import 'package:sonoul/services/lyrics_service.dart';
import 'package:sonoul/services/voice_analysis_service.dart';

class SongGenerationService extends GetxService {
  final LyricsService _lyricsService = Get.put(LyricsService());
  final VoiceAnalysisService _voiceAnalysisService = Get.put(VoiceAnalysisService());

  Future<Map<String, dynamic>> generateSong({
    required String idea,
    required String audioPath,
    required List<String> tags,
  }) async {
    // 1. Generate Lyrics
    final lyrics = await _lyricsService.generateLyrics(idea);

    // 2. Analyze Voice
    final voiceData = await _voiceAnalysisService.analyzeVoice(audioPath);

    // 3. Generate Song (Mock)
    await Future.delayed(const Duration(seconds: 4)); // Simulate song synthesis

    return {
      'title': 'My New Song',
      'lyrics': lyrics,
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Mock audio
      'cover_url': 'https://picsum.photos/200',
      'tags': tags,
      'emotion': voiceData['emotion'],
    };
  }
}
