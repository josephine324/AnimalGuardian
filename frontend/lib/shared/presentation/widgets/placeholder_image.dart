import 'package:flutter/material.dart';

/// A placeholder image widget that supports both assets and network images
/// 
/// Usage:
/// ```dart
/// PlaceholderImage(
///   assetPath: 'assets/images/cow.jpg',
///   networkUrl: 'https://example.com/image.jpg',
///   placeholderIcon: Icons.pets,
///   width: 200,
///   height: 200,
/// )
/// ```
class PlaceholderImage extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final IconData placeholderIcon;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;
  final Color? iconColor;
  final BorderRadius? borderRadius;

  const PlaceholderImage({
    super.key,
    this.assetPath,
    this.networkUrl,
    required this.placeholderIcon,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[200]!;
    final iconClr = iconColor ?? Colors.grey[400]!;
    
    Widget imageWidget;
    
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      // Try to load network image first
      imageWidget = Image.network(
        networkUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(bgColor, iconClr);
        },
        errorBuilder: (context, error, stackTrace) {
          // Fallback to asset if network fails
          if (assetPath != null) {
            return Image.asset(
              assetPath!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(bgColor, iconClr);
              },
            );
          }
          return _buildPlaceholder(bgColor, iconClr);
        },
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      // Try to load the asset, fallback to placeholder if it fails
      imageWidget = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(bgColor, iconClr);
        },
      );
    } else {
      imageWidget = _buildPlaceholder(bgColor, iconClr);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(Color bgColor, Color iconClr) {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      child: Icon(
        placeholderIcon,
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : 60,
        color: iconClr,
      ),
    );
  }
}

