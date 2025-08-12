part of 'signup_cubit.dart';

enum SignupStatus { initial, loading, success, error }

class SignupState extends Equatable {
  final SignupStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final AutovalidateMode autovalidateMode;

  const SignupState({
    this.status = SignupStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  SignupState copyWith({
    SignupStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    AutovalidateMode? autovalidateMode,
  }) {
    return SignupState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isPasswordVisible, isConfirmPasswordVisible, autovalidateMode];
}
