import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sonoul/common/res/app_colors.dart';

class LoadingHelper extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingHelper({
    super.key,
    this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: color ?? AppColors.primary,
        size: size,
      ),
    );
  }
}
