import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/utils/image_cache_manager.dart';

/// A customizable cached network image widget with built-in loading and error states.
/// Supports placeholder, error widget, and various styling options.
class CustomCachedImage extends StatelessWidget {
  /// The URL of the image to load
  final String? imageUrl;

  /// Fallback URL when imageUrl is null or empty
  final String? fallbackUrl;

  /// Width of the image container
  final double? width;

  /// Height of the image container
  final double? height;

  /// How the image should be inscribed into the container
  final BoxFit fit;

  /// Border radius for the image
  final BorderRadius? borderRadius;

  /// Custom placeholder widget shown while loading
  final Widget? placeholder;

  /// Custom error widget shown when image fails to load
  final Widget? errorWidget;

  /// Background color for placeholder and error states
  final Color? backgroundColor;

  /// Icon to show in placeholder/error states
  final IconData placeholderIcon;

  /// Color of the placeholder icon
  final Color? placeholderIconColor;

  /// Size of the placeholder icon
  final double placeholderIconSize;

  /// Whether to show a loading indicator
  final bool showLoadingIndicator;

  /// BoxDecoration for the container (shadows, borders, etc.)
  final BoxDecoration? decoration;

  const CustomCachedImage({
    super.key,
    this.imageUrl,
    this.fallbackUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.placeholderIcon = Icons.music_note_rounded,
    this.placeholderIconColor,
    this.placeholderIconSize = 40,
    this.showLoadingIndicator = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl != null && imageUrl!.isNotEmpty) 
        ? imageUrl! 
        : fallbackUrl ?? '';

    if (url.isEmpty) {
      return _buildErrorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      cacheManager: ImageCacheManager.instance,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    // Apply decoration if provided
    if (decoration != null) {
      return Container(
        width: width,
        height: height,
        decoration: decoration,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: image,
        ),
      );
    }

    // Apply size constraints
    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.greenDark.withValues(alpha: 0.5),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: showLoadingIndicator
            ? SizedBox(
                width: placeholderIconSize * 0.6,
                height: placeholderIconSize * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    placeholderIconColor ?? AppColors.greenLight.withValues(alpha: 0.6),
                  ),
                ),
              )
            : Icon(
                placeholderIcon,
                size: placeholderIconSize,
                color: placeholderIconColor ?? AppColors.greenLight.withValues(alpha: 0.5),
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? AppColors.greenDark,
            AppColors.greenDeep,
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: placeholderIconColor ?? AppColors.greenLight.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
