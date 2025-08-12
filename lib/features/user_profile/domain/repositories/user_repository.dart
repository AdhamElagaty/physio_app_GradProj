import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_details.dart';

abstract class UserRepository {
  Future<Either<Failure, UserDetails>> getCurrentUserDetails();
}
