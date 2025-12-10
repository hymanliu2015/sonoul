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

  Future<List<Map<String, dynamic>>> getUserSongs({String? singerId}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      var query = _supabase
          .from('songs')
          .select()
          .eq('user_id', user.id);
          
      if (singerId != null && singerId.isNotEmpty) {
        query = query.eq('singer_id', singerId);
      }
          
      final response = await query.order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user songs: $e');
      return [];
    }
  }
}
