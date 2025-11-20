import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SingerController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  RxString avatarPath = ''.obs;
  RxBool isLoading = false.obs;

  // Mock image picker for now
  void pickImage() {
    // In a real app, use image_picker package
    // For now, we'll just set a placeholder URL or simulate a path
    avatarPath.value = "https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> createSinger(String name) async {
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter a name', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not logged in', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Save to Supabase 'profiles' or 'singers' table
      // Assuming a 'singers' table exists or we use 'profiles'
      // For this demo, we'll assume a 'singers' table
      await _supabase.from('singers').insert({
        'user_id': user.id,
        'name': name,
        'avatar_url': avatarPath.value,
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Success', 'Singer created successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.dash); // Go to dashboard
      
    } on PostgrestException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      // For demo purposes, if table doesn't exist, we might just proceed
      debugPrint("Error creating singer: $e");
      Get.snackbar('Dev Note', 'Simulating success (DB might be missing)', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.dash);
    } finally {
      isLoading.value = false;
    }
  }
}
