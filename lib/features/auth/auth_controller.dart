import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;

  // Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (res.user != null) {
        Get.offAllNamed(AppRoutes.dash);
      }
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Register
  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        Get.snackbar('Success', 'Registration successful! Please login.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        // Optionally navigate to login or auto-login
        // For now, let's just stay here or go to login if we were separate
        Get.offNamed(AppRoutes.login); 
      }
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
  
  User? get currentUser => _supabase.auth.currentUser;
}
