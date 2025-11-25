import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Map<String, String>? httpHeaders;
  final int shimmerDelayMs; // ⬅ delay time

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.fit,
    this.borderRadius=BorderRadius.zero,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.httpHeaders,
    this.shimmerDelayMs = 800,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: shimmerDelayMs)),
      builder: (context, snapshot) {
        // Still waiting → show shimmer
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildShimmerPlaceholder();
        }

        // After delay → load actual image
        return _buildCachedImage();
      },
    );
  }

  Widget _buildCachedImage() {
    if (imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: errorWidget ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit ?? BoxFit.cover,
        width: width,
        height: height,
        httpHeaders: httpHeaders,
        placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: borderRadius
        ),
      ),
    );
  }
}