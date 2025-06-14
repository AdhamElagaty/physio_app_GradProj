import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/constatnts.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/constatnts.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiManager {
  late Dio dio;
  bool _isRefreshing = false;

  ApiManager() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConstatnts.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    dio = Dio(options);

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path == '/Account/RefreshToken') {
            return handler.next(options);
          }

          Token? token = CacheHelper.getToken('token');

          if (token != null &&
              _isTokenExpiredOrCloseToExpire(token.expiresOn)) {
            if (!_isRefreshing) {
              _isRefreshing = true;
              debugPrint(
                  "Token expired or close to expire. Trying to refresh...");
              final newToken = await _refreshAccessToken();
              if (newToken != null) {
                token = newToken;
              }
              _isRefreshing = false;
            }
          }

          if (token != null && token.value.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.value}';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            debugPrint("Received 401, attempting token refresh...");

            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer ${newToken.value}';

              _isRefreshing = false;
              return handler.resolve(await dio.fetch(options));
            }

            _isRefreshing = false;
          }

          return handler.next(error);
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

  Future<Response> putData({
    required String endPoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    return await dio.put(
      endPoint,
      data: body,
      options: Options(headers: headers),
    );
  }

  Future<Response> deleteData({
    required String endPoint,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    return await dio.delete(
      endPoint,
      queryParameters: params,
      options: Options(headers: headers),
    );
  }

  bool _isTokenExpiredOrCloseToExpire(String expiresOn) {
    final expiryDate = DateTime.tryParse(expiresOn);
    if (expiryDate == null) return true;

    final bufferDuration = const Duration(minutes: 5);
    return DateTime.now().add(bufferDuration).isAfter(expiryDate);
  }

  Future<Token?> _refreshAccessToken() async {
    final refreshToken = CacheHelper.getToken('refreshToken');

    if (refreshToken == null || refreshToken.value.isEmpty) {
      debugPrint("No refresh token available.");
      await _logoutUser();
      return null;
    }

    try {
      final response = await dio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': refreshToken.value},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final newTokenJson = response.data['data']['token'];
        final newToken = Token.fromJson(newTokenJson);

        await CacheHelper.saveToken('token', newToken);
        debugPrint("Token refreshed successfully.");
        return newToken;
      } else {
        debugPrint("Failed to refresh token: ${response.data}");
        await _logoutUser();
        return null;
      }
    } catch (e) {
      debugPrint("Error during token refresh: $e");
      await _logoutUser();
      return null;
    }
  }

  Future<void> _logoutUser() async {
    await CacheHelper.logoutUser();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

// class ApiManager {
//   late Dio dio;
//   bool _isRefreshing = false;

//   ApiManager() {
//     BaseOptions options = BaseOptions(
//       baseUrl: AppConstatnts.baseUrl,
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//     );

//     dio = Dio(options);

//     dio.interceptors.addAll([
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Skip token check for refresh token endpoint
//           if (options.path == '/Account/RefreshToken') {
//             return handler.next(options);
//           }

//           Token? token = CacheHelper.getToken('token');

//           // Check if token expired or about to expire (5 minute buffer)
//           if (token != null &&
//               _isTokenExpiredOrCloseToExpire(token.expiresOn)) {
//             if (!_isRefreshing) {
//               _isRefreshing = true;
//               debugPrint(
//                   "Token expired or close to expire. Trying to refresh...");
//               final newToken = await _refreshAccessToken();
//               if (newToken != null) {
//                 token = newToken;
//               }
//               _isRefreshing = false;
//             }
//           }

//           if (token != null && token.value.isNotEmpty) {
//             options.headers['Authorization'] = 'Bearer ${token.value}';
//           }

//           return handler.next(options);
//         },
//         onError: (DioException error, handler) async {
//           // Handle 401 unauthorized errors
//           if (error.response?.statusCode == 401 && !_isRefreshing) {
//             _isRefreshing = true;
//             debugPrint("Received 401, attempting token refresh...");

//             final newToken = await _refreshAccessToken();
//             if (newToken != null) {
//               // Retry the original request with new token
//               final options = error.requestOptions;
//               options.headers['Authorization'] = 'Bearer ${newToken.value}';

//               _isRefreshing = false;
//               return handler.resolve(await dio.fetch(options));
//             }
//             _isRefreshing = false;
//           }
//           return handler.next(error);
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

//   Future<Response> putData({
//     required String endPoint,
//     Map<String, dynamic>? body,
//     Map<String, dynamic>? headers,
//   }) async {
//     return await dio.put(
//       endPoint,
//       data: body,
//       options: Options(headers: headers),
//     );
//   }

//   Future<Response> deleteData({
//     required String endPoint,
//     Map<String, dynamic>? params,
//     Map<String, dynamic>? headers,
//   }) async {
//     return await dio.delete(
//       endPoint,
//       queryParameters: params,
//       options: Options(headers: headers),
//     );
//   }

//   // Check if token expired or close to expire (within 5 minutes)
//   bool _isTokenExpiredOrCloseToExpire(String expiresOn) {
//     final expiryDate = DateTime.tryParse(expiresOn);
//     if (expiryDate == null) return true;

//     final bufferDuration = const Duration(minutes: 5);
//     return DateTime.now().add(bufferDuration).isAfter(expiryDate);
//   }

//   // Call refresh token API
//   Future<Token?> _refreshAccessToken() async {
//     final refreshToken = CacheHelper.getToken('refreshToken');

//     if (refreshToken == null || refreshToken.value.isEmpty) {
//       debugPrint("No refresh token available.");
//       return null;
//     }

//     try {
//       final response = await dio.post(
//         '/Account/RefreshToken',
//         data: {'refreshToken': refreshToken.value},
//       );

//       if (response.statusCode == 200 && response.data['data'] != null) {
//         final newTokenJson = response.data['data']['token'];
//         final newToken = Token.fromJson(newTokenJson);

//         // Save new tokens
//         await CacheHelper.saveToken('token', newToken);

//         debugPrint("Token refreshed successfully.");
//         return newToken;
//       } else {
//         debugPrint("Failed to refresh token: ${response.data}");
//         // Optionally logout user here if refresh fails
//         return null;
//       }
//     } catch (e) {
//       debugPrint("Error during token refresh: $e");
//       // Optionally logout user here if refresh fails
//       return null;
//     }
//   }
// }
