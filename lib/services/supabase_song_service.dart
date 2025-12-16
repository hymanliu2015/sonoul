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

  Future<void> deleteSong(String songId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('songs')
          .delete()
          .eq('id', songId)
          .eq('user_id', user.id); // Security: ensure user owns the song
          
      debugPrint('SupabaseSongService: Deleted song $songId');
    } catch (e) {
      debugPrint('SupabaseSongService: Error deleting song: $e');
      rethrow;
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

  // Broadcast stream for song completion
  final Rx<Map<String, dynamic>?> _songGeneratedController = Rx<Map<String, dynamic>?>(null);
  Stream<Map<String, dynamic>?> get onSongGenerated => _songGeneratedController.stream;

  RealtimeChannel? _subscription;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        initializeRealtimeSubscription();
      } else if (event == AuthChangeEvent.signedOut) {
        _subscription?.unsubscribe();
        _subscription = null;
      }
    });
    
    // Attempt to initialize if already logged in
    if (_supabase.auth.currentUser != null) {
      initializeRealtimeSubscription();
    }
  }

  void initializeRealtimeSubscription() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    // Avoid duplicate subscriptions
    if (_subscription != null) return;

    debugPrint('SupabaseSongService: Initializing Realtime Subscription for user ${user.id}');

    _subscription = _supabase.channel('public:songs');
    _subscription!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'songs',
      // Removed column filter to ensure we get all events, then filter locally
      // This is safer if user_id isn't in the changeset or for other RLS reasons
      callback: (payload) {
        // debugPrint('Supabase Realtime Update Payload: ${payload.toString()}');
        final newRecord = payload.newRecord;
        
        // Check if this update belongs to the current user
        if (newRecord['user_id'] == user.id) {
           debugPrint('Supabase Realtime: Song update for user ${user.id} - Status: ${newRecord['status']}');
           
           if (newRecord['status'] == 'completed') {
             Get.snackbar(
              'Song Ready', 
              'Your song "${newRecord['title'] ?? 'Untitled'}" has been generated!',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: const Color(0xFFFFFFFF),
              duration: const Duration(seconds: 4),
            );
           }
           
           // Trigger global stream update for ANY status change so UI can update
           _songGeneratedController.value = newRecord;
        }
      },
    ).subscribe();
  }
}
