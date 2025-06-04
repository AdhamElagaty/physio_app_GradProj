import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/domain/repo/reset_password_repo.dart';

class RequestResetPasswordUseCase {
  final ResetPasswordRepository repository;

  RequestResetPasswordUseCase(this.repository);

  Future<Either<FailureExceptions, Unit>> call(String email) {
    return repository.requestResetPassword(email);
  }
}

class ConfirmOtpUseCase {
  final ResetPasswordRepository repository;

  ConfirmOtpUseCase(this.repository);

  Future<Either<FailureExceptions, String>> call(
      {required String email, required String otp}) {
    return repository.confirmOtp(email: email, otp: otp);
  }
}

class ResetPasswordUseCase {
  final ResetPasswordRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<FailureExceptions, Unit>> call({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) {
    return repository.resetPassword(
      email: email,
      token: token,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
