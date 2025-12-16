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
      String? inputAudioUrl;
      if (audioPath != null && audioPath.isNotEmpty) {
        final File audioFile = File(audioPath);
        if (audioFile.existsSync()) {
          final fileName = 'voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
          inputAudioUrl = await _supabaseSongService.uploadSongAudio(audioFile, fileName);
        }
      }

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Insert into songs table to trigger the Webhook
      final response = await _supabase
          .from('songs')
          .insert({
            'user_id': user.id,
            'singer_id': singerId, // Top-level column
            'prompt': idea,
            'tags': tags,
            'style': tags.join(','),
            'title': idea.length > 20 ? '${idea.substring(0, 20)}...' : idea,
            'instrumental': isInstrumental,
            'status': 'pending',
            'meta': {
              'input_audio_url': inputAudioUrl,
              'source': 'generateSong',
            }
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);

    } catch (e) {
      debugPrint('Song Generation Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateSongFromEmotion({
    required String audioPath,
    required String singerId,
    String? idea,
    List<String>? tags,
    bool isInstrumental = false,
  }) async {
    try {
      String? inputAudioUrl;
      if (audioPath.isNotEmpty) {
        final File audioFile = File(audioPath);
        if (audioFile.existsSync()) {
          final fileName = 'emotion_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
          inputAudioUrl = await _supabaseSongService.uploadSongAudio(audioFile, fileName);
        } else {
           throw Exception('Audio file not found');
        }
      }

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Insert into songs table to trigger the Webhook
      final response = await _supabase
          .from('songs')
          .insert({
            'user_id': user.id,
            'singer_id': singerId,
            'prompt': idea ?? 'Emotion based song',
            'tags': tags ?? [],
            'style': tags?.join(',') ?? 'Emotion',
            'instrumental': isInstrumental,
            'status': 'pending',
            'meta': {
              'input_audio_url': inputAudioUrl,
              'source': 'generateSongFromEmotion',
              'audioWeight': 0.65, 
              'styleWeight': 0.65,
            }
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);

    } catch (e) {
      debugPrint('Emotion Song Generation Error: $e');
      rethrow;
    }
  }
}
