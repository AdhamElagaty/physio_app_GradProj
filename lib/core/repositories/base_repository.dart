import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../error/error_context.dart';

abstract class BaseRepository {
  final NetworkInfo _networkInfo;

  BaseRepository(this._networkInfo);

  Future<Either<Failure, T>> handleRequest<T>(Future<T> Function() request, {required ErrorContext context}) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No Internet Connection. Please check your network and try again.'));
    }
    try {
      final result = await request();
      return Right(result);
    } on DioException catch (e) {
      final exception = e.error;
      if (exception is UnauthorizedException) {
        return Left(UnauthorizedFailure(exception.message, context));
      }
      if (exception is NotFoundException) {
        return Left(NotFoundFailure(exception.message, context));
      }
      if (exception is ServerException) {
        return Left(ServerFailure(exception.message, context));
      }
      return Left(ServerFailure(e.message ?? 'An unexpected network error occurred.', context));
    } on CacheException {
      return Left(CacheFailure('A local data handling error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}', context));
    }
  }
}
