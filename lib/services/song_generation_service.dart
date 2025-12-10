import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/services/supabase_song_service.dart';

class SongGenerationService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SupabaseSongService _supabaseSongService = Get.put(SupabaseSongService());

  Future<Map<String, dynamic>> generateSong({
    required String idea,
    required String audioPath,
    required List<String> tags,
    required String singerId,
  }) async {
    try {
      // 1. Upload User's Voice Recording to Storage
      // We need to upload this first so the Edge Function can access it (if needed for analysis)
      final File audioFile = File(audioPath);
      final String fileName = 'voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final String? inputAudioUrl = await _supabaseSongService.uploadSongAudio(audioFile, fileName);

      if (inputAudioUrl == null) {
        throw Exception('Failed to upload voice recording');
      }

      // 2. Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'generate-song',
        body: {
          'idea': idea,
          'audio_path': fileName, // Pass the path/filename, function can construct URL if needed
          'tags': tags,
          'user_id': _supabase.auth.currentUser?.id,
          'singer_id': singerId,
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function Error: ${response.status} - ${response.data}');
      }

      // The Edge Function returns the created song record
      return Map<String, dynamic>.from(response.data);

    } catch (e) {
      print('Song Generation Error: $e');
      rethrow;
    }
  }
}
