import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';
import '../confirm_email/confirm_email_params.dart';

class ConfirmTwoFactorUseCase implements UseCase<AuthUser, ConfirmCodeParams> {
  final AuthRepository _repository;
  ConfirmTwoFactorUseCase(this._repository);

  @override
  Future<Either<Failure, AuthUser>> call(ConfirmCodeParams params) async {
    return await _repository.confirmTwoFactorCode(email: params.email, code: params.code);
  }
}
