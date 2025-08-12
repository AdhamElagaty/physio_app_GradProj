import 'package:dio/dio.dart';

import '../../presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../../injection_container.dart';
import '../../services/cache/token_cache_service.dart';
import '../endpoints.dart';

class AuthInterceptor extends Interceptor {
  final TokenCacheService _tokenCacheService;
  final Dio _dio;

  AppManagerCubit get _authCubit => sl<AppManagerCubit>();

  AuthInterceptor(this._tokenCacheService, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // For public endpoints, just continue
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }
    
    final accessToken = await _tokenCacheService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isTokenRefreshEndpoint(err.requestOptions.path)) {
      try {
        final newTokens = await _refreshToken();
        if (newTokens != null) {
          await _tokenCacheService.saveTokens(
            accessToken: newTokens['accessToken'],
            accessTokenExpiresOn: newTokens['accessTokenExpiresOn'],
            refreshToken: newTokens['refreshToken'],
            refreshTokenExpiresOn: newTokens['refreshTokenExpiresOn'],
          );

          // Retry the original request with the new token
          final newOptions = err.requestOptions
            ..headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';

          final response = await _dio.fetch(newOptions);
          return handler.resolve(response);
        }
      } on DioException {
        // Refresh token failed, clear tokens and propagate error
        // await _tokenStorage.clearTokens();
        _authCubit.sessionExpired();
        // You might want to navigate to login screen here
      }
    }
    return handler.next(err);
  }

  Future<Map<String, dynamic>?> _refreshToken() async {
    final refreshToken = await _tokenCacheService.getRefreshToken();
    final accessToken = await _tokenCacheService.getAccessToken();

    if (refreshToken == null || accessToken == null) {
      return null;
    }

    try {
      final response = await _dio.post(
        Endpoints.refreshTokenPost,
        data: {
          'token': accessToken,
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['token']['value'];
        final accessTokenExpiresOn = DateTime.parse(response.data['data']['token']['expiresOn']);
        final newRefreshToken = response.data['data']['refreshToken']['value'];
        final refreshTokenExpiresOn = DateTime.parse(response.data['data']['refreshToken']['expiresOn']);
        return {
          'accessToken': newAccessToken,
          'accessTokenExpiresOn': accessTokenExpiresOn,
          'refreshToken': newRefreshToken,
          'refreshTokenExpiresOn': refreshTokenExpiresOn,
        };
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  bool _isPublicEndpoint(String path) {
    return path == Endpoints.signInPost ||
           path == Endpoints.signUpPost ||
           path == Endpoints.confirmEmailPost ||
           path == Endpoints.resendEmailConfirmationPost;
  }

  bool _isTokenRefreshEndpoint(String path) {
    return path == Endpoints.refreshTokenPost ||
           path == Endpoints.logoutPost ||
           path == Endpoints.signInPost ||
           path == Endpoints.signUpPost ||
           path == Endpoints.confirmEmailPost ||
           path == Endpoints.resendEmailConfirmationPost || 
           path == Endpoints.requestResetPassword ||
           path == Endpoints.confirmResetPassword ||
           path == Endpoints.resetPassword ||
           path == Endpoints.confirmTwoFactorPost;
  }
}