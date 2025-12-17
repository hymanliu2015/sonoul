import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Login
  Future<void> login(String email, String password) async {
    // Validate inputs
    if (email.isEmpty) {
      ToastUtils.shotToast('Please enter your email', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      return;
    }
    
    if (password.isEmpty) {
      ToastUtils.shotToast('Please enter your password', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      return;
    }
    
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
  Future<void> register(String email, String password, String confirmPassword) async {
    // Validate inputs
    if (email.isEmpty) {
      ToastUtils.shotToast('Please enter your email', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      return;
    }
    
    if (password.isEmpty) {
      ToastUtils.shotToast('Please enter your password', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      return;
    }
    
    if (confirmPassword.isEmpty) {
      ToastUtils.shotToast('Please confirm your password', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      return;
    }
    
    if (password != confirmPassword) {
      ToastUtils.shotToast('Passwords do not match', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      return;
    }
    
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
    // 1. 确保用户已登录，否则 session.accessToken 会为 null，
    // 并且 functions.invoke 无法自动发送有效的 JWT。
    if (_supabase.auth.currentSession == null) {
      throw Exception('用户未登录，无法执行删除操作。');
    }

    try {
      // 2. 调用 Edge Function，指定函数名称和 DELETE 方法
      final res = await _supabase.functions.invoke(
        'delete-user', // 替换为您部署的函数名称
        // 关键：指定 method 为 DELETE，符合 RESTful 规范
        method: HttpMethod.delete,
        // 不需要 body，因为函数只需要 JWT (supabase.functions.invoke() 会自动添加)
      );

      // Check if response contains an error
      if (res.data != null && res.data['error'] != null) {
        debugPrint('Edge Function 错误: ${res.data}');
        throw Exception(res.data['error']);
      }

      // Success: sign out and navigate to login
      debugPrint('账户删除成功，执行客户端登出...');
      await _supabase.auth.signOut();
      Get.offAllNamed(AppRoutes.login);

    } on FunctionException catch (e) {
      // 处理函数调用返回的特定错误（例如 401 Unauthorized, 500 Internal Error）
      debugPrint('函数调用失败: ${e.details}');
      throw Exception('删除账户失败: ${e.details}');
    } catch (e) {
      // 处理其他网络或通用错误
      debugPrint('发生未知错误: $e');
      throw Exception('发生未知错误，请稍后再试。');
    }
  }
  
  User? get currentUser => _supabase.auth.currentUser;
}
