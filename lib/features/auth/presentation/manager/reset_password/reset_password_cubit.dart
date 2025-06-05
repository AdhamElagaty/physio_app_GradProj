import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/features/auth/domain/use_case/reset_passord_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordUseCase resetPasswordUseCase;

  ResetPasswordCubit(this.resetPasswordUseCase) : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    emit(ResetPasswordLoading());

    final result = await resetPasswordUseCase(
      email: email,
      token: token,
      password: password,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) {
        emit(ResetPasswordError(failure.message));
      },
      (_) {
        emit(ResetPasswordSuccess());
      },
    );
  }
}
