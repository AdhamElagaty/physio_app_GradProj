import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../services/cache/token_cache_service.dart';
import 'endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';

class DioFactory {
  final TokenCacheService _tokenCacheService;

  DioFactory(this._tokenCacheService);

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    final tokenRefreshDio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));

    dio.interceptors.addAll([
      AuthInterceptor(_tokenCacheService, tokenRefreshDio),
      ErrorInterceptor(),
      if (kDebugMode) AppLogInterceptor(),
    ]);

    return dio;
  }
}