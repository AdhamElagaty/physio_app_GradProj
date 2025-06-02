import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/data/data_source/auth_remote_ds.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';
import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';
import 'package:gradproject/features/auth/domain/repo/auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  AuthRemoteDataSource auth;
  AuthRepoImp(
    this.auth,
  );
  @override
  Future<Either<FailureExceptions, bool>> signIn(
      String email, String password) async {
    try {
      bool loggedIn = await auth.signIn(email, password);
      return Right(loggedIn);
    } catch (e) {
      return Left(FailuerRemoteException(e.toString()));
    }
  }

  @override
  Future<Either<FailureExceptions, UserModel>> signUp(
      SignUpEntity signUpEntity) async {
    try {
      UserModel user = await auth.signUp(signUpEntity);
      return Right(user);
    } catch (e) {
      return left(FailuerRemoteException(e.toString()));
    }
  }
}
