import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_appbar.dart';
import 'package:sonoul/components/custom_box.dart';
import 'package:sonoul/components/custom_buttom.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/member/member_controller.dart';
import 'package:sonoul/common/helper/loading_helper.dart';
import 'package:sonoul/utils/toast_util.dart';

class MemberPage extends GetView<MemberController> {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbar(
        title: Text(
          'Premium Member',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingHelper());
        }
        return Column(
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
                      _buildMockProducts()
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
                  CustomButton(
                    text: 'Continue',
                    onPressed: controller.buySelectedProduct,
                    color: AppColors.primary,
                    textColor: Colors.white,
                    width: double.infinity,
                    height: 56,
                    textFontSize: 18,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => ToastUtils.shotToast('Opening Terms of Service...'),
                        child: const CustomText(
                          text: 'Terms of Service',
                          textColor: AppColors.textSecondary,
                          textFontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: controller.restorePurchases,
                        child: const CustomText(
                          text: 'Restore Purchases',
                          textColor: AppColors.textSecondary,
                          textFontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Safe area padding
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMockProducts() {
    return Column(
      children: [
        _buildMockCard(
          title: 'Weekly Premium',
          price: '\$4.99 / week',
          productId: 'sonoul_week',
        ),
        const SizedBox(height: 16),
        _buildMockCard(
          title: 'Monthly Premium',
          price: '\$9.99 / month',
          productId: 'sonoul_monthly',
        ),
        const SizedBox(height: 16),
        _buildMockCard(
          title: 'Yearly Premium',
          price: '\$69.99 / year',
          productId: 'sonoul_annual',
          isBestValue: true,
        ),
      ],
    );
  }

  Widget _buildMockCard({
    required String title,
    required String price,
    required String productId,
    bool isBestValue = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedProductId.value == productId;
      return CustomBox(
        onTap: () => controller.selectProduct(productId),
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
                  if (isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CustomText(
                        text: 'BEST VALUE',
                        textColor: Colors.white,
                        textFontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  CustomText(
                    text: title,
                    textFontSize: 18,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: price,
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
