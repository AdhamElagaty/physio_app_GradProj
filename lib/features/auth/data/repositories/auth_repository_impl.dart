import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/error_context.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/services/cache/token_cache_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../model/confirm_code_request_model.dart';
import '../model/email_request_model.dart';
import '../model/login_request_model.dart';
import '../model/refresh_token_request_model.dart';
import '../model/register_request_model.dart';
import '../model/reset_password_request_model.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenCacheService _tokenCacheService;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenCacheService,
    this._networkInfo,
  ) : super(_networkInfo);

  @override
  Future<Either<Failure, void>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return handleRequest(() {
      final request = RegisterRequestModel(firstName: firstName, lastName: lastName, email: email, password: password);
      return _remoteDataSource.register(request);
    }, context: ErrorContext.authRegister);
  }

  @override
  Future<Either<Failure, AuthUser>> confirmEmail({required String email, required String code}) {
    return handleRequest(() async {
      final request = ConfirmCodeRequestModel(userEmail: email, code: code);
      final user = await _remoteDataSource.confirmEmail(request);
      await _tokenCacheService.saveTokens(accessToken: user.token.value, accessTokenExpiresOn: user.token.expiresOn, refreshToken: user.refreshToken.value, refreshTokenExpiresOn: user.refreshToken.expiresOn);
      return user;
    }, context: ErrorContext.authConfirmEmailCode);
  }

  @override
  Future<Either<Failure, void>> resendEmailConfirmationCode({required String email}) {
    return handleRequest(() {
      return _remoteDataSource.resendEmailConfirmationCode(EmailRequestModel(email: email));
    }, context: ErrorContext.authResendConfirmationCode);
  }

  @override
  Future<Either<Failure, LoginResult>> login({required String emailOrUsername, required String password}) {
    return handleRequest(() async {
      final request = LoginRequestModel(emailOrUserName: emailOrUsername, password: password);
      try{
        final userModel = await _remoteDataSource.login(request);
        if (userModel.require2FA) {
          return LoginRequires2FA(userModel.email);
        }

      await _tokenCacheService.saveTokens(accessToken: userModel.token.value, accessTokenExpiresOn: userModel.token.expiresOn, refreshToken: userModel.refreshToken.value, refreshTokenExpiresOn: userModel.refreshToken.expiresOn);
      return LoginSuccess(userModel);
      } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
            final response = e.response?.data;
            if (response['message'].toString().toLowerCase().contains('email not confirmed')) {
              return LoginRequiresEmailConfirmation(emailOrUsername);
            }
        }
        rethrow;
      } 
    }, context: ErrorContext.authLogin);
  }

  @override
  Future<Either<Failure, AuthUser>> confirmTwoFactorCode({required String email, required String code}) {
    return handleRequest(() async {
      final request = ConfirmCodeRequestModel(userEmail: email, code: code);
      final user = await _remoteDataSource.confirmTwoFactorCode(request);
      await _tokenCacheService.saveTokens(accessToken: user.token.value, accessTokenExpiresOn: user.token.expiresOn, refreshToken: user.refreshToken.value, refreshTokenExpiresOn: user.refreshToken.expiresOn);
      return user;
    }, context: ErrorContext.authConfirmTwoFactorCode);
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) {
    return handleRequest(() {
      return _remoteDataSource.requestPasswordReset(EmailRequestModel(email: email));
    }, context: ErrorContext.authRequestPasswordReset);
  }

  @override
  Future<Either<Failure, String>> confirmPasswordReset(String email, String code) {
    return handleRequest(() {
      return _remoteDataSource.confirmPasswordReset(ConfirmCodeRequestModel(userEmail: email, code: code));
    }, context: ErrorContext.authConfirmPasswordResetCode);
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email, required String token, required String newPassword}) {
    return handleRequest(() {
      final request = ResetPasswordRequestModel(userEmail: email, token: token, password: newPassword, confirmPassword: newPassword);
      return _remoteDataSource.resetPassword(request);
    }, context: ErrorContext.authSetNewPassword);
  }

  @override
  Future<Either<Failure, LoginSuccess>> refreshSession() async {
    // if (await _networkInfo.isConnected) {
    //   try {
    //     final accessToken = await _tokenCacheService.getAccessToken();
    //     final refreshToken = await _tokenCacheService.getRefreshToken();

    //     if (accessToken == null || refreshToken == null) {
    //       return Left(CacheFailure('No session found.'));
    //     }

    //     final userModel = await _remoteDataSource.refreshSession(
    //       accessToken: accessToken,
    //       refreshToken: refreshToken,
    //     );
        
    //     return Right(LoginSuccess(userModel));
    //   } on ServerException catch (e) {
    //     return Left(ServerFailure(e.message));
    //   } on CacheException {
    //     return Left(CacheFailure("Failed to retrieve tokens from cache"));
    //   }
    // } else {
    //   return Left(NetworkFailure('No internet connection.'));
    // }

    return handleRequest(() async {
      final accessToken = await _tokenCacheService.getAccessToken();
      final refreshToken = await _tokenCacheService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        throw CacheException();
      }

      final userModel = await _remoteDataSource.refreshSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return LoginSuccess(userModel);
    }, context: ErrorContext.authRefreshSession);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await _networkInfo.isConnected) {
      try {
        final accessToken = await _tokenCacheService.getAccessToken();
        final refreshToken = await _tokenCacheService.getRefreshToken();
        if (accessToken != null && refreshToken != null) {
          await _remoteDataSource.revokeToken(RefreshTokenRequestModel(token: accessToken, refreshToken: refreshToken));
        }
      } on DioException {
        log('Failed to revoke token during logout', error: 'DioException occurred');
      }
    }

    await _tokenCacheService.clearTokens();
    return const Right(null);
  }
}
