import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackAsset; // Path to a default image asset
  final Widget? fallbackWidget; // An alternative widget to use as a fallback
  final Widget Function(ImageProvider imageProvider)? builder; // A builder function that takes an ImageProvider

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.fallbackAsset,
    this.fallbackWidget,
    this.builder
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty ||
        !imageUrl!.startsWith('http')) {
      // Handle missing or invalid URL
      ImageProvider imageProvider;
      if (fallbackAsset != null) {
        imageProvider = AssetImage(fallbackAsset!);
      } else if (fallbackWidget != null) {
        return fallbackWidget!;
      } else {
        return const Icon(Icons.image);
      }
      if (builder != null) {
        return builder!(imageProvider);
      }
      return Image(image: imageProvider);
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
        builder != null ? (fallbackAsset != null ? builder!(AssetImage(fallbackAsset!)) : fallbackWidget!) : const Icon(
            Icons.error),
        imageBuilder: builder != null ? (context, imageProvider) =>
            builder!(imageProvider) : null,
      );
    }
  }
}