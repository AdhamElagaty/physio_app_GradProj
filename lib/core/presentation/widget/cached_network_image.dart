import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../injection_container.dart';
import '../../services/cache/dynamic_image_cache_service.dart';

class DynamicCachedImage extends StatelessWidget {
  final String cacheKey;
  final String? imageUrl;
  final String? fallbackAssetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;

  const DynamicCachedImage({
    super.key,
    required this.cacheKey,
    this.imageUrl,
    this.fallbackAssetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
  }) : assert(imageUrl != null || fallbackAssetPath != null,
            'Either imageUrl or fallbackAssetPath must be provided.');


  @override
  Widget build(BuildContext context) {
    final String? effectiveUrl = imageUrl;
    final bool isRemote =
        effectiveUrl != null && effectiveUrl.isNotEmpty && effectiveUrl.startsWith('http');

    if (isRemote) {
      return _buildRemoteImage(context, effectiveUrl);
    } else {
      return _buildFallbackOrPlaceholder();
    }
  }

  Widget _buildRemoteImage(BuildContext context, String remoteUrl) {
    final imageCacheService = sl<DynamicImageCacheService>();
    final uniqueId = imageCacheService.getUniqueId(cacheKey, remoteUrl);
    final bool isSvg = remoteUrl.toLowerCase().endsWith('.svg');

    if (isSvg) {
      final initialFile = imageCacheService.getSvgFromMemory(uniqueId);
      return ValueListenableBuilder<File?>(
        valueListenable: imageCacheService.getSvgFileNotifier(key: cacheKey, imageUrl: remoteUrl),
        builder: (context, fileFromNotifier, _) {
          final displayFile = fileFromNotifier ?? initialFile;
          if (displayFile != null) {
            return RepaintBoundary(
              child: SvgPicture.file(
                displayFile,
                width: width,
                height: height,
                fit: fit,
                colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
              ),
            );
          }
          return _buildFallbackOrPlaceholder();
        },
      );
    } else {
      final initialBytes = imageCacheService.getRasterFromMemory(uniqueId);
      return ValueListenableBuilder<Uint8List?>(
        valueListenable: imageCacheService.getRasterImageNotifier(key: cacheKey, imageUrl: remoteUrl),
        builder: (context, bytesFromNotifier, _) {
          final displayBytes = bytesFromNotifier ?? initialBytes;
          if (displayBytes != null) {
            final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            final int? cacheWidth = width != null ? (width! * devicePixelRatio).round() : null;
            final int? cacheHeight = height != null ? (height! * devicePixelRatio).round() : null;

            return RepaintBoundary(
              child: Image.memory(
                displayBytes,
                width: width,
                height: height,
                fit: fit,
                color: color,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackOrPlaceholder();
                },
              ),
            );
          }
          return _buildFallbackOrPlaceholder();
        },
      );
    }
  }

  Widget _buildFallbackOrPlaceholder() {
    final localFallback = fallbackAssetPath;
    if (localFallback != null && localFallback.isNotEmpty) {
      if (localFallback.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          localFallback,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: (context) => placeholder ?? SizedBox(width: width, height: height),
        );
      } else {
        return Image.asset(
          localFallback,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return placeholder ?? SizedBox(width: width, height: height);
          },
        );
      }
    }
    return placeholder ?? SizedBox(width: width, height: height);
  }
}
