import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';
import 'resend_email_confirmation_params.dart';

class ResendEmailConfirmationUseCase implements UseCase<void, EmailParams> {
  final AuthRepository _repository;
  ResendEmailConfirmationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(EmailParams params) async {
    return await _repository.resendEmailConfirmationCode(email: params.email);
  }
}
