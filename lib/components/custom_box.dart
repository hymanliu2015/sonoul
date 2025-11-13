import 'package:sonoul/common/res/aoo_colors.dart';
import 'package:flutter/material.dart';

class CustomBox extends StatelessWidget {
  const CustomBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.borderWidth,
    this.color,
    this.borderColor,
    this.margin,
    this.padding,
    this.alignment,
    this.child,
    this.onTap,
    this.onLongPress,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final double? borderWidth;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: alignment,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppColors.tranColor,
            width: borderWidth ?? 0,
          ),
        ),
        child: child,
      ),
    );
  }
}
