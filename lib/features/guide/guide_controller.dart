import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:sonoul/utils/sp_util.dart';

class GuideController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  RxString avatarPath = ''.obs;
  RxBool isLoading = false.obs;
  RxString name = ''.obs; // Track name input

  // Mock image picker for now
  void pickImage() {
    // In a real app, use image_picker package
    // For now, we'll just set a placeholder URL or simulate a path
    avatarPath.value = "https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}";
  }

  void onNameChanged(String value) {
    name.value = value;
  }

  Future<void> createSinger() async {
    final singerName = name.value.trim();
    if (singerName.isEmpty) {
      Get.rawSnackbar(title: 'Error', message: 'Please enter a name', backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) {
        Get.rawSnackbar(title: 'Error', message: 'User not logged in', backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Save to Supabase 'profiles' or 'singers' table
      await _supabase.from('singers').insert({
        'user_id': user.id,
        'name': singerName,
        'avatar_url': avatarPath.value,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Save local state
      await SpUtil.putBool('has_created_singer', true);
      await SpUtil.putString('singer_name', singerName);
      await SpUtil.putString('singer_avatar', avatarPath.value);

      Get.rawSnackbar(title: 'Success', message: 'Singer created successfully!', backgroundColor: Colors.green, snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(AppRoutes.dash); // Go to dashboard
      
    } on PostgrestException catch (e) {
      Get.rawSnackbar(title: 'Error', message: e.message, backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint("Error creating singer: $e");
      // Simulate success for demo/dev if DB fails
      await SpUtil.putBool('has_created_singer', true);
      await SpUtil.putString('singer_name', singerName);
      await SpUtil.putString('singer_avatar', avatarPath.value);

      Get.rawSnackbar(title: 'Dev Note', message: 'Simulating success (DB might be missing)', backgroundColor: Colors.orange, snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(AppRoutes.dash);
    } finally {
      isLoading.value = false;
    }
  }
}
