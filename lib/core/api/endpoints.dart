class Endpoints {
  // Base URL for the API
  static const String baseUrl = "https://physio.tryasp.net";

  // Authentication Endpoints
  static const String _baseAuthEndpoints = '/api/auth';
  static const String signInPost = '$_baseAuthEndpoints/login';
  static const String signUpPost = '$_baseAuthEndpoints/register';
  static const String confirmEmailPost = '$_baseAuthEndpoints/confirm-email';
  static const String resendEmailConfirmationPost = '$_baseAuthEndpoints/resend-email-confirmation-code';
  static const String confirmTwoFactorPost = '$_baseAuthEndpoints/confirm-two-factor';
  static const String refreshTokenPost = '$_baseAuthEndpoints/refresh-token';
  static const String logoutPost = '$_baseAuthEndpoints/revoke-token';

  // User Profile Endpoints
  static const String _baseUserEndpoints = '/api/user';
  static const String userProfileGet = _baseUserEndpoints;
  static const String userUpdatePut = _baseUserEndpoints;
  static const String requestRemoveUserPost = '$_baseUserEndpoints/request-delete';
  static const String removeUserDelete = _baseUserEndpoints;
  // User Password Endpoints
  static const String _basePasswordEndpoints = '$_baseUserEndpoints/password';
  static const String requestResetPassword = '$_basePasswordEndpoints/request-reset';
  static const String confirmResetPassword = '$_basePasswordEndpoints/confirm-reset';
  static const String resetPassword = '$_basePasswordEndpoints/reset';
  static const String requestChangePassword = '$_basePasswordEndpoints/request-change';
  static const String confirmChangePassword = '$_basePasswordEndpoints/confirm-change';
  static const String changePassword = '$_basePasswordEndpoints/change';
  // User Change Two Factor Status Endpoints
  static const String _baseTwoFactorEndpoints = '$_baseUserEndpoints/2fa/toggle';
  static const String requestEnableTwoFactor = '$_baseTwoFactorEndpoints/enable';
  static const String requestDisableTwoFactor = '$_baseTwoFactorEndpoints/disable';
  static const String confirmEnableTwoFactor = _baseTwoFactorEndpoints;
  // User Avatar Endpoints
  static const String _baseAvatarEndpoints = '$_baseUserEndpoints/picture';
  static const String userAvatarPut = _baseAvatarEndpoints;
  static const String userAvatarDelete = _baseAvatarEndpoints;

  // Exercise Endpoints
  static const String _baseExerciseEndpoints = '/api/exercise';
  static const String allExercisesGet = _baseExerciseEndpoints;
  // Exercise Categories Endpoints
  static const String exerciseCategoriesGet = '$_baseExerciseEndpoints/categories';
  // Exercise History Endpoints
  static const String exerciseHistoryGet = '$_baseExerciseEndpoints/history';
  static const String exerciseHistoryPost = '$_baseExerciseEndpoints/history';
  // Exercise Favorites Endpoints
  static String addexerciseFavoritePost(String exerciseId) => '$_baseExerciseEndpoints/favorites/$exerciseId';
  static String removeExerciseFavoriteDelete(String exerciseId) => '$_baseExerciseEndpoints/favorites/$exerciseId';

  // AI Bot Endpoints
  static const String _baseAIBotEndpoints = '/api/aibot';
  static const String sendMessagePost = '$_baseAIBotEndpoints/message';
  // AI Bot Chat Endpoints
  static const String _baseAIChatEndpoints = '$_baseAIBotEndpoints/chats';
  static const String chatsGet = _baseAIChatEndpoints;
  static String chatMessagesGet(String chatId) => '$_baseAIChatEndpoints/$chatId';
  static String updateChatTitlePut(String chatId) => '$_baseAIChatEndpoints/$chatId';
  static String deleteChatDelete(String chatId) => '$_baseAIChatEndpoints/$chatId';
}
