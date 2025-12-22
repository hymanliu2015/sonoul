import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_appbar.dart';
import 'package:sonoul/components/custom_box.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/member/member_controller.dart';
import 'package:sonoul/common/helper/loading_helper.dart';

class MemberPage extends GetView<MemberController> {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbar(
        text: 'Premium Member',
      ),
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, size: 80, color: Colors.orange),
                        const SizedBox(height: 20),
                        const CustomText(
                          text: 'Unlock Full Potential',
                          textFontSize: 28,
                          fontWeight: FontWeight.bold,
                          textColor: AppColors.textPrimary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const CustomText(
                          text: 'Get unlimited AI songs, high quality downloads, and more.',
                          textFontSize: 16,
                          textColor: AppColors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        if (controller.products.isEmpty)
                          const CustomText(
                            text: 'Loading products...',
                            textFontSize: 14,
                            textColor: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          )
                        else
                          ...controller.products.map((product) => _buildProductCard(product)),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Area
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Continue Button with proper styling
                      GestureDetector(
                        onTap: controller.isPurchasing.value ? null : controller.buySelectedProduct,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: controller.isPurchasing.value ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: controller.isPurchasing.value
                              ? const LoadingHelper(size: 24, color: Colors.white)
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Restore Purchases Button
                      GestureDetector(
                        onTap: controller.isPurchasing.value ? null : controller.restorePurchases,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Restore Purchases',
                            style: TextStyle(
                              color: controller.isPurchasing.value ? AppColors.textSecondary : AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Terms of Service
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Terms of Service',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Safe area padding
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    return Obx(() {
      final isSelected = controller.selectedProductId.value == product.id;
      return CustomBox(
        onTap: () => controller.selectProduct(product.id),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        borderWidth: 2,
        borderColor: isSelected ? AppColors.primary : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.title,
                    textFontSize: 18,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: product.price,
                    textFontSize: 16,
                    textColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
             // Selection Radio/Check
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      );
    });
  }
}
