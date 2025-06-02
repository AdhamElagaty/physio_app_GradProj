import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';
import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';

abstract class AuthRepo {
  Future<Either<FailureExceptions, bool>> signIn(String email, String password);
  Future<Either<FailureExceptions, UserModel>> signUp(
      SignUpEntity signUpEntity);
}
