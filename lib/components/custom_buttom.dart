// 按钮组件
import 'package:sonoul/common/res/aoo_colors.dart';
import 'package:sonoul/components/custom_box.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color? color;
  final Color? textColor;
  final double? textFontSize;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.color,
    this.textColor,
    this.textFontSize,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBox(
      width: width ?? 300,
      height: height ?? 56,
      color: color ?? AppColors.whiteColor,
      onTap: isEnabled ? onPressed : null,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      margin: EdgeInsets.zero,
      child: CustomText(
        text: text,
        textColor: textColor ?? AppColors.blackColor,
        textFontSize: textFontSize ?? 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
