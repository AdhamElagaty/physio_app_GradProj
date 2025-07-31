import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';
import 'confirm_email_params.dart';

class ConfirmEmailUseCase implements UseCase<AuthUser, ConfirmCodeParams> {
  final AuthRepository _repository;
  ConfirmEmailUseCase(this._repository);

  @override
  Future<Either<Failure, AuthUser>> call(ConfirmCodeParams params) async {
    return await _repository.confirmEmail(email: params.email, code: params.code);
  }
}
