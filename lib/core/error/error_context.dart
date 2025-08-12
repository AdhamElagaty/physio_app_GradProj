import 'error_feature_tybe.dart';

enum ErrorContext {
  // --- Auth feature ---
  authLogin,
  authRegister,
  authResendConfirmationCode,
  authRequestPasswordReset,
  authConfirmPasswordResetCode,
  authSetNewPassword,
  authConfirmEmailCode,
  authConfirmTwoFactorCode,
  authRefreshSession,
  authLogout,

  // --- Chat feature ---
  chatGetChats,
  chatGetChatMessages,
  chatSendMessage,
  chatDeleteChat,
  chatUpdateTitle,

  // --- Exercise feature ---
  exerciseGetExercises,
  exerciseGetExerciseCategories,
  exerciseGetExerciseHistory,
  exerciseAddExerciseHistory, 
  exerciseAddExerciseFavorite,
  exerciseRemoveExerciseFavorite,

  // --- User Profile feature ---
  userGetCurrentUserDetails,

  // --- general feature ---
  general
}

extension ErrorContextExtension on ErrorContext {
  ErrorFeatureType get featureType {
    switch (this) {
      case ErrorContext.authLogin:
      case ErrorContext.authRegister:
      case ErrorContext.authResendConfirmationCode:
      case ErrorContext.authRequestPasswordReset:
      case ErrorContext.authConfirmPasswordResetCode:
      case ErrorContext.authSetNewPassword:
      case ErrorContext.authConfirmEmailCode:
      case ErrorContext.authConfirmTwoFactorCode:
      case ErrorContext.authRefreshSession:
      case ErrorContext.authLogout:
        return ErrorFeatureType.auth;

      case ErrorContext.chatGetChats:
      case ErrorContext.chatGetChatMessages:
      case ErrorContext.chatSendMessage:
      case ErrorContext.chatDeleteChat:
      case ErrorContext.chatUpdateTitle:
        return ErrorFeatureType.chatBot;

      case ErrorContext.exerciseGetExercises:
      case ErrorContext.exerciseGetExerciseCategories:
      case ErrorContext.exerciseGetExerciseHistory:
      case ErrorContext.exerciseAddExerciseHistory:
      case ErrorContext.exerciseAddExerciseFavorite:
      case ErrorContext.exerciseRemoveExerciseFavorite:
        return ErrorFeatureType.exercise;

      case ErrorContext.userGetCurrentUserDetails:
        return ErrorFeatureType.userProfile;

      default:
        return ErrorFeatureType.general;
    }
  }
}
