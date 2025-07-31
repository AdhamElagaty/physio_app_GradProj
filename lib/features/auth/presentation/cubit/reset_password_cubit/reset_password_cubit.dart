import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../domain/usecases/reset_password/reset_password_params.dart';
import '../../../domain/usecases/reset_password/reset_password_usecase.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordUseCase _useCase;
  final ErrorHandlerService _errorHandler;

  ResetPasswordCubit(this._useCase, this._errorHandler) : super(const ResetPasswordState());

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: ResetPasswordStatus.loading));
    final params = ResetPasswordParams(email: email, token: token, newPassword: newPassword);
    final result = await _useCase(params);
    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(status: ResetPasswordStatus.error, errorMessage: friendlyMessage));
      },
      (_) => emit(state.copyWith(status: ResetPasswordStatus.success)),
    );
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  void setAutovalidateMode() {
    emit(state.copyWith(autovalidateMode: AutovalidateMode.onUserInteraction));
  }
}
