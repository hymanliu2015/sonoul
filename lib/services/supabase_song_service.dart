import 'dart:io';
import 'package:flutter/widgets.dart';
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
      debugPrint('Error uploading audio: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSongs({String? singerId}) async {
    try {
      debugPrint('SupabaseSongService: Fetching songs...');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('SupabaseSongService: No current user');
        return [];
      }

      var query = _supabase
          .from('songs')
          .select()
          .eq('user_id', user.id);

      if (singerId != null && singerId.isNotEmpty) {
        query = query.eq('singer_id', singerId);
      }

      final response = await query.order('created_at', ascending: false);
      debugPrint('SupabaseSongService: Got response: ${response.length} songs');

      // Explicit type conversion
      return List<Map<String, dynamic>>.from(
        response.map((item) => Map<String, dynamic>.from(item))
      );

    } catch (e) {
      debugPrint('SupabaseSongService: Error fetching user songs: $e');
      return [];
    }
  }

  Future<int> getUserSongCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      final response = await _supabase
          .from('songs')
          .select('id') // Only select ID to minimize data transfer
          .eq('user_id', user.id)
          .count(CountOption.exact); // Use count option
      
      return response.count;
    } catch (e) {
      debugPrint('Error fetching song count: $e');
      return 0;
    }
  }
}
