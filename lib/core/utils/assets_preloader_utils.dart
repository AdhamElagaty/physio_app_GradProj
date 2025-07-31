import 'dart:async';
import 'dart:developer';

import 'package:flutter_svg/flutter_svg.dart';

import 'styles/app_assets.dart';

class AssetPreloaderUtils {
  const AssetPreloaderUtils._();

  static Future<void> precacheAllAssets() async {
    final stopwatch = Stopwatch()..start();
    log('[AssetPreloader] Starting asset pre-caching without context...');

    final svgPaths = AppAssets.getAllSvgAssets();

    await _precacheSvgsForSvgPicture(svgPaths);

    stopwatch.stop();
    log('[AssetPreloader] All assets pre-cached in ${stopwatch.elapsedMilliseconds}ms.');
  }

  static Future<void> _precacheSvgsForSvgPicture(List<String> assetPaths) async {
    final futures = <Future<void>>[];
    for (final path in assetPaths) {
      futures.add(() async {
        try {
          final loader = SvgAssetLoader(path);
          await svg.cache.putIfAbsent(
            loader.cacheKey(null),
            () => loader.loadBytes(null),
          );
        } catch (e) {
          log('[AssetPreloader] Failed to precache SVG for SvgPicture: $path - Error: $e');
        }
      }());
    }
    await Future.wait(futures);
  }
}
