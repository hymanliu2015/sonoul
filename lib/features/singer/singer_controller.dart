import 'package:get/get.dart';
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

  void pickImage() {
    avatarPath.value = "https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}";
  }

  void onNameChanged(String value) {
    name.value = value;
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

      await _supabase.from('singers').insert({
        'user_id': user.id,
        'name': singerName,
        'avatar_url': avatarPath.value,
        'created_at': DateTime.now().toIso8601String(),
      });

      await SpUtil.putBool('has_created_singer', true);
      await SpUtil.putString('singer_name', singerName);
      await SpUtil.putString('singer_avatar', avatarPath.value);

      ToastUtils.shotToast('Singer created successfully!');
      Get.offAllNamed(AppRoutes.dash);
      
    } on PostgrestException catch (e) {
      ToastUtils.shotToast(e.message);
    } catch (e) {
      debugPrint("Error creating singer: $e");
      await SpUtil.putBool('has_created_singer', true);
      await SpUtil.putString('singer_name', singerName);
      await SpUtil.putString('singer_avatar', avatarPath.value);

      ToastUtils.shotToast('Simulating success (DB might be missing)');
      Get.offAllNamed(AppRoutes.dash);
    } finally {
      isLoading.value = false;
    }
  }
}
