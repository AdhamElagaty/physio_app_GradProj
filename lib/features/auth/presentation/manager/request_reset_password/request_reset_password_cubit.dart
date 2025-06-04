import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/features/auth/domain/use_case/reset_passord_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/request_reset_password/request_reset_password_state.dart';

class RequestResetPasswordCubit extends Cubit<RequestResetPasswordState> {
  final RequestResetPasswordUseCase requestResetPasswordUseCase;

  RequestResetPasswordCubit(this.requestResetPasswordUseCase)
      : super(RequestResetPasswordInitial());

  Future<void> requestResetPassword(String email) async {
    emit(RequestResetPasswordLoading());

    final result = await requestResetPasswordUseCase(email);

    result.fold(
      (failure) => emit(RequestResetPasswordError('failed')),
      (_) => emit(RequestResetPasswordSuccess()),
    );
  }
}
