import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../domain/usecases/register/register_params.dart';
import '../../../domain/usecases/register/register_usecase.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final RegisterUseCase _registerUseCase;
  final ErrorHandlerService _errorHandler;
  SignupCubit(this._registerUseCase, this._errorHandler) : super(const SignupState());

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: SignupStatus.loading));
    final params = RegisterParams(firstName: firstName, lastName: lastName, email: email, password: password);
    final result = await _registerUseCase(params);

    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(status: SignupStatus.error, errorMessage: friendlyMessage));
      },
      (_) => emit(state.copyWith(status: SignupStatus.success)),
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
