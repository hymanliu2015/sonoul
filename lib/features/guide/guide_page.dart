import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/guide/guide_controller.dart';

class GuidePage extends StatelessWidget {
  final GuideController controller = Get.put(GuideController());

  GuidePage({super.key});

  final List<Map<String, dynamic>> _guideItems = [
    {
      'icon': Icons.person_pin,
      'title': 'Virtual Singer',
      'description': 'Create your virtual singer avatar',
    },
    {
      'icon': Icons.mic_external_on,
      'title': 'Own Songs',
      'description': 'Generate your personalized songs',
    },
    {
      'icon': Icons.share,
      'title': 'Share Music',
      'description': 'Share with friends and family or social media',
    },
  ];

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
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: _guideItems.length,
                  itemBuilder: (context, index) {
                    final item = _guideItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 60),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item['description'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Indicators
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _guideItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: controller.currentPage.value == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 40),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final isLastPage = controller.currentPage.value == _guideItems.length - 1;
                        return ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              controller.finishGuide();
                            } else {
                              controller.nextPage();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
