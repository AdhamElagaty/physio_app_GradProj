import 'package:dartz/dartz.dart';

import '../../../../core/error/error_context.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_category.dart';
import '../../../exercise_history/domain/entities/paginated_exercise_histories_result.dart';
import '../../domain/entities/paginated_exercises_result.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/usecases/add_exercise_history/add_exercise_history_params.dart';
import '../../../exercise_history/domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../../domain/usecases/get_exercises/get_exercises_params.dart';
import '../datasources/exercise_local_data_source/exercise_local_data_source.dart';
import '../datasources/exercise_remote_data_source/exercise_remote_data_source.dart';
import '../model/add_exercise_history_request_model.dart';
import '../model/exercise_category_model.dart';
import '../model/exercise_model.dart';
import '../model/paginated_exercises_response_model.dart';

class ExerciseRepositoryImpl extends BaseRepository
    implements ExerciseRepository {
  final ExerciseRemoteDataSource _remoteDataSource;
  final ExerciseLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ExerciseRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  ) : super(_networkInfo);

  @override
  Future<Either<Failure, PaginatedExercisesResult>> getExercises(
      GetExercisesParams params) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteFutureResult = handleRequest(
            () => _remoteDataSource.getExercises(params),
            context: ErrorContext.exerciseGetExercises);
        final localFuture = _localDataSource.getExercises();
        final results = await Future.wait([remoteFutureResult, localFuture]);

        final remoteResponse =
            results[0] as Either<Failure, PaginatedExercisesResponseModel>;
        final localExercises = results[1] as List<ExerciseModel>;

        return remoteResponse.fold(
          (failure) => Left(failure),
          (remoteResponse) {
            final activeLocalExercises =
                localExercises.where((e) => e.isActive).toList();

            final filteredRemoteExercises =
                remoteResponse.exercises.where((remote) {
              return activeLocalExercises
                  .any((local) => local.modelKey == remote.modelKey);
            }).toList();

            final List<Exercise> mergedExercises = [];
            final List<ExerciseModel> exercisesToCache = [];

            for (var localEx in localExercises) {
              bool isInRemote = false;

              final remoteMatch = filteredRemoteExercises.firstWhere(
                (remoteEx) {
                  isInRemote = remoteEx.modelKey == localEx.modelKey;
                  return isInRemote;
                },
                orElse: () => localEx,
              );

              final updatedExercise = ExerciseModel(
                id: remoteMatch.id,
                modelKey: localEx.modelKey,
                exerciseTrainerType: localEx.exerciseTrainerType,
                title: remoteMatch.title,
                subTitle: remoteMatch.subTitle,
                description: remoteMatch.description,
                exerciseType: remoteMatch.exerciseType,
                localFallbackIconAsset: localEx.localFallbackIconAsset,
                iconUrl: remoteMatch.iconUrl,
                localFallbackImageAsset: localEx.localFallbackImageAsset,
                imageUrl: remoteMatch.imageUrl,
                isFavorite: remoteMatch.isFavorite,
                categoryTitle: localEx.categoryTitle,
                isActive: localEx.isActive,
              );

              exercisesToCache.add(updatedExercise);

              if (remoteMatch.isActive && isInRemote) {
                mergedExercises.add(updatedExercise);
              }
            }

            _localDataSource.cacheExercises(exercisesToCache);

            return Right(
              PaginatedExercisesResult(
                items: mergedExercises,
                hasNextPage: remoteResponse.hasNextPage,
              ),
            );
          },
        );
      } catch (e) {
        return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}',
              ErrorContext.exerciseGetExercises),
        );
      }
    } else {
      try {
        final localExercises = await _localDataSource.getExercises();
        var filtered = localExercises.where((e) => e.isActive).toList();

        if (params.searchExercise != null &&
            params.searchExercise!.isNotEmpty) {
          final searchTerm = params.searchExercise!.toLowerCase();
          filtered = filtered
              .where((e) =>
                  e.title.toLowerCase().contains(searchTerm) ||
                  e.subTitle.toLowerCase().contains(searchTerm) ||
                  e.description.toLowerCase().contains(searchTerm))
              .toList();
        }

        if (params.searchCategoriesTitle != null &&
            params.searchCategoriesTitle!.isNotEmpty) {
          filtered = filtered
              .where((e) => params.searchCategoriesTitle!
                  .contains(e.categoryTitle.toLowerCase()))
              .toList();
        }

        final int startIndex =
            ((params.pageIndex - 1) * params.pageSize).toInt();
        final int endIndex = (startIndex + params.pageSize).toInt();
        final paginatedItems = filtered.sublist(startIndex,
            endIndex > filtered.length ? filtered.length : endIndex);

        return Right(
          PaginatedExercisesResult(
            items: paginatedItems,
            hasNextPage: endIndex < filtered.length,
          ),
        );
      } catch (e) {
        return Left(CacheFailure('Could not load cached exercises.'));
      }
    }
  }

  @override
  Future<Either<Failure, List<ExerciseCategory>>>
      getExerciseCategories() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteFutureResult = handleRequest(
            () => _remoteDataSource.getExerciseCategories(),
            context: ErrorContext.exerciseGetExerciseCategories);
        final localFuture = _localDataSource.getCategories();

        final results = await Future.wait([remoteFutureResult, localFuture]);

        final remoteCategories =
            results[0] as Either<Failure, List<ExerciseCategoryModel>>;
        final localCategories = results[1] as List<ExerciseCategoryModel>;

        return remoteCategories.fold((failure) => left(failure),
            (remoteCategories) {
          final mergedCategories = remoteCategories.map((remote) {
            final localMatch = localCategories.firstWhere(
              (local) => local.title == remote.title,
              orElse: () => remote,
            );
            return ExerciseCategoryModel(
              id: remote.id,
              title: remote.title,
              subTitle: remote.subTitle,
              localFallbackIconAsset: localMatch.localFallbackIconAsset,
              iconUrl: remote.iconUrl,
              iconColor: localMatch.iconColor,
            );
          }).toList();

          _localDataSource.cacheCategories(mergedCategories);
          return Right(mergedCategories);
        });
      } catch (e) {
        return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}',
              ErrorContext.exerciseGetExerciseCategories),
        );
      }
    } else {
      try {
        final localCategories = await _localDataSource.getCategories();
        return Right(localCategories);
      } catch (e) {
        return Left(CacheFailure('Could not load cached categories.'));
      }
    }
  }

  @override
  Future<Either<Failure, PaginatedExerciseHistoriesResult>>
      getExerciseHistories(GetExerciseHistoriesParams params) {
    return handleRequest(() async {
      final response = await _remoteDataSource.getExerciseHistories(params);
      return PaginatedExerciseHistoriesResult(
          items: response.histories, hasNextPage: response.hasNextPage);
    }, context: ErrorContext.exerciseGetExerciseHistory);
  }

  @override
  Future<Either<Failure, void>> addExerciseHistory(
      AddExerciseHistoryParams params) {
    return handleRequest(() async {
      final requestModel = AddExerciseHistoryRequestModel.fromParams(params);
      await _remoteDataSource.addExerciseHistory(requestModel);
    }, context: ErrorContext.exerciseAddExerciseHistory);
  }

  @override
  Future<Either<Failure, void>> addExerciseFavorite(String exerciseId) {
    return handleRequest(
        () => _remoteDataSource.addExerciseFavorite(exerciseId),
        context: ErrorContext.exerciseAddExerciseFavorite);
  }

  @override
  Future<Either<Failure, void>> removeExerciseFavorite(String exerciseId) {
    return handleRequest(
        () => _remoteDataSource.removeExerciseFavorite(exerciseId),
        context: ErrorContext.exerciseRemoveExerciseFavorite);
  }
}
