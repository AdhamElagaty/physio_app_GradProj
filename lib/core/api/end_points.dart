class Endpoints {
  static const String signIn = '/api/auth/login';
  static const String signUp = '/api/auth/register';
  static const String confirmEmail = '/api/auth/confirm-email';
  static const String resendEmailConfirmation =
      '/api/auth/resend-email-confirmation-code';
  static const String requestResetPassword = '/api/user/password/request-reset';

  static const String confirmResetPassword = '/api/user/password/confirm-reset';

  static const String resetPassword = '/api/user/password/reset';

  static const String sendMessage = '/api/aibot/message';
  static String updateChatTitle(String chatId) =>
      '/api/aibot/chats/$chatId'; // Function to generate endpoint
  static String deleteChat(String chatId) =>
      '/api/aibot/chats/$chatId'; // Function to generate endpoint
  static String getChats = '/api/aibot/chats';
  static String getChatMessages(String chatId) => '/api/aibot/chats/$chatId';
}
