import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/constatnts.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';

class ApiManager {
  late Dio dio;

  ApiManager() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConstatnts.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    dio = Dio(options);

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          Token? token = CacheHelper.getToken('token');

          // Check if token expired
          if (token != null && _isTokenExpired(token.expiresOn)) {
            debugPrint("Token expired. Trying to refresh...");
            final newAccessToken = await _refreshAccessToken();
            if (newAccessToken != null) {
              token = newAccessToken;
            }
          }

          if (token != null && token.value.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.value}';
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

  // Check if token expired
  bool _isTokenExpired(String expiresOn) {
    final expiryDate = DateTime.tryParse(expiresOn);
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate);
  }

  // Call refresh token API
  Future<Token?> _refreshAccessToken() async {
    final refreshToken = CacheHelper.getToken('refreshToken');

    if (refreshToken == null || refreshToken.value.isEmpty) {
      debugPrint("No refresh token available.");
      return null;
    }

    try {
      final response = await dio.post(
        '/Account/RefreshToken',
        data: {'refreshToken': refreshToken.value},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final newTokenJson = response.data['data']['token'];
        final newToken = Token.fromJson(newTokenJson);

        // Save new token
        await CacheHelper.saveToken('token', newToken);

        debugPrint("Token refreshed successfully.");
        return newToken;
      } else {
        debugPrint("Failed to refresh token: ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("Error during token refresh: $e");
      return null;
    }
  }
}
// class ApiManager {
//   late Dio dio;

//   ApiManager() {
//     BaseOptions options = BaseOptions(
//       baseUrl: AppConstatnts.baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//     );

//     dio = Dio(options);

//     // Add Interceptors
//     dio.interceptors.addAll([
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final token = await CacheHelper.getToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },
//       ),
//       LogInterceptor(
//         request: true,
//         requestHeader: true,
//         requestBody: true,
//         responseHeader: false,
//         responseBody: true,
//         error: true,
//         logPrint: (obj) => debugPrint(obj.toString()),
//       ),
//     ]);
//   }

//   Future<Response> getData({
//     required String endPoint,
//     Map<String, dynamic>? params,
//     Map<String, dynamic>? headers,
//   }) async {
//     return await dio.get(
//       endPoint,
//       queryParameters: params,
//       options: Options(headers: headers),
//     );
//   }

//   Future<Response> postData({
//     required String endPoint,
//     Map<String, dynamic>? body,
//     Map<String, dynamic>? headers,
//   }) async {
//     return await dio.post(
//       endPoint,
//       data: body,
//       options: Options(headers: headers),
//     );
//   }
// }
