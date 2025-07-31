part of 'request_password_reset_cubit.dart';

enum RequestResetStatus { initial, loading, success, error }

class RequestPasswordResetState extends Equatable {
  final RequestResetStatus status;
  final String? errorMessage;
  final AutovalidateMode autovalidateMode;

  const RequestPasswordResetState({
    this.status = RequestResetStatus.initial, 
    this.errorMessage,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  RequestPasswordResetState copyWith({
    RequestResetStatus? status, 
    String? errorMessage,
    AutovalidateMode? autovalidateMode,
  }) {
    return RequestPasswordResetState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
    );
  }
  
  @override
  List<Object?> get props => [status, errorMessage, autovalidateMode];
}
