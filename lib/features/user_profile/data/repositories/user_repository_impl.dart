import 'package:dartz/dartz.dart';

import '../../../../core/error/error_context.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/user_details.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl extends BaseRepository implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource, NetworkInfo networkInfo) : super(networkInfo);

  @override
  Future<Either<Failure, UserDetails>> getCurrentUserDetails() {
    return handleRequest(() => _remoteDataSource.getCurrentUserDetails(), context: ErrorContext.userGetCurrentUserDetails);
  }
}
