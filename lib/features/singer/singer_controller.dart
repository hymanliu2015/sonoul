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
  RxString avatarPrompt = ''.obs;

  void onNameChanged(String value) {
    name.value = value;
  }

  void onPromptChanged(String value) {
    avatarPrompt.value = value;
  }

  Future<void> generateAvatar() async {
    final prompt = avatarPrompt.value.trim();
    if (prompt.isEmpty) {
      ToastUtils.shotToast('Please enter an avatar prompt');
      return;
    }

    try {
      isLoading.value = true;
      // Call the generate-image Edge Function
      final res = await _supabase.functions.invoke(
        'generate-image',
        method: HttpMethod.post,
        body: {'prompt': prompt},
      );

      final data = res.data;
      if (data == null || data['data'] == null || data['data'].isEmpty) {
        throw "Failed to generate image";
      }

      // Assuming standard OpenAI response format: { data: [{ url: "..." }] }
      final imageUrl = data['data'][0]['url'];
      avatarPath.value = imageUrl;
      ToastUtils.shotToast('Avatar generated successfully!');

    } catch (e) {
      debugPrint("Error generating avatar: $e");
      ToastUtils.shotToast('Error generating avatar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSinger() async {
    final singerName = name.value.trim();
    final prompt = avatarPrompt.value.trim();

    if (singerName.isEmpty) {
      ToastUtils.shotToast('Please enter a name');
      return;
    }
    if (prompt.isEmpty) {
      ToastUtils.shotToast('Please enter an avatar prompt');
      return;
    }
    if (avatarPath.value.isEmpty) {
      ToastUtils.shotToast('Please generate an avatar first');
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
          'prompt': prompt, // Optional: save the prompt if the backend supports it
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
        Get.find<DashController>().addMockSinger(singerName, avatarPath.value);
      }

      ToastUtils.shotToast('Singer created successfully!');
      Get.offAndToNamed(AppRoutes.dash);

    } on PostgrestException catch (e) {
      ToastUtils.shotToast(e.message);
    } catch (e) {
      debugPrint("Error creating singer: $e");

      // Mock: Add to DashController directly
      if (Get.isRegistered<DashController>()) {
        Get.find<DashController>().addMockSinger(singerName, avatarPath.value);
      }

      ToastUtils.shotToast('Simulating success');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }
}
