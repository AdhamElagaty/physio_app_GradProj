import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_user.dart';
import '../entities/login_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> confirmEmail({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> resendEmailConfirmationCode({
    required String email,
  });

  Future<Either<Failure, LoginResult>> login({
    required String emailOrUsername,
    required String password,
  });

  Future<Either<Failure, AuthUser>> confirmTwoFactorCode({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> requestPasswordReset(String email);

  Future<Either<Failure, String>> confirmPasswordReset(
      String email, String code);

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, LoginSuccess>> refreshSession();

  Future<Either<Failure, void>> logout();
}
