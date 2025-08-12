import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/utils/styles/app_colors.dart';
import '../../../../../core/utils/styles/app_assets.dart';
import '../../../domain/entities/exercise_category.dart';
import '../../../domain/usecases/get_exercise_categories/get_exercise_categories_usecase.dart';

part 'exercise_category_state.dart';

class ExerciseCategoryCubit extends Cubit<ExerciseCategoryState> {
  final GetExerciseCategoriesUseCase _getExerciseCategoriesUseCase;
  final ErrorHandlerService _errorHandler;

  ExerciseCategoryCubit({
    required GetExerciseCategoriesUseCase getExerciseCategoriesUseCase,
    required ErrorHandlerService errorHandler,
  })  : _getExerciseCategoriesUseCase = getExerciseCategoriesUseCase,
        _errorHandler = errorHandler,
        super(const ExerciseCategoryState());

  Future<void> getCategories({bool forceRefresh = false, required bool isOffline}) async {
    if (state.status == ExerciseCategoryStatus.loading || (state.status == ExerciseCategoryStatus.loaded && !forceRefresh)) {
      return;
    }

    emit(state.copyWith(status: ExerciseCategoryStatus.loading, errorMessage: null, isOffline: isOffline));

    final result = await _getExerciseCategoriesUseCase(NoParams());

    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        emit(state.copyWith(
          status: ExerciseCategoryStatus.error,
          errorMessage: friendlyMessage,
        ));
      },
      (categories) {
        final List<ExerciseCategory> displayCategories = [];

        if (!isOffline) {
          displayCategories.add(
            ExerciseCategory(
              id: ExerciseCategory.favoritesId,
              title: 'Favorites',
              subTitle: 'All your favorite exercises',
              iconColor: AppColors.red,
              localFallbackIconAsset: AppAssets.iconly.bold.heart,
              iconUrl: '',
            ),
          );
        }

        displayCategories.addAll(categories);
        
        emit(state.copyWith(
          status: ExerciseCategoryStatus.loaded,
          categories: displayCategories,
        ));
      },
    );
  }
}