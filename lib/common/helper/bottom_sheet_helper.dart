import 'package:sonoul/common/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetHelper {
  /// 显示一个自定义 BottomSheet
  static void showCustomBottomSheet({
    required Widget content, // 要显示的内容
    double? height, // 高度，可以根据内容自适应
    bool isScrollControlled = true, // 是否允许内容根据高度控制
    Color? backgroundColor, // 背景颜色
    bool isDismissible = false, // 是否点击外部关闭
    bool isEnableDrag = false, // 是否支持拖拽
    double? borderRadius, // 圆角
    Widget? header, // 可选的 header
  }) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius ?? 16.0),
            topRight: Radius.circular(borderRadius ?? 16.0),
          ),
        ),
        width: Get.width ,
        height: height ?? Get.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 如果有 header，显示 header
            if (header != null) header,
            Expanded(child: content),
          ],
        ),
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: isEnableDrag,
    );
  }

  /// 显示带有标题和自定义按钮的 BottomSheet
  static void showSimpleBottomSheet({
    required String title, // 标题
    required Widget content, // 内容
    required String buttonText, // 按钮文本
    required Function() onButtonPressed, // 按钮回调
    Color? backgroundColor, // 背景颜色
    bool isDismissible = true, // 是否点击外部关闭
    double? height, // 高度
  }) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular( 16.0),
            topRight: Radius.circular( 16.0),
          ),
        ),
        height: height ?? Get.height * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: content), // 这里展示传入的内容
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
    );
  }

  /// 显示一个自定义的底部选择器（类似底部弹出框）
  static void showBottomPicker({
    required Widget picker, // Picker 部分
    double? height, // 高度
    bool isDismissible = true, // 是否点击外部关闭
  }) {
    Get.bottomSheet(
      Container(
        height: height ?? Get.height * 0.2,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular( 16.0),
            topRight: Radius.circular( 16.0),
          ),
        ),
        child: picker,
      ),
      isDismissible: isDismissible,
      isScrollControlled: true,
    );
  }
}
