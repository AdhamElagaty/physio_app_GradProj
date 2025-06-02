import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';
import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';
import 'package:gradproject/features/auth/domain/repo/auth_repo.dart';

class SignUpUseCase {
  AuthRepo repo;

  SignUpUseCase(this.repo);

  Future<Either<FailureExceptions, UserModel>> call(
          SignUpEntity signUpEntity) =>
      repo.signUp(signUpEntity);
}
