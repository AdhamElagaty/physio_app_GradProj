import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/login_result.dart';
import '../../repositories/auth_repository.dart';
import 'login_params.dart';


class LoginUseCase implements UseCase<LoginResult, LoginParams> {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, LoginResult>> call(LoginParams params) async {
    return await _repository.login(
      emailOrUsername: params.emailOrUsername,
      password: params.password,
    );
  }
}
