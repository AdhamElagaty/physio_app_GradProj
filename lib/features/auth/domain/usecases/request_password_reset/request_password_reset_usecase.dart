import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';
import '../resend_email_confirmation/resend_email_confirmation_params.dart';

class RequestPasswordResetUseCase implements UseCase<void, EmailParams> {
  final AuthRepository _repository;
  RequestPasswordResetUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(EmailParams params) async {
    return await _repository.requestPasswordReset(params.email);
  }
}
