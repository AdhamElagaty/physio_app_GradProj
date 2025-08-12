import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../domain/usecases/request_password_reset/request_password_reset_usecase.dart';
import '../../../domain/usecases/resend_email_confirmation/resend_email_confirmation_params.dart';

part 'request_password_reset_state.dart';

class RequestPasswordResetCubit extends Cubit<RequestPasswordResetState> {
  final RequestPasswordResetUseCase _useCase;
  final ErrorHandlerService _errorHandler;
  RequestPasswordResetCubit(this._useCase, this._errorHandler) : super(const RequestPasswordResetState());

  Future<void> requestReset(String email) async {
    emit(state.copyWith(status: RequestResetStatus.loading));
    final result = await _useCase(EmailParams(email: email));
    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(status: RequestResetStatus.error, errorMessage: friendlyMessage));
      },
      (_) => emit(state.copyWith(status: RequestResetStatus.success)),
    );
  }

   void setAutovalidateMode() {
    emit(state.copyWith(autovalidateMode: AutovalidateMode.onUserInteraction));
  }
}
