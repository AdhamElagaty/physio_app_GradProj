import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../domain/entities/login_result.dart';
import '../../../domain/usecases/login/login_params.dart';
import '../../../domain/usecases/login/login_usecase.dart';
import '../../../domain/usecases/resend_email_confirmation/resend_email_confirmation_params.dart';
import '../../../domain/usecases/resend_email_confirmation/resend_email_confirmation_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final ResendEmailConfirmationUseCase _resendEmailConfirmationUseCase;
  final ErrorHandlerService _errorHandler;

  LoginCubit(
    this._loginUseCase, 
    this._resendEmailConfirmationUseCase,
    this._errorHandler
    ) : super(const LoginState());

  Future<void> login(String emailOrUsername, String password) async {
    emit(state.copyWith(status: LoginStatus.loading));
    final result = await _loginUseCase(LoginParams(emailOrUsername: emailOrUsername, password: password));

    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(status: LoginStatus.error, errorMessage: friendlyMessage));
      },
      (loginResult) async {
        switch (loginResult) {
          case LoginSuccess():
            emit(state.copyWith(status: LoginStatus.success));
          case LoginRequires2FA():
            emit(state.copyWith(status: LoginStatus.requires2FA, emailForNextStep: loginResult.email));
          case LoginRequiresEmailConfirmation():
            final sendResult = await _resendEmailConfirmationUseCase(EmailParams(email: loginResult.emailOrUserName));
            sendResult.fold(
              (failure) => emit(state.copyWith(status: LoginStatus.error, errorMessage: failure.message)),
              (_) => emit(state.copyWith(status: LoginStatus.requiresEmailConfirmation, emailForNextStep: loginResult.emailOrUserName)),
            );
        }
      },
    );
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void setAutovalidateMode() {
    emit(state.copyWith(autovalidateMode: AutovalidateMode.onUserInteraction));
  }
}
