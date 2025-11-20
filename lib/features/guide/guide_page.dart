import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/guide/guide_controller.dart';

class GuidePage extends StatelessWidget {
  final GuideController controller = Get.put(GuideController());

  GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.music_note,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome to Sonoul',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your AI Virtual Singer App',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                _buildFeatureItem(
                  icon: Icons.mic,
                  title: 'Create AI Songs',
                  description: 'Generate unique songs with AI-powered voice',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  icon: Icons.album,
                  title: 'Build Your Album',
                  description: 'Organize and share your music collection',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  icon: Icons.person,
                  title: 'Virtual Singer',
                  description: 'Create your own AI virtual singer identity',
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.finishGuide,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
