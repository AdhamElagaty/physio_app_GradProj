import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../domain/usecases/confirm_email/confirm_email_params.dart';
import '../../../domain/usecases/confirm_email/confirm_email_usecase.dart';
import '../../../domain/usecases/confirm_password_reset/confirm_password_reset_usecase.dart';
import '../../../domain/usecases/confirm_two_factor/confirm_two_factor_usecase.dart';
import '../../../domain/usecases/request_password_reset/request_password_reset_usecase.dart';
import '../../../domain/usecases/resend_email_confirmation/resend_email_confirmation_params.dart';
import '../../../domain/usecases/resend_email_confirmation/resend_email_confirmation_usecase.dart';
import '../../models/otp_verification_type.dart';

part 'otp_verification_state.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  final ConfirmEmailUseCase _confirmEmailUseCase;
  final ConfirmTwoFactorUseCase _confirmTwoFactorUseCase;
  final ConfirmPasswordResetUseCase _confirmPasswordResetUseCase;
  final ResendEmailConfirmationUseCase _resendEmailConfirmationUseCase;
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  final ErrorHandlerService _errorHandler;

  Timer? _timer;
  static const int _cooldownDuration = 60;

  OtpVerificationCubit(
    this._confirmEmailUseCase,
    this._confirmTwoFactorUseCase,
    this._confirmPasswordResetUseCase,
    this._resendEmailConfirmationUseCase,
    this._requestPasswordResetUseCase,
    this._errorHandler,
  ) : super(const OtpVerificationState());

  void initializeTimer() {
    // Only start the timer if it hasn't been started already.
    if (state.resendCooldownSeconds == null) {
      _startResendTimer();
    }
  }
  
  // NEW METHOD to reset the error/success state after animations.
  void resetVerificationStatus() {
    if (state.status == OtpStatus.verificationFailure || state.status == OtpStatus.verificationSuccess) {
      emit(state.copyWith(status: OtpStatus.initial, errorMessage: null, resetToken: null));
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    emit(state.copyWith(resendCooldownSeconds: _cooldownDuration));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentCooldown = state.resendCooldownSeconds ?? 0;
      if (currentCooldown > 0) {
        emit(state.copyWith(resendCooldownSeconds: currentCooldown - 1));
      } else {
        _timer?.cancel();
        emit(state.copyWith(resendCooldownSeconds: 0));
      }
    });
  }

  Future<void> verifyOtp({
    required String otp,
    required String email,
    required OtpVerificationType verificationType,
  }) async {
    // Prevent multiple verification requests
    if (state.status.isLoading) return;

    emit(state.copyWith(status: OtpStatus.loading, errorMessage: null, resetToken: null));
    
    dynamic result;
    switch (verificationType) {
      case OtpVerificationType.passwordReset:
        result = await _confirmPasswordResetUseCase(ConfirmCodeParams(email: email, code: otp));
        break;
      case OtpVerificationType.twoFactorAuthentication:
        result = await _confirmTwoFactorUseCase(ConfirmCodeParams(email: email, code: otp));
        break;
      case OtpVerificationType.emailConfirmation:
        result = await _confirmEmailUseCase(ConfirmCodeParams(email: email, code: otp));
        break;
    }

    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(status: OtpStatus.verificationFailure, errorMessage: friendlyMessage));
      },
      (successData) {
        final token = verificationType == OtpVerificationType.passwordReset ? successData as String : null;
        emit(state.copyWith(status: OtpStatus.verificationSuccess, resetToken: token));
      },
    );
  }

  Future<void> resendOtp({
    required String email,
    required OtpVerificationType verificationType,
  }) async {
    if ((state.resendCooldownSeconds ?? 0) > 0 || state.status.isLoading) return;

    emit(state.copyWith(status: OtpStatus.resendLoading, errorMessage: null));

    dynamic result;
    switch (verificationType) {
      case OtpVerificationType.passwordReset:
        result = await _requestPasswordResetUseCase(EmailParams(email: email));
        break;
      case OtpVerificationType.emailConfirmation:
        result = await _resendEmailConfirmationUseCase(EmailParams(email: email));
        break;
      default:
        emit(state.copyWith(status: OtpStatus.resendFailure, errorMessage: 'Resend not applicable for this action.'));
        return;
    }

    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(status: OtpStatus.resendFailure, errorMessage: friendlyMessage));
      },
      (_) {
        emit(state.copyWith(status: OtpStatus.resendSuccess));
        _startResendTimer();
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
