import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseSongService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadSongAudio(File audioFile, String fileName) async {
    try {
      final String path = 'audio/$fileName';
      await _supabase.storage.from('songs').upload(
        path,
        audioFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      final String publicUrl = _supabase.storage.from('songs').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createSong({
    required String title,
    required String audioUrl,
    String? lyrics,
    String? idea,
    List<String>? tags,
    String? emotion,
    int? duration,
    String? coverUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase.from('songs').insert({
        'user_id': user.id,
        'title': title,
        'audio_url': audioUrl,
        'lyrics': lyrics,
        'idea': idea,
        'tags': tags,
        'emotion': emotion,
        'duration': duration,
        'cover_url': coverUrl ?? 'https://picsum.photos/200', // Default or random cover
      }).select().single();

      return response;
    } catch (e) {
      print('Error creating song record: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSongs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('songs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user songs: $e');
      return [];
    }
  }
}
