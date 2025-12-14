import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/services/supabase_song_service.dart';

class SongGenerationService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SupabaseSongService _supabaseSongService = Get.put(SupabaseSongService());

  Future<Map<String, dynamic>> generateSong({
    required String idea,
    String? audioPath,
    required List<String> tags,
    required String singerId,
    bool isInstrumental = false,
  }) async {
    try {
      String? fileName;
      // 1. Upload User's Voice Recording to Storage (if provided)
      if (audioPath != null && audioPath.isNotEmpty) {
        final File audioFile = File(audioPath);
        fileName = 'voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final String? inputAudioUrl = await _supabaseSongService.uploadSongAudio(audioFile, fileName);

        if (inputAudioUrl == null) {
          throw Exception('Failed to upload voice recording');
        }
      }

      // 2. Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'generate-song',
        body: {
          'idea': idea,
          'audio_path': fileName, // Can be null
          'tags': tags,
          'user_id': _supabase.auth.currentUser?.id,
          'singer_id': singerId,
          'is_instrumental': isInstrumental,
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function Error: ${response.status} - ${response.data}');
      }

      // The Edge Function returns the created song record
      return Map<String, dynamic>.from(response.data);

    } catch (e) {
      debugPrint('Song Generation Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateSongFromEmotion({
    required String audioPath,
    required String singerId,
  }) async {
    try {
      // 1. Upload User's Voice Recording to Storage
      final File audioFile = File(audioPath);
      final String fileName = 'emotion_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final String? inputAudioUrl = await _supabaseSongService.uploadSongAudio(audioFile, fileName);

      if (inputAudioUrl == null) {
        throw Exception('Failed to upload voice recording');
      }

      // 2. Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'generate-song-emotion',
        body: {
          'audio_path': fileName,
          'user_id': _supabase.auth.currentUser?.id,
          'singer_id': singerId,
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function Error: ${response.status} - ${response.data}');
      }

      return Map<String, dynamic>.from(response.data);

    } catch (e) {
      debugPrint('Emotion Song Generation Error: $e');
      rethrow;
    }
  }
}
