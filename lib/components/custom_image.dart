import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final VoidCallback? onTap;
  final double? borderRadius;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.color,
    this.fit,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius ?? 0),
        ),
        child: Image.asset(
          imageUrl,
          width: width,
          height: height,
          color: color,
          fit: fit,
        ),
      ),
    );
  }
}
