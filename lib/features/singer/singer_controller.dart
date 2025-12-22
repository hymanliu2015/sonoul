import 'package:get/get.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:sonoul/utils/toast_util.dart';

class SingerController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  RxString avatarPath = ''.obs;
  RxBool isLoading = false.obs;
  RxString name = ''.obs;
  RxString prompt = ''.obs;
  RxBool isGenerating = false.obs;

  void pickImage() {
    avatarPath.value = "https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}";
  }

  void onNameChanged(String value) {
    name.value = value;
  }

  void onPromptChanged(String value) {
    prompt.value = value;
  }

  Future<void> generateAvatar() async {
    final promptText = prompt.value.trim();
    if (promptText.isEmpty) {
      ToastUtils.shotToast('Please enter a prompt');
      return;
    }

    try {
      isGenerating.value = true;
      // Close keyboard
      FocusManager.instance.primaryFocus?.unfocus();
      
      final res = await _supabase.functions.invoke(
        'generate-image',
        method: HttpMethod.post,
        body: {
          'prompt': promptText,
        },
      );

      final data = res.data;
      if (data == null || data['data'] == null || (data['data'] as List).isEmpty) {
        throw "No image data returned";
      }
      
      final imageUrl = data['data'][0]['url'];
      avatarPath.value = imageUrl;
      ToastUtils.shotToast('Avatar generated successfully!');
      
    } catch (e) {
      debugPrint("Error generating avatar: $e");
      ToastUtils.shotToast('Failed to generate avatar');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> createSinger() async {
    final singerName = name.value.trim();
    if (singerName.isEmpty) {
      ToastUtils.shotToast('Please enter a name');
      return;
    }

    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) {
        ToastUtils.shotToast('Please login first');
        Get.toNamed(AppRoutes.login);
        return;
      }

      final res = await _supabase.functions.invoke(
        'api_singers',
        method: HttpMethod.post,
        body: {
          'name': singerName,
          'avatar_url': avatarPath.value,
        },
      );

      // 后端返回：{ "data": [...] }
      final data = res.data;
      if (data == null) {
        ToastUtils.shotToast('Server error');
        return;
      }

      await SpUtil.putString('singer_name', singerName);
      await SpUtil.putString('singer_avatar', avatarPath.value);

      // Mock: Add to DashController directly
      if (Get.isRegistered<DashController>()) {
        final avatar = avatarPath.value.isNotEmpty
            ? avatarPath.value
            : "https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}";
        Get.find<DashController>().addMockSinger(singerName, avatar);
      }

      ToastUtils.shotToast('Singer created successfully!');
      Get.offAndToNamed(AppRoutes.dash);

    } on PostgrestException catch (e) {
      ToastUtils.shotToast(e.message);
    } catch (e) {
      debugPrint("Error creating singer: $e");

      // Mock: Add to DashController directly
      if (Get.isRegistered<DashController>()) {
        final avatar = avatarPath.value.isNotEmpty
            ? avatarPath.value
            : "https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}";
        Get.find<DashController>().addMockSinger(singerName, avatar);
      }

      ToastUtils.shotToast('Simulating success');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }
}
