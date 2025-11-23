import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.textColor,
    this.textFontSize,
    this.textAlign,
    this.fontWeight,
  });

  final String text;
  final Color? textColor;
  final double? textFontSize;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: textFontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}
