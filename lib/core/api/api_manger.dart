import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/constatnts.dart';

class ApiManager {
  late Dio dio;

  ApiManager() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConstatnts.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    dio = Dio(options);

    // Add Interceptors
    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await CacheHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    ]);
  }

  Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    return await dio.get(
      endPoint,
      queryParameters: params,
      options: Options(headers: headers),
    );
  }

  Future<Response> postData({
    required String endPoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    return await dio.post(
      endPoint,
      data: body,
      options: Options(headers: headers),
    );
  }
}
