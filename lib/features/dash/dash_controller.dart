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
      // Limit check: Max 2 singers for free users
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
      
      // Limit check: Max 5 songs for free users
      if (!isPremium.value) {
        final songCount = await _songService.getUserSongCount();
        if (songCount >= 5) {
          ToastUtils.shotToast('Free limit reached (Max 5 songs). Upgrade to create more!');
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

  Future<void> generateShareImage(String type) async {
    if (currentSinger == null) return;
    
    isGeneratingShare.value = true;
    ToastUtils.shotToast('Generating share image...');
    
    try {
      // Prepare data based on share type
      final Map<String, dynamic> shareData = {
        'singer_name': currentSinger!.name,
        'singer_avatar': currentSinger!.avatarUrl,
        'type': type,
      };

      // If sharing song, get latest song info
      if (type == 'song') {
        final songs = await _songService.getUserSongs(singerId: currentSinger!.id);
        if (songs.isNotEmpty) {
          shareData['song_title'] = songs.first['title'] ?? 'My Song';
          shareData['song_cover'] = songs.first['audio_url'] ?? '';
        }
      }

      // Call Supabase Edge Function to generate image
      final res = await _supabase.functions.invoke(
        'generate-share-image',
        body: shareData,
      );

      if (res.status == 200 && res.data != null) {
        final imageUrl = res.data['image_url'];
        if (imageUrl != null) {
          // Share the generated image URL
          await _shareImage(imageUrl, currentSinger!.name, type);
        } else {
          // Fallback: share text with singer info
          await _shareText(currentSinger!.name, type);
        }
      } else {
        // Fallback to text sharing
        await _shareText(currentSinger!.name, type);
      }
      
    } catch (e) {
      debugPrint('Error generating share: $e');
      // Fallback to text sharing
      await _shareText(currentSinger!.name, type);
    } finally {
      isGeneratingShare.value = false;
    }
  }

  Future<void> _shareImage(String imageUrl, String singerName, String type) async {
    try {
      // Download image to temp file
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/share_$singerName.png');
        await file.writeAsBytes(response.bodyBytes);
        
        // Get share text
        final shareText = _getShareText(singerName, type);

        final params = ShareParams(
          files: [XFile(file.path)],
          text: shareText,
          subject: 'Check out $singerName on Sonoul!',
        );

        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.dismissed) {
          debugPrint('Did you not like the pictures?');
        }
      } else {
        // Fallback to text
        await _shareText(singerName, type);
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
      await _shareText(singerName, type);
    }
  }

  Future<void> _shareText(String singerName, String type) async {
    final shareText = _getShareText(singerName, type);
    await SharePlus.instance.share(
      ShareParams(text: shareText,subject:'Check out $singerName on Sonoul!' ),
    );
  }

  String _getShareText(String singerName, String type) {
    switch (type) {
      case 'profile':
        return '🎤 Check out my virtual singer "$singerName" on Sonoul! #Sonoul #VirtualSinger';
      case 'song':
        return '🎵 Listen to my latest AI-generated song by "$singerName" on Sonoul! #Sonoul #AIMusic';
      case 'album':
        return '🎶 Discover my music collection by "$singerName" on Sonoul! #Sonoul #VirtualSinger';
      default:
        return '🎤 Check out "$singerName" on Sonoul!';
    }
  }
}