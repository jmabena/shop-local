import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class NetworkImageWithFallback extends ImageProvider<NetworkImageWithFallback> {
  final String? imageUrl;
  final String fallbackAsset;

  const NetworkImageWithFallback({
    required this.imageUrl,
    required this.fallbackAsset,
  });

  @override
  Future<NetworkImageWithFallback> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageWithFallback>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      NetworkImageWithFallback key, ImageDecoderCallback decode) {
    final Completer<ui.Codec> completer = Completer<ui.Codec>();

    // Try to load the network image first
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      NetworkImage(imageUrl!).resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
              (imageInfo, synchronousCall) async {
            final ByteData? byteData =
            await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final codec =
              await ui.instantiateImageCodec(byteData.buffer.asUint8List());
              completer.complete(codec);
            } else {
              _loadFallback(completer);
            }
          },
          onError: (exception, stackTrace) {
            _loadFallback(completer);
          },
        ),
      );
    } else {
      _loadFallback(completer);
    }

    return MultiFrameImageStreamCompleter(
      codec: completer.future,
      scale: 1.0,
    );
  }

  void _loadFallback(Completer<ui.Codec> completer) async {
    try {
      final ByteData data = await rootBundle.load(fallbackAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      completer.complete(codec);
    } catch (e) {
      completer.completeError(e);
    }
  }
}
