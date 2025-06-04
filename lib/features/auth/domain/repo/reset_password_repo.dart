import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';

abstract class ResetPasswordRepository {
  Future<Either<FailureExceptions, Unit>> requestResetPassword(String email);
  Future<Either<FailureExceptions, String>> confirmOtp(
      {required String email, required String otp});
  Future<Either<FailureExceptions, Unit>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  });
}
