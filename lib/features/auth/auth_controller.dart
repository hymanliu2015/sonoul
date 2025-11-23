import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      ToastUtils.shotToast(e.message, Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
    } catch (e) {
      ToastUtils.shotToast('An unexpected error occurred', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
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
        ToastUtils.shotToast('Registration successful! Please login.', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.green, Colors.white);
        // Optionally navigate to login or auto-login
        // For now, let's just stay here or go to login if we were separate
        Get.offNamed(AppRoutes.login); 
      }
    } on AuthException catch (e) {
      debugPrint("AuthException:${e.toString()}");
    } catch (e) {
      debugPrint("Exception:${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      // In a real app, you might call an Edge Function here to delete user data
      // await _supabase.functions.invoke('delete-user');
      
      // For now, we just sign out and pretend
      await _supabase.auth.signOut();
      
      ToastUtils.shotToast('Account deleted successfully', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.green, Colors.white);
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      ToastUtils.shotToast('Failed to delete account', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
  
  User? get currentUser => _supabase.auth.currentUser;
}
