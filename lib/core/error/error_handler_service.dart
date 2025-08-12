import 'error_context.dart';
import 'error_feature_tybe.dart';
import 'failure.dart';

class ErrorHandlerService {
  String getMessageFromFailure(Failure failure) {
    if (failure is ServerFailure) {
      return _handleServerFailure(failure);
    } else if (failure is NetworkFailure) {
      return "You're currently offline. Please connect to the internet to continue.";
    } else if (failure is CacheFailure) {
      return "A local data error occurred. Please try restarting the app.";
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  String _handleServerFailure(ServerFailure failure) {
    final featureType = failure.context.featureType;
    switch (featureType) {
      case ErrorFeatureType.auth:
        return _getAuthErrorMessage(failure);
      case ErrorFeatureType.exercise:
        return _getExerciseErrorMessage(failure);
      case ErrorFeatureType.chatBot:
        return _getChatErrorMessage(failure);
      case ErrorFeatureType.userProfile:
        return "An error occurred while fetching user profile data. Please try again later.";
      default:
        return "An unexpected error occurred. Please try again.";
    }
  }

  String _getChatErrorMessage(ServerFailure failure) {
    final normalizedMessage = failure.message.toLowerCase().trim();
    final context = failure.context;

    if (normalizedMessage == 'invalid credentials.') {
      return "Your session may have expired. Please log out and sign in again.";
    }

    if (failure is NotFoundFailure) {
      switch (context) {
        case ErrorContext.chatGetChats:
          return "You don't have any conversations yet. Start a new chat to see it here.";
        case ErrorContext.chatGetChatMessages:
        case ErrorContext.chatSendMessage:
        case ErrorContext.chatDeleteChat:
        case ErrorContext.chatUpdateTitle:
          return "This chat is no longer available. It may have been deleted.";
        default:
          return "We couldn't find what you were looking for. Please try again.";
      }
    }

    if (normalizedMessage.contains('cannot be null or empty')) {
      return "We couldn't process your request due to a technical issue. Please try again.";
    }

    if (context == ErrorContext.chatSendMessage) {
      return "The assistant was unable to respond. Please check your connection and try sending your message again.";
    }

    return "There was an issue with the chat service. Please pull to refresh or try again in a moment.";
  }

  String _getExerciseErrorMessage(ServerFailure failure) {
    final normalizedMessage = failure.message.toLowerCase().trim();
    final context = failure.context;

    if (normalizedMessage == 'invalid credentials.') {
      return "Your session may have expired. Please log out and sign in again.";
    }

    if (failure is NotFoundFailure) {
      switch (context) {
        case ErrorContext.exerciseGetExercises:
          return "We couldn't find any exercises matching your criteria. Please try different search terms or filters.";
        case ErrorContext.exerciseGetExerciseHistory:
          return "No workout history was found for your current selection. Try changing the date range or filters.";
        case ErrorContext.exerciseGetExerciseCategories:
          return "We couldn't load the exercise categories at the moment. Please pull to refresh or try again later.";
        case ErrorContext.exerciseAddExerciseHistory:
        case ErrorContext.exerciseAddExerciseFavorite:
        case ErrorContext.exerciseRemoveExerciseFavorite:
          return "This exercise is no longer available. It may have been updated or removed.";
        default:
          break;
      }
    }

    const specificErrorMap = {
      'exercise already favorited by user.':
          "This exercise is already in your favorites.",
      'exercise not favorited by user.':
          "This exercise is not in your favorites list.",
      'max holding time must be greater than zero for this exercise type.':
          "For this type of exercise, you must provide a holding time.",
      'invalid exercise id format.':
          "An error occurred because of an invalid request. Please try again.",
      'exercise not found.':
          "This exercise is no longer available. It may have been updated or removed.",
    };

    final specificMessage = specificErrorMap[normalizedMessage];
    if (specificMessage != null) {
      return specificMessage;
    }

    return "We ran into a problem on our end. Please try that again in a moment.";
  }

  String _getAuthErrorMessage(ServerFailure failure) {
    final normalizedMessage = failure.message.toLowerCase().trim();
    final context = failure.context;

    if (normalizedMessage == 'invalid credentials.') {
      switch (context) {
        case ErrorContext.authLogin:
          return "The email or password you entered is incorrect. Please check your details and try again.";
        case ErrorContext.authConfirmEmailCode:
        case ErrorContext.authConfirmTwoFactorCode:
        case ErrorContext.authConfirmPasswordResetCode:
          return "The code you entered is incorrect or has expired. Please try again or request a new one.";
        case ErrorContext.authRefreshSession:
          return "Your session has expired. Please log in again to continue.";
        default:
          return "The information you provided is incorrect. Please double-check and try again.";
      }
    }

    if (normalizedMessage.startsWith('you do not have a local password')) {
      return failure.message;
    }

    const specificErrorMap = {
      'your account has been locked due to multiple failed login attempts.':
          "For your security, your account has been temporarily locked. Please use the 'Forgot Password' feature to unlock it.",
      'email not confirmed. please verify your email.':
          "This email hasn't been verified yet. We've automatically sent you a new confirmation code.",
      'registration failed. please try again or contact support.':
          "We couldn't create your account. This email might already be registered. Please check your details or try logging in.",
      'email has already been confirmed.':
          "This email address has already been verified. You can go ahead and log in.",
    };

    final specificMessage = specificErrorMap[normalizedMessage];
    if (specificMessage != null) {
      return specificMessage;
    }

    return "Something went wrong on our end. Please try again later.";
  }
}
