import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return errorWidget ?? _buildDefaultError();
    }

    if (kIsWeb || imagePath.startsWith('http://') || imagePath.startsWith('https://') || imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        headers: kIsWeb
            ? null
            : const {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              },
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: placeholder != null
            ? (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder!;
              }
            : null,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    }
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withOpacity(0.05),
      child: const Icon(Icons.broken_image, size: 24, color: Colors.white24),
    );
  }
}
