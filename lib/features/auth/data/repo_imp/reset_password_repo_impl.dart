import 'package:dartz/dartz.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/data/data_source/reset_password_ds.dart';
import 'package:gradproject/features/auth/domain/repo/reset_password_repo.dart';

class AuthRepositoryImpl implements ResetPasswordRepository {
  final ResetPaasswordRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<FailureExceptions, Unit>> requestResetPassword(
      String email) async {
    try {
      await remoteDataSource.requestResetPassword(email);
      return right(unit);
    } catch (e) {
      return left(FailuerRemoteException(e.toString()));
    }
  }

  @override
  Future<Either<FailureExceptions, String>> confirmOtp(
      {required String email, required String otp}) async {
    try {
      final token = await remoteDataSource.confirmOtp(email: email, otp: otp);
      return right(token);
    } catch (e) {
      return left(FailuerRemoteException(e.toString()));
    }
  }

  @override
  Future<Either<FailureExceptions, Unit>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
          email, token, password, confirmPassword);
      return right(unit);
    } catch (e) {
      return left(FailuerRemoteException(e.toString()));
    }
  }
}
