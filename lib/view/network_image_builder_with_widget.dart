import 'package:flutter/material.dart';

class ImageOrFallbackWidget extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackAsset;
  final Widget? fallbackWidget;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(ImageProvider image)? builder;

  const ImageOrFallbackWidget({
    super.key,
    required this.imageUrl,
    this.fallbackAsset,
    this.fallbackWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final provider = _getImageProvider();

    if (provider != null) {
      return Image(
        image: provider,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => fallbackWidget!,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return builder?.call(provider) ?? child;
          return Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return fallbackWidget!;
    }
  }

  ImageProvider? _getImageProvider() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    } else if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
      return AssetImage(fallbackAsset!);
    }
    return null;
  }
}
