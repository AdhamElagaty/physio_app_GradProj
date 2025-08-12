part of 'otp_verification_cubit.dart';

enum OtpStatus { initial, loading, verificationSuccess, verificationFailure, resendLoading, resendSuccess, resendFailure }

extension OtpStatusX on OtpStatus {
  bool get isLoading => this == OtpStatus.loading || this == OtpStatus.resendLoading;
}

class OtpVerificationState extends Equatable {
  final OtpStatus status;
  final String? errorMessage;
  final String? resetToken;
  final int? resendCooldownSeconds;

  const OtpVerificationState({
    this.status = OtpStatus.initial,
    this.errorMessage,
    this.resetToken,
    this.resendCooldownSeconds,
  });

  OtpVerificationState copyWith({
    OtpStatus? status,
    String? errorMessage,
    String? resetToken,
    int? resendCooldownSeconds,
  }) {
    return OtpVerificationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      resetToken: resetToken ?? this.resetToken,
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, resetToken, resendCooldownSeconds];
}