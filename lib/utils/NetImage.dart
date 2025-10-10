import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/*final imageCacheManager = CacheManager(
  Config(
    'imageCache',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 200,
  ),
);*/
class NetImage extends StatelessWidget {
  static final CacheManager _imageCacheManager = CacheManager(
    Config(
      'imageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool cache;

  const NetImage(
      {Key? key,
      required this.url,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.cache = false})
      : super(key: key);

  bool get _isSvg => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      // SVG 图片（flutter_svg 不自带缓存）
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );
    } else {
      // 普通图片：使用 cached_network_image
      if (cache) {
        return CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          cacheManager: _imageCacheManager,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
        );
      } else {
        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        );
      }
    }
  }
}
