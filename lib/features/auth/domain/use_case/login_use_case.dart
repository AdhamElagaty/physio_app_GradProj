import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/domain/repo/auth_repo.dart';

class LoginUseCase {
  AuthRepo repo;

  LoginUseCase(this.repo);

  Future<Either<FailureExceptions, bool>> call(String email, String password) =>
      repo.signIn(email, password);
}
