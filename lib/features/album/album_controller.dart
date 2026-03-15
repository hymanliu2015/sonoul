import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';
import 'package:sonoul/features/dash/dash_controller.dart';

class AlbumController extends GetxController {
  final SupabaseSongService _songService = Get.put(SupabaseSongService());
  
  final RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  bool _isFetching = false;
  int _offset = 0;
  static const int _limit = 20;

  // 当前专辑对应的虚拟歌手（可为空，表示所有歌手）
  late final String? singerId;
  late final String? singerName;

  // 轮询定时器
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 10);

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    singerId = args != null ? args['singerId'] as String? : null;
    singerName = args != null ? args['singerName'] as String? : null;

    // 检查是否需要立即刷新（从 CreateSongPage 跳转过来）
    final shouldRefresh = args != null ? args['refresh'] as bool? : false;
    if (shouldRefresh == true) {
      debugPrint('AlbumController: Refresh requested from CreateSongPage');
    }

    fetchSongs();
    
    // Listen for real-time song updates
    _songService.onSongGenerated.listen((updatedSong) {
      if (updatedSong != null) {
        debugPrint('AlbumController: Received song update: ${updatedSong['title']} - ${updatedSong['status']}');
        
        // Optimistic update: Find and update the song locally
        final index = songs.indexWhere((s) => s['id'] == updatedSong['id']);
        if (index != -1) {
          songs[index] = updatedSong;
          songs.refresh(); // Notify listeners of update
        } else {
          // If song not found (e.g. new song), add to top or refresh
          // For now, simple insert at top as list is ordered by created_at desc
          songs.insert(0, updatedSong);
          _offset += 1; // Increase offset so loadMore doesn't fetch duplicates
        }
        
        // 检查是否还有 pending 的歌曲，决定是否继续轮询
        _updatePollingState();
      }
    });

    // 启动轮询，监听 songs 变化来决定是否继续
    ever(songs, (_) => _updatePollingState());
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  /// 检查是否有 pending 状态的歌曲，决定是否开启/关闭轮询
  void _updatePollingState() {
    final hasPending = songs.any((s) => 
      s['status'] == 'pending' || s['status'] == 'processing'
    );
    
    if (hasPending && _pollingTimer == null) {
      _startPolling();
    } else if (!hasPending && _pollingTimer != null) {
      _stopPolling();
    }
  }

  void _startPolling() {
    debugPrint('AlbumController: Starting polling for pending songs');
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      fetchSongs(showLoading: false);
    });
  }

  void _stopPolling() {
    debugPrint('AlbumController: Stopping polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchSongs({bool showLoading = true}) async {
    if (_isFetching) return;
    try {
      _isFetching = true;
      if (showLoading) {
        isLoading.value = true;
      }
      debugPrint(
        'AlbumController: Fetching songs for current user, singerId=$singerId (loading: $showLoading)',
      );
      
      _offset = 0;
      hasMore.value = true;
      
      // 按当前虚拟歌手过滤歌曲；如果 singerId 为空，则为用户全部歌曲
      final userSongs = await _songService.getUserSongs(singerId: singerId, limit: _limit, offset: _offset);
      debugPrint('AlbumController: Fetched ${userSongs.length} songs');
      songs.assignAll(userSongs);
      
      if (userSongs.length < _limit) {
        hasMore.value = false;
      }
      _offset = userSongs.length;
    } catch (e) {
      debugPrint('AlbumController: Error fetching songs: $e');
      Get.snackbar('Error', 'album_load_failed'.trParams({'error': e.toString()}));
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || _isFetching) return;
    
    try {
      isLoadingMore.value = true;
      _isFetching = true;
      final newSongs = await _songService.getUserSongs(singerId: singerId, limit: _limit, offset: _offset);
      
      if (newSongs.isEmpty) {
        hasMore.value = false;
      } else {
        // Prevent duplicates caused by offset shifts during database inserts
        final existingIds = songs.map((s) => s['id']).toSet();
        final filteredSongs = newSongs.where((s) => !existingIds.contains(s['id'])).toList();
        
        songs.addAll(filteredSongs);
        _offset += newSongs.length;
        if (newSongs.length < _limit) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      debugPrint('AlbumController: Error loading more: $e');
    } finally {
      isLoadingMore.value = false;
      _isFetching = false;
    }
  }

  void openSongDetail(Map<String, dynamic> song) {
    // Pass the current song AND the full playlist to allow navigation
    // Filter out pending/processing songs that aren't playable if desired, 
    // or just pass all and let the detail controller handle skippable ones.
    // For now, let's pass all songs so the index makes sense.
    Get.toNamed(AppRoutes.songDetail, arguments: {
      'song': song,
      'playlist': songs,
    });
  }

  Future<void> deleteSong(String songId) async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('album_delete_dialog_title'.tr, style: const TextStyle(color: Colors.white)),
        content: Text(
          'album_delete_dialog_content'.tr,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('album_delete_cancel'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                isLoading.value = true;
                await _songService.deleteSong(songId);
                songs.removeWhere((s) => s['id'] == songId);
                Get.snackbar(
                  'Success',
                  'album_delete_success'.tr,
                  colorText: Colors.white, 
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                );
              } catch (e) {
                Get.snackbar('Error', 'album_delete_failed'.tr);
              } finally {
                isLoading.value = false;
              }
            },
            child: Text('album_delete_confirm'.tr, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void goToCreateSong() {
    // Use DashController's method which already has member check logic
    if (Get.isRegistered<DashController>()) {
      Get.find<DashController>().goToCreateSingle();
    } else {
      // Fallback: just navigate if DashController is not available
      Get.toNamed(AppRoutes.createSingle);
    }
  }
}
