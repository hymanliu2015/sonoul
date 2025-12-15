import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sonoul/features/auth/auth_controller.dart';
import 'package:sonoul/features/singer/singer_model.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/supabase_song_service.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  String get userEmail => _authController.currentUser?.email ?? 'Guest';
  bool get isLoggedIn => _authController.currentUser != null;
  
  final RxList<Singer> singers = <Singer>[].obs;
  final RxInt currentSingerIndex = 0.obs;
  final RxBool isLoading = false.obs;

  final RxBool isPremium = false.obs;
  final SupabaseSongService _songService = Get.put(SupabaseSongService());

  // Helper to get current singer safely
  Singer? get currentSinger => singers.isNotEmpty ? singers[currentSingerIndex.value] : null;

  @override
  void onInit() {
    super.onInit();
    fetchSingers();
    checkSubscription();
  }

  Future<void> checkSubscription() async {
    if (!isLoggedIn) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response != null) {
        final endDate = DateTime.parse(response['end_date']);
        if (endDate.isAfter(DateTime.now())) {
          isPremium.value = true;
        } else {
          isPremium.value = false;
        }
      } else {
        isPremium.value = false;
      }
    } catch (e) {
      debugPrint("Error checking subscription: $e");
      isPremium.value = false;
    }
  }

  Future<void> fetchSingers() async {
    if (!isLoggedIn) return;

    try {
      isLoading.value = true;
      
      final res = await _supabase.functions.invoke(
        'api_singers',
        method: HttpMethod.get,
      );

      final data = res.data;
      if (data != null && data['data'] != null) {
        final List<dynamic> list = data['data'];
        singers.value = list.map((e) => Singer.fromJson(e)).toList();
      }
      
    } catch (e) {
      debugPrint("Error fetching singers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addMockSinger(String name, String avatar) {
    fetchSingers();
  }

  bool requireAuth() {
    if (!isLoggedIn) {
      ToastUtils.shotToast('Please login first');
      Get.toNamed(AppRoutes.login);
      return false;
    }
    return true;
  }

  void goToCreateSinger() {
    if (requireAuth()) {
      if (!isPremium.value && singers.length >= 2) {
        ToastUtils.shotToast('Free limit reached (Max 2 singers). Upgrade to create more!');
        Get.toNamed(AppRoutes.member);
        return;
      }
      Get.toNamed(AppRoutes.singer);
    }
  }

  Future<void> goToCreateSingle() async {
    if (requireAuth()) {
      if (singers.isEmpty) {
         ToastUtils.shotToast('Please create a singer first');
         Get.toNamed(AppRoutes.singer);
         return;
      }
      
      if (!isPremium.value) {
        final songCount = await _songService.getUserSongCount();
        if (songCount >= 2) {
          ToastUtils.shotToast('Free limit reached (Max 2 songs). Upgrade to create more!');
          Get.toNamed(AppRoutes.member);
          return;
        }
      }
      
      Get.toNamed(AppRoutes.createSingle);
    }
  }

  void goToAlbum() {
    if (requireAuth()) {
      Get.toNamed(AppRoutes.album);
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
    _authController.logout();
  }
  
  void onPageChanged(int index) {
    currentSingerIndex.value = index;
  }

  // Share Feature
  final RxBool isGeneratingShare = false.obs;

  /// Share singer info (avatar image + name) with a random song file
  Future<void> shareSingerWithSong() async {
    if (currentSinger == null) return;
    
    isGeneratingShare.value = true;
    ToastUtils.shotToast('Preparing to share...');
    
    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> filesToShare = [];
      
      // 1. Download singer avatar image
      if (currentSinger!.avatarUrl.isNotEmpty) {
        try {
          final avatarResponse = await http.get(Uri.parse(currentSinger!.avatarUrl));
          if (avatarResponse.statusCode == 200) {
            final avatarFile = File('${tempDir.path}/singer_${currentSinger!.name}.png');
            await avatarFile.writeAsBytes(avatarResponse.bodyBytes);
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
            final songResponse = await http.get(Uri.parse(audioUrl));
            if (songResponse.statusCode == 200) {
              final extension = audioUrl.toString().split('.').last.split('?').first;
              final songFile = File('${tempDir.path}/song_$songTitle.$extension');
              await songFile.writeAsBytes(songResponse.bodyBytes);
              filesToShare.add(XFile(songFile.path));
            }
          } catch (e) {
            debugPrint('Error downloading song: $e');
          }
        }
      }
      
      // 3. Prepare share text
      String shareText = '🎤 Check out my virtual singer "${currentSinger!.name}" on Sonoul!';
      if (songTitle != null) {
        shareText += '\n🎵 Featured song: "$songTitle"';
      }
      shareText += '\n\n#Sonoul #VirtualSinger #AIMusic';
      
      // 4. Share with files
      if (filesToShare.isNotEmpty) {
        final params = ShareParams(
          files: filesToShare,
          text: shareText,
          subject: 'Check out ${currentSinger!.name} on Sonoul!',
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
      ToastUtils.shotToast('Failed to share. Please try again.');
    } finally {
      isGeneratingShare.value = false;
    }
  }
}