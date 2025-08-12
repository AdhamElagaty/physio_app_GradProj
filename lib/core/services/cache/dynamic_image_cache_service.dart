import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool/pool.dart';

import '../../api/api_consumer.dart';

Future<bool> _areByteListsEqual(Map<String, Uint8List> params) async {
  return listEquals(params['list1'], params['list2']);
}

Future<Uint8List?> _readBytesFromFile(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
  } catch (e) {
    debugPrint("Error reading file in isolate: $e");
  }
  return null;
}

// --- HEAVILY REFACTORED SERVICE ---

class DynamicImageCacheService {
  final ApiConsumer _apiConsumer;
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  final Directory _cacheDir;

  final Map<String, Uint8List> _rasterMemoryCache = {};
  final Map<String, File> _svgMemoryCache = {};
  final Map<String, ValueNotifier<Uint8List?>> _rasterNotifiers = {};
  final Map<String, ValueNotifier<File?>> _svgNotifiers = {};
  final Set<String> _loadOperationsInProgress = {};

  // MODIFIED: We now have two separate pools for different types of work.
  final Pool _networkFetchPool = Pool(5); // For slower network operations
  final Pool _diskReadPool = Pool(3);     // NEW: For fast disk I/O. A small number is best.

  DynamicImageCacheService._(this._apiConsumer, this._connectivity, this._prefs, this._cacheDir);

  static Future<DynamicImageCacheService> create({
    required ApiConsumer apiConsumer,
  }) async {
    final connectivity = Connectivity();
    final prefs = await SharedPreferences.getInstance();
    final cacheDir = await getApplicationDocumentsDirectory();
    return DynamicImageCacheService._(apiConsumer, connectivity, prefs, cacheDir);
  }

  // (getUniqueId, getRasterFromMemory, getSvgFromMemory, get...Notifier methods are unchanged)
  String getUniqueId(String key, String imageUrl) => '$key::$imageUrl';
  Uint8List? getRasterFromMemory(String uniqueId) => _rasterMemoryCache[uniqueId];
  File? getSvgFromMemory(String uniqueId) => _svgMemoryCache[uniqueId];
  ValueNotifier<Uint8List?> getRasterImageNotifier({
    required String key,
    required String imageUrl,
  }) {
    final uniqueId = getUniqueId(key, imageUrl);
    if (!_rasterNotifiers.containsKey(uniqueId)) {
      _rasterNotifiers[uniqueId] = ValueNotifier<Uint8List?>(getRasterFromMemory(uniqueId));
      _loadImage(uniqueId: uniqueId, imageUrl: imageUrl);
    }
    return _rasterNotifiers[uniqueId]!;
  }
  ValueNotifier<File?> getSvgFileNotifier({
    required String key,
    required String imageUrl,
  }) {
    final uniqueId = getUniqueId(key, imageUrl);
    if (!_svgNotifiers.containsKey(uniqueId)) {
      _svgNotifiers[uniqueId] = ValueNotifier<File?>(getSvgFromMemory(uniqueId));
      _loadImage(uniqueId: uniqueId, imageUrl: imageUrl);
    }
    return _svgNotifiers[uniqueId]!;
  }
  
  Future<void> _loadImage({
    required String uniqueId,
    required String imageUrl,
  }) async {
    if (_loadOperationsInProgress.contains(uniqueId)) return;
    _loadOperationsInProgress.add(uniqueId);
    
    try {
      final isSvg = p.extension(imageUrl).toLowerCase() == '.svg';
      final localFile = _getLocalFile(uniqueId: uniqueId, imageUrl: imageUrl);
      
      // MODIFIED: The disk read operation is now controlled by our new pool.
      // This prevents a storm of 'compute' calls, which was the source of the "little lag".
      await _diskReadPool.withResource(() async {
        if (isSvg) {
          if (await localFile.exists()) {
             _svgMemoryCache[uniqueId] = localFile;
             _svgNotifiers[uniqueId]?.value = localFile;
          }
        } else {
          final bytesFromDisk = await compute(_readBytesFromFile, localFile.path);
          if (bytesFromDisk != null) {
            _rasterMemoryCache[uniqueId] = bytesFromDisk;
            _rasterNotifiers[uniqueId]?.value = bytesFromDisk;
          }
        }
      });

      // (Network fetch logic remains the same, it's already well-managed)
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) return;

      final etagKey = _getEtagKeyFromUniqueId(uniqueId);
      final savedEtag = _prefs.getString(etagKey);
      
      final needsNetworkCheck = isSvg 
          ? _svgMemoryCache[uniqueId] == null 
          : _rasterMemoryCache[uniqueId] == null;

      if (needsNetworkCheck || savedEtag != null) {
        await _fetchFromNetwork(uniqueId: uniqueId, imageUrl: imageUrl, savedEtag: savedEtag);
      }
    } finally {
      _loadOperationsInProgress.remove(uniqueId);
    }
  }

  // (The rest of the service class remains unchanged)
  Future<void> _fetchFromNetwork({
    required String uniqueId,
    required String imageUrl,
    String? savedEtag,
  }) async {
    await _networkFetchPool.withResource(() async {
      try {
        final headers = <String, String>{};
        if (savedEtag != null) headers['If-None-Match'] = savedEtag;

        final options = Options(headers: headers, responseType: ResponseType.bytes);
        final response = await _apiConsumer.getWithFullResponse(imageUrl, options: options);

        if (response.statusCode == 200) {
          final Uint8List imageBytes = response.data;
          final localFile = _getLocalFile(uniqueId: uniqueId, imageUrl: imageUrl);
          await localFile.writeAsBytes(imageBytes);

          final newEtag = response.headers.value('etag');
          if (newEtag != null) await _prefs.setString(_getEtagKeyFromUniqueId(uniqueId), newEtag);

          final isSvg = p.extension(imageUrl).toLowerCase() == '.svg';
          if (isSvg) {
            _svgMemoryCache[uniqueId] = localFile;
            _svgNotifiers[uniqueId]?.value = localFile;
          } else {
            final isEqual = _rasterMemoryCache.containsKey(uniqueId)
                ? await compute(_areByteListsEqual, {'list1': _rasterMemoryCache[uniqueId]!, 'list2': imageBytes})
                : false;
            
            if (!isEqual) {
              _rasterMemoryCache[uniqueId] = imageBytes;
              _rasterNotifiers[uniqueId]?.value = imageBytes;
            }
          }
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 304) {
        } else {
          debugPrint('ImageCacheManager: Network exception for $uniqueId: $e');
        }
      }
    });
  }

  String _getFileName({required String uniqueId, required String imageUrl}) {
    final extension = p.extension(imageUrl, 2);
    final safeName = uniqueId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'cache_${safeName.hashCode}$extension';
  }

  String _getEtagKeyFromUniqueId(String uniqueId) => 'etag_${uniqueId.hashCode}';

  File _getLocalFile({required String uniqueId, required String imageUrl}) {
    final fileName = _getFileName(uniqueId: uniqueId, imageUrl: imageUrl);
    return File(p.join(_cacheDir.path, fileName));
  }
}