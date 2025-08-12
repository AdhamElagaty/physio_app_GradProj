import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/login_result.dart';
import '../../repositories/auth_repository.dart';

class RefreshSessionUseCase implements UseCase<LoginSuccess, NoParams> {
  final AuthRepository repository;

  RefreshSessionUseCase(this.repository);

  @override
  Future<Either<Failure, LoginSuccess>> call(NoParams params) async {
    return await repository.refreshSession();
  }
}
