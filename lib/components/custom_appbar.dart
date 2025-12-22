import 'package:sonoul/common/res/app_assets.dart';
import 'package:sonoul/components/custom_image.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final double contentHeight;
  final Widget? leading;
  final Widget? flex;
  final List<Widget>? actions;
  final Widget? title;
  final String? text;
  final double? leadingWidth;
  final Color? backgroundColor;
  final Color? backColor;

  const CustomAppbar({
    super.key,
    this.leading,
    this.flex,
    this.title,
    this.text,
    this.contentHeight = 48,
    this.actions,
    this.leadingWidth,
    this.backgroundColor,
    this.backColor,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomAppbarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(contentHeight);
}

class _CustomAppbarState extends State<CustomAppbar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: widget.backgroundColor,
      title: widget.title ?? CustomText(text: widget.text ?? ""),
      leading: widget.leading != null
          ? GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Center(child: widget.leading),
            )
          : IconButton(
              onPressed: () {
                Get.back();
              },
              icon: CustomImage(
                imageUrl: AppAssets.iconBack,
                width: 24,
                height: 24,
                color: widget.backColor,
              ),
            ),
      leadingWidth: widget.leadingWidth,
      actions: widget.actions,
      centerTitle: true,
      automaticallyImplyLeading: false,
      flexibleSpace: widget.flex,
    );
  }

  Size get preferredSize => const Size(100, 100);
}
