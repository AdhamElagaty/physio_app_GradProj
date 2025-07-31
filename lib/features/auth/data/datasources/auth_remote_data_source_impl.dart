import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../model/auth_user_model.dart';
import '../model/confirm_code_request_model.dart';
import '../model/email_request_model.dart';
import '../model/login_request_model.dart';
import '../model/refresh_token_request_model.dart';
import '../model/register_request_model.dart';
import '../model/reset_password_request_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer _apiConsumer;
  AuthRemoteDataSourceImpl(this._apiConsumer);

  @override
  Future<void> register(RegisterRequestModel request) async => await _apiConsumer.post(Endpoints.signUpPost, body: request.toJson());

  @override
  Future<AuthUserModel> confirmEmail(ConfirmCodeRequestModel request) async {
    final response = await _apiConsumer.post(Endpoints.confirmEmailPost, body: request.toJson());
    return AuthUserModel.fromJson(response['data']);
  }

  @override
  Future<void> resendEmailConfirmationCode(EmailRequestModel request) async => await _apiConsumer.post(Endpoints.resendEmailConfirmationPost, body: request.toJson());

  @override
  Future<AuthUserModel> login(LoginRequestModel request) async {
    final response = await _apiConsumer.post(Endpoints.signInPost, body: request.toJson());
    return AuthUserModel.fromJson(response['data']);
  }

  @override
  Future<AuthUserModel> confirmTwoFactorCode(ConfirmCodeRequestModel request) async {
    final response = await _apiConsumer.post(Endpoints.confirmTwoFactorPost, body: request.toJson());
    return AuthUserModel.fromJson(response['data']);
  }

  @override
  Future<void> requestPasswordReset(EmailRequestModel request) async => await _apiConsumer.post(Endpoints.requestResetPassword, body: request.toJson());

  @override
  Future<String> confirmPasswordReset(ConfirmCodeRequestModel request) async {
    final response = await _apiConsumer.post(Endpoints.confirmResetPassword, body: request.toJson());
    // The backend returns the token in response.data['data']['token']
    return response['data']['token'];
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async => await _apiConsumer.post(Endpoints.resetPassword, body: request.toJson());

   @override
  Future<AuthUserModel> refreshSession({required String accessToken, required String refreshToken}) async {
    final response = await _apiConsumer.post(
      Endpoints.refreshTokenPost,
      body: {
        'token': accessToken,
        'refreshToken': refreshToken,
      },
    );

    return AuthUserModel.fromJson(response['data']);
  }
  
  @override
  Future<void> revokeToken(RefreshTokenRequestModel request) async => await _apiConsumer.post(Endpoints.logoutPost, body: request.toJson());
}