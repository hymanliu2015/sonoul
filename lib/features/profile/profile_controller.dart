import 'package:get/get.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  final userEmail = ''.obs;
  final avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? '';
    }
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }
}
