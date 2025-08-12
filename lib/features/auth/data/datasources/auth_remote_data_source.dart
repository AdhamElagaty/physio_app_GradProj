import '../model/auth_user_model.dart';
import '../model/confirm_code_request_model.dart';
import '../model/email_request_model.dart';
import '../model/login_request_model.dart';
import '../model/refresh_token_request_model.dart';
import '../model/register_request_model.dart';
import '../model/reset_password_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterRequestModel request);
  Future<AuthUserModel> confirmEmail(ConfirmCodeRequestModel request);
  Future<void> resendEmailConfirmationCode(EmailRequestModel request);
  Future<AuthUserModel> login(LoginRequestModel request);
  Future<AuthUserModel> confirmTwoFactorCode(ConfirmCodeRequestModel request);
  Future<void> requestPasswordReset(EmailRequestModel request);
  Future<String> confirmPasswordReset(ConfirmCodeRequestModel request);
  Future<void> resetPassword(ResetPasswordRequestModel request);
  Future<AuthUserModel> refreshSession({required String accessToken, required String refreshToken});
  Future<void> revokeToken(RefreshTokenRequestModel request);
}
