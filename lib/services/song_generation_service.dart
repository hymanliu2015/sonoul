import 'dart:io';
import 'package:get/get.dart';
import 'package:sonoul/services/lyrics_service.dart';
import 'package:sonoul/services/voice_analysis_service.dart';
import 'package:sonoul/services/elevenlabs_service.dart';
import 'package:sonoul/services/supabase_song_service.dart';

class SongGenerationService extends GetxService {
  final LyricsService _lyricsService = Get.put(LyricsService());
  final VoiceAnalysisService _voiceAnalysisService = Get.put(VoiceAnalysisService());
  final ElevenLabsService _elevenLabsService = Get.put(ElevenLabsService());
  final SupabaseSongService _supabaseSongService = Get.put(SupabaseSongService());

  Future<Map<String, dynamic>> generateSong({
    required String idea,
    required String audioPath,
    required List<String> tags,
  }) async {
    // 1. Generate Lyrics (Mock or real implementation)
    final lyrics = await _lyricsService.generateLyrics(idea);

    // 2. Analyze Voice (Optional, for emotion/style)
    final voiceData = await _voiceAnalysisService.analyzeVoice(audioPath);
    final emotion = voiceData['emotion'] ?? 'Neutral';

    // 3. Generate Audio using ElevenLabs
    // Use the lyrics as text for speech generation
    // In a real music app, we might want to structure this better or use a music model
    final File? generatedAudioFile = await _elevenLabsService.generateSpeech(
      text: lyrics.isNotEmpty ? lyrics : idea,
    );

    if (generatedAudioFile == null) {
      throw Exception('Failed to generate audio from ElevenLabs');
    }

    // 4. Upload Audio to Supabase Storage
    final String fileName = 'song_${DateTime.now().millisecondsSinceEpoch}.mp3';
    final String? audioUrl = await _supabaseSongService.uploadSongAudio(generatedAudioFile, fileName);

    if (audioUrl == null) {
      throw Exception('Failed to upload audio to storage');
    }

    // 5. Save Song Record to Supabase Database
    final songRecord = await _supabaseSongService.createSong(
      title: 'Song about $idea', // Simple title generation
      audioUrl: audioUrl,
      lyrics: lyrics,
      idea: idea,
      tags: tags,
      emotion: emotion,
      duration: 30, // Mock duration or calculate from file
      coverUrl: 'https://picsum.photos/200?random=${DateTime.now().millisecondsSinceEpoch}',
    );

    if (songRecord == null) {
      throw Exception('Failed to save song record to database');
    }

    return songRecord;
  }
}
