import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_details.dart';
import '../repositories/user_repository.dart';

class GetCurrentUserDetailsUseCase implements UseCase<UserDetails, NoParams> {
  final UserRepository _repository;

  GetCurrentUserDetailsUseCase(this._repository);

  @override
  Future<Either<Failure, UserDetails>> call(NoParams params) async {
    return await _repository.getCurrentUserDetails();
  }
}