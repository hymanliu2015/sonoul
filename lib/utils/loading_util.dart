
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sonoul/common/res/app_colors.dart';

class LoadingUtils {
  // 使用单例模式来确保工具类只有一个实例
  static final LoadingUtils _instance = LoadingUtils._internal();

  factory LoadingUtils() => _instance;

  // 私有构造函数
  LoadingUtils._internal();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // 显示 loading
  void showLoading() {
    if (_isLoading) return; // 防止重复显示

    _isLoading = true;

    // 显示 loading 提示框
    Get.dialog(
      Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.primary, // 你可以自定义颜色
          size: 36, // 自定义动画大小
        ),
      ),
    );
  }

  // 隐藏 loading
  void hideLoading() {
    if (!_isLoading) return; // 防止重复隐藏

    _isLoading = false;

    // 关闭 Dialog
    Get.back();
  }
}
