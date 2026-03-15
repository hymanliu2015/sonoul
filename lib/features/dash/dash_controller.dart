import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonoul/utils/dio_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/features/singer/singer_model.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'dart:async';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  String get userEmail => _authController.currentUser?.email ?? 'dash_guest'.tr;
  bool get isLoggedIn => _authController.currentUser != null;
  
  final RxList<Singer> singers = <Singer>[].obs;
  final RxInt currentSingerIndex = 0.obs;
  final RxBool isLoading = false.obs;

  // Tabs state
  final RxInt currentTab = 0.obs;

  // Songs/Album state
  final RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[].obs;
  final RxBool isSongsLoading = true.obs;
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 10);

  final int maxCreateSinger = 2;

  final int maxCreateSongs = 2;

  final RxBool isPremium = false.obs;
  final SupabaseSongService _songService = Get.put(SupabaseSongService());
  RealtimeChannel? _subsRealtime;

  // Helper to get current singer safely
  Singer? get currentSinger => singers.isNotEmpty ? singers[currentSingerIndex.value] : null;

  static const String _singersCacheKey = 'cached_singers';

  @override
  void onInit() {
    super.onInit();
    _loadCachedSingers(); // 先加载缓存
    fetchSingers(); // 后台更新最新数据
    checkSubscription();
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _initializeSubscriptionsRealtime();
      } else if (event == AuthChangeEvent.signedOut) {
        _subsRealtime?.unsubscribe();
        _subsRealtime = null;
      }
    });
    if (_supabase.auth.currentUser != null) {
      _initializeSubscriptionsRealtime();
    }
    
    // Listen for real-time song updates
    _songService.onSongGenerated.listen((updatedSong) {
      if (updatedSong != null) {
        debugPrint('DashController: Received song update: ${updatedSong['title']} - ${updatedSong['status']}');
        
        // Optimistic update
        final index = songs.indexWhere((s) => s['id'] == updatedSong['id']);
        if (index != -1) {
          songs[index] = updatedSong;
          songs.refresh();
        } else {
          // Only insert if it belongs to the currently selected singer in the tab
          if (currentSinger != null && updatedSong['singer_id'] == currentSinger!.id) {
            songs.insert(0, updatedSong);
          }
        }
        
        _updatePollingState();
      }
    });

    ever(songs, (_) => _updatePollingState());
    
    // Automatically fetch songs when the selected singer changes
    ever(currentSingerIndex, (_) {
      fetchSongsForCurrentSinger();
    });
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
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      fetchSongsForCurrentSinger(showLoading: false);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void changeTab(int index) {
    currentTab.value = index;
  }

  /// 从 SP 本地缓存加载用户的 VIP 过期时间
  void _loadPremiumFromSP() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    final spKey = 'vip_end_date_${user.id}';
    final endDateStr = SpUtil.getString(spKey);
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        final endDate = DateTime.parse(endDateStr);
        isPremium.value = endDate.isAfter(DateTime.now());
        debugPrint('Loaded Premium status from SP: ${isPremium.value}');
      } catch (e) {
        debugPrint('Error parsing cached premium date: $e');
      }
    }
  }

  /// 将 VIP 过期时间保存到 SP 本地缓存
  void _savePremiumToSP(String userId, String endDateStr) {
    final spKey = 'vip_end_date_$userId';
    SpUtil.putString(spKey, endDateStr);
  }

  /// 清除用户的 VIP 缓存
  void _clearPremiumSP(String userId) {
    final spKey = 'vip_end_date_$userId';
    SpUtil.remove(spKey);
  }

  Future<void> checkSubscription() async {
    if (!isLoggedIn) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      // 先从本地加载缓存的状态，防止网络离线时直接变成非VIP
      _loadPremiumFromSP();

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .order('end_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final endDateStr = response['end_date'];
        final endDate = DateTime.parse(endDateStr);
        if (endDate.isAfter(DateTime.now())) {
          isPremium.value = true;
          _savePremiumToSP(user.id, endDateStr);
        } else {
          isPremium.value = false;
          _clearPremiumSP(user.id);
        }
      } else {
        isPremium.value = false;
        _clearPremiumSP(user.id);
      }
    } catch (e) {
      debugPrint("Error checking subscription: $e");
      // 注意：这里不再将 isPremium 强制设为 false，保留从缓存加载的状态
    }
  }

  /// 从本地缓存加载歌手列表
  Future<void> _loadCachedSingers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_singersCacheKey);
      if (cachedJson != null) {
        final List<dynamic> list = jsonDecode(cachedJson);
        singers.value = list.map((e) => Singer.fromJson(e)).toList();
        debugPrint('Loaded ${singers.length} singers from cache');
      }
    } catch (e) {
      debugPrint('Error loading cached singers: $e');
    }
  }

  /// 保存歌手列表到本地缓存
  Future<void> _cacheSingers(List<dynamic> singersList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_singersCacheKey, jsonEncode(singersList));
      debugPrint('Cached ${singersList.length} singers');
    } catch (e) {
      debugPrint('Error caching singers: $e');
    }
  }

  Future<void> fetchSingers({bool showLoading = true}) async {
    if (!isLoggedIn) {
      isSongsLoading.value = false;
      return;
    }

    try {
      // 只有当没有缓存数据时才显示 loading
      if (showLoading && singers.isEmpty) {
        isLoading.value = true;
      }
      
      final res = await _supabase.functions.invoke(
        'api_singers',
        method: HttpMethod.get,
      );

      final data = res.data;
      if (data != null && data['data'] != null) {
        final List<dynamic> list = data['data'];
        singers.value = list.map((e) => Singer.fromJson(e)).toList();
        // 缓存到本地
        _cacheSingers(list);
        
        // Fetch songs for the initial active singer
        if (singers.isNotEmpty) {
          fetchSongsForCurrentSinger();
        } else {
          isSongsLoading.value = false;
        }
      } else {
        isSongsLoading.value = false;
      }
      
    } catch (e) {
      debugPrint("Error fetching singers: $e");
      isSongsLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSongsForCurrentSinger({bool showLoading = true}) async {
    if (!isLoggedIn) return;
    
    try {
      if (showLoading) {
        isSongsLoading.value = true;
      }
      
      final singerId = currentSinger?.id;
      final userSongs = await _songService.getUserSongs(singerId: singerId);
      songs.assignAll(userSongs);
      
    } catch (e) {
      debugPrint('DashController: Error fetching songs: $e');
      ToastUtils.shotToast('album_load_failed'.trParams({'error': e.toString()}));
    } finally {
      if (showLoading) {
        isSongsLoading.value = false;
      }
    }
  }

  void openSongDetail(Map<String, dynamic> song) {
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
                isSongsLoading.value = true;
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
                isSongsLoading.value = false;
              }
            },
            child: Text('album_delete_confirm'.tr, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void addMockSinger(String name, String avatar) {
    fetchSingers();
  }

  bool requireAuth() {
    if (!isLoggedIn) {
      ToastUtils.shotToast('dash_please_login'.tr);
      Get.toNamed(AppRoutes.login);
      return false;
    }
    return true;
  }

  void goToCreateSinger() {
    if (requireAuth()) {
      if (!isPremium.value && singers.length >= maxCreateSinger) {
        Get.toNamed(AppRoutes.member);
        return;
      }
      Get.toNamed(AppRoutes.singer);
    }
  }

  Future<void> goToCreateSingle() async {
    if (requireAuth()) {
      if (singers.isEmpty) {
        ToastUtils.shotToast('dash_create_singer_first'.tr);
        Get.toNamed(AppRoutes.singer);
        return;
      }
      
      if (!isPremium.value) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        try {
          final songCount = await _songService.getUserSongCount();
          Get.back(); // dismiss dialog
          if (songCount >= maxCreateSongs) {
            Get.toNamed(AppRoutes.member);
            return;
          }
        } catch (e) {
          Get.back();
          debugPrint('Error getting song count: $e');
          return;
        }
      }
      
      // 进入单曲创作页时，携带当前虚拟歌手信息，后续生成的歌曲会绑定该 singer
      Get.toNamed(AppRoutes.createSingle, arguments: {
        'singerId': currentSinger?.id,
        'singerName': currentSinger?.name,
      });
    }
  }

  void goToAlbum() {
    if (requireAuth()) {
      // 进入专辑页时，按当前虚拟歌手过滤，只展示该歌手的歌曲
      if (currentSinger == null) {
        ToastUtils.shotToast('dash_create_singer_first'.tr);
        Get.toNamed(AppRoutes.singer);
        return;
      }
      Get.toNamed(AppRoutes.album, arguments: {
        'singerId': currentSinger!.id,
        'singerName': currentSinger!.name,
      });
    }
  }
  
  void goToMember() {
    Get.toNamed(AppRoutes.member);
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  void logout() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _clearPremiumSP(user.id);
    }
    _authController.logout();
  }
  
  void changeActiveSinger(int index) {
    if (index >= 0 && index < singers.length) {
      currentSingerIndex.value = index;
    }
  }

  void _initializeSubscriptionsRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    if (_subsRealtime != null) return;
    _subsRealtime = _supabase.channel('public:subscriptions');
    _subsRealtime!
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'subscriptions',
        callback: (payload) {
          final record = payload.newRecord;
          if (record['user_id'] == user.id) {
            final status = record['status'];
            final endDateStr = record['end_date'];
            if (status == 'active' && endDateStr != null) {
              final endDate = DateTime.parse(endDateStr);
              final premiumStatus = endDate.isAfter(DateTime.now());
              isPremium.value = premiumStatus;
              if (premiumStatus) {
                _savePremiumToSP(user.id, endDateStr);
              }
            }
          }
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'subscriptions',
        callback: (payload) {
          final record = payload.newRecord;
          if (record['user_id'] == user.id) {
            final status = record['status'];
            final endDateStr = record['end_date'];
            if (status == 'active' && endDateStr != null) {
              final endDate = DateTime.parse(endDateStr);
              final premiumStatus = endDate.isAfter(DateTime.now());
              isPremium.value = premiumStatus;
              if (premiumStatus) {
                _savePremiumToSP(user.id, endDateStr);
              } else {
                _clearPremiumSP(user.id);
              }
            } else {
              isPremium.value = false;
              _clearPremiumSP(user.id);
            }
          }
        },
      )
      .subscribe();
  }

  // Share Feature
  final RxBool isGeneratingShare = false.obs;

  /// Share singer info (avatar image + name) with a random song file
  Future<void> shareSingerWithSong() async {
    if (currentSinger == null) return;
    
    isGeneratingShare.value = true;
    ToastUtils.shotToast('dash_preparing_share'.tr);
    
    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> filesToShare = [];
      
      // 1. Download singer avatar image
      if (currentSinger!.avatarUrl.isNotEmpty) {
        try {
          final avatarResponse = await DioUtils().get(
            currentSinger!.avatarUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          if (avatarResponse.statusCode == 200) {
            final avatarFile = File('${tempDir.path}/singer_${currentSinger!.name}.png');
            await avatarFile.writeAsBytes(avatarResponse.data);
            filesToShare.add(XFile(avatarFile.path));
          }
        } catch (e) {
          debugPrint('Error downloading avatar: $e');
        }
      }
      
      // 2. Get random song from user's songs
      final songs = await _songService.getUserSongs(singerId: currentSinger!.id);
      String? songTitle;
      
      if (songs.isNotEmpty) {
        // Pick a random song
        final randomIndex = DateTime.now().millisecondsSinceEpoch % songs.length;
        final randomSong = songs[randomIndex];
        songTitle = randomSong['title'] ?? 'My Song';
        final audioUrl = randomSong['audio_url'];
        
        // Download the song file if available
        if (audioUrl != null && audioUrl.toString().isNotEmpty) {
          try {
            final songResponse = await DioUtils().get(
              audioUrl,
              options: Options(responseType: ResponseType.bytes),
            );
            if (songResponse.statusCode == 200) {
              final extension = audioUrl.toString().split('.').last.split('?').first;
              final songFile = File('${tempDir.path}/song_$songTitle.$extension');
              await songFile.writeAsBytes(songResponse.data);
              filesToShare.add(XFile(songFile.path));
            }
          } catch (e) {
            debugPrint('Error downloading song: $e');
          }
        }
      }
      
      // 3. Prepare share text
      String shareText = 'dash_share_text_prefix'.trParams({'name': currentSinger!.name});
      if (songTitle != null) {
        shareText += 'dash_share_song_prefix'.trParams({'title': songTitle});
      }
      shareText += '\n\n#Sonoul #VirtualSinger #AIMusic';
      
      // 4. Share with files
      if (filesToShare.isNotEmpty) {
        final params = ShareParams(
          files: filesToShare,
          text: shareText,
          subject: 'dash_share_subject'.trParams({'name': currentSinger!.name}),
        );
        
        await SharePlus.instance.share(params);
      } else {
        // Fallback to text-only share
        await SharePlus.instance.share(
          ShareParams(
            text: shareText,
            subject: 'Check out ${currentSinger!.name} on Sonoul!',
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Error sharing: $e');
      ToastUtils.shotToast('dash_share_failed'.tr);
    } finally {
      isGeneratingShare.value = false;
    }
  }
}
