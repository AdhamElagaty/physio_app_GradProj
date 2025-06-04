abstract class RequestResetPasswordState {}

class RequestResetPasswordInitial extends RequestResetPasswordState {}

class RequestResetPasswordLoading extends RequestResetPasswordState {}

class RequestResetPasswordSuccess extends RequestResetPasswordState {}

class RequestResetPasswordError extends RequestResetPasswordState {
  final String message;
  RequestResetPasswordError(this.message);
}
