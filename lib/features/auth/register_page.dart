import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/helper/loading_helper.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/auth/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greenLight.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textOnDark, size: 18),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.greenDeep,
              Color(0xFF0A1F1B),
              Color(0xFF051512),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Logo / Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.greenDark, AppColors.greenDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greenPrimary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.greenLight.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 40,
                      color: AppColors.greenLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnDark,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join Sonoul and start creating music',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        Obx(() => _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: controller.isRegisterPasswordVisible.value,
                          onToggleVisibility: controller.toggleRegisterPasswordVisibility,
                        )),
                        const SizedBox(height: 20),
                        Obx(() => _buildTextField(
                          controller: confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: controller.isRegisterConfirmPasswordVisible.value,
                          onToggleVisibility: controller.toggleRegisterConfirmPasswordVisibility,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Obx(() => GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            controller.register(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              confirmPasswordController.text.trim(),
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.greenLight, AppColors.greenPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greenPrimary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: controller.isLoading.value
                          ? const Center(
                              child: LoadingHelper(size: 24, color: Colors.white),
                            )
                          : const Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        children: const [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppColors.greenLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: AppColors.greenLight,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 22),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 22,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            hintText: label == 'Email' ? 'Enter your email' : 'Choose a password',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.greenLight, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
