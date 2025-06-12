class Endpoints {
  static const String signIn = '/api/auth/login';
  static const String signUp = '/api/auth/register';
  static const String confirmEmail = '/api/auth/confirm-email';
  static const String forgotPassword =
      '/api/auth/resend-email-confirmation-code';
  static const String requestResetPassword = '/api/user/password/request-reset';

  static const String confirmResetPassword = '/api/user/password/confirm-reset';

  static const String resetPassword = 'api/user/password/reset';
  static const String sendMessage = '/api/aibot/message';
}
