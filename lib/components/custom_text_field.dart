import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final bool isObscure;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final InputDecoration? inputDecoration;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.hintText,
    required this.controller,
    this.isObscure = false,
    this.keyboardType,
    this.style,
    this.hintStyle,
    this.inputDecoration,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      style: style,
      focusNode: focusNode,
      validator: validator,
      decoration: inputDecoration ??
          InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            border: InputBorder.none,
          ),
    );
  }
}
