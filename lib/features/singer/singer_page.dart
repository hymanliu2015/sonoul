import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_cached_image.dart';
import 'package:sonoul/features/singer/singer_controller.dart';

class SingerPage extends StatelessWidget {
  final SingerController controller = Get.put(SingerController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController promptController = TextEditingController();

  SingerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
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
        title: const Text(
          'Create Singer',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar Preview
                _buildAvatarPreview(),
                const SizedBox(height: 32),
                // Singer Name Input
                _buildGlassCard(
                  child: _buildNameInput(),
                ),
                const SizedBox(height: 20),
                // Avatar Prompt Input
                _buildGlassCard(
                  child: _buildPromptInput(),
                ),
                const SizedBox(height: 24),
                // Generate Avatar Button
                _buildGenerateButton(),
                const SizedBox(height: 20),
                // Create Singer Button
                _buildCreateButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAvatarPreview() {
    return Obx(() {
      final hasAvatar = controller.avatarPath.value.isNotEmpty;
      
      return Column(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenPrimary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: hasAvatar
                  ? CustomCachedImage(
                      imageUrl: controller.avatarPath.value,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.person_outline,
                      placeholderIconSize: 80,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.greenDark,
                            AppColors.greenDeep,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.greenLight.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 80,
                        color: AppColors.greenLight.withValues(alpha: 0.5),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              hasAvatar ? '✨ Avatar Generated!' : 'Avatar will appear here',
              key: ValueKey(hasAvatar),
              style: TextStyle(
                fontSize: 14,
                color: hasAvatar 
                    ? AppColors.greenLight 
                    : Colors.white.withValues(alpha: 0.5),
                fontWeight: hasAvatar ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greenPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline, color: AppColors.greenLight, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Singer Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnDark,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          onChanged: controller.onNameChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Enter a unique name for your singer...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.greenPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.happy.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.happy, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Avatar Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnDark,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: promptController,
          onChanged: controller.onPromptChanged,
          minLines: 2,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Describe the singer\'s appearance...e.g., "A young female singer with blue hair and cyberpunk style"',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.greenPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Obx(() {
      final isEnabled = controller.avatarPrompt.value.isNotEmpty && !controller.isLoading.value;
      
      return GestureDetector(
        onTap: isEnabled ? controller.generateAvatar : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isEnabled ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled 
                  ? AppColors.greenLight.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: isEnabled 
                    ? AppColors.greenLight 
                    : Colors.white.withValues(alpha: 0.3),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Generate Avatar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEnabled 
                      ? AppColors.greenLight 
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCreateButton() {
    return Obx(() {
      final isEnabled = controller.name.value.isNotEmpty &&
          controller.avatarPrompt.value.isNotEmpty &&
          controller.avatarPath.value.isNotEmpty &&
          !controller.isLoading.value;

      return GestureDetector(
        onTap: isEnabled ? controller.createSinger : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.greenLight, AppColors.greenPrimary, AppColors.greenDark],
                  )
                : null,
            color: isEnabled ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.greenPrimary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: controller.isLoading.value
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Create Singer',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
