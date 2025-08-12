part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, error, requires2FA, requiresEmailConfirmation }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final String? emailForNextStep;
  final bool isPasswordVisible;
  final AutovalidateMode autovalidateMode;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.emailForNextStep,
    this.isPasswordVisible = false,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? emailForNextStep,
    bool? isPasswordVisible,
    AutovalidateMode? autovalidateMode,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      emailForNextStep: emailForNextStep ?? this.emailForNextStep,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, emailForNextStep, isPasswordVisible, autovalidateMode];
}
