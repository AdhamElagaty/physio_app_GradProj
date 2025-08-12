import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';
import '../confirm_email/confirm_email_params.dart';

class ConfirmPasswordResetUseCase implements UseCase<String, ConfirmCodeParams> {
  final AuthRepository _repository;
  ConfirmPasswordResetUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(ConfirmCodeParams params) async {
    return await _repository.confirmPasswordReset(params.email, params.code);
  }
}
