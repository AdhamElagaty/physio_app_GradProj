import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_category.dart';
import '../../../domain/usecases/add_exercise_favorite/add_exercise_favorite_usecase.dart';
import '../../../domain/usecases/get_exercises/get_exercises_params.dart';
import '../../../domain/usecases/get_exercises/get_exercises_usecase.dart';
import '../../../domain/usecases/remove_exercise_favorite/remove_exercise_favorite_usecase.dart';

part 'exercise_filter_state.dart';

class ExerciseFilterCubit extends Cubit<ExerciseFilterState> {
  final GetExercisesUseCase _getExercisesUseCase;
  final AddExerciseFavoriteUseCase _addExerciseFavoriteUseCase;
  final RemoveExerciseFavoriteUseCase _removeExerciseFavoriteUseCase;
  final ErrorHandlerService _errorHandler;

  int _page = 1;
  Timer? _debounce;
  bool _isOffline = false;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  ExerciseFilterCubit({
    required GetExercisesUseCase getExercisesUseCase,
    required AddExerciseFavoriteUseCase addExerciseFavoriteUseCase,
    required RemoveExerciseFavoriteUseCase removeExerciseFavoriteUseCase,
    required ErrorHandlerService errorHandler,
  })  : _getExercisesUseCase = getExercisesUseCase,
        _addExerciseFavoriteUseCase = addExerciseFavoriteUseCase,
        _removeExerciseFavoriteUseCase = removeExerciseFavoriteUseCase,
        _errorHandler = errorHandler,
        super(const ExerciseFilterState()) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchNextPage();
    }
  }

  Future<void> initialize({
    required List<String> allCategories,
    String? initialCategory,
    bool autoSearch = false,
    required bool isOffline,
  }) async {
    _isOffline = isOffline;
    emit(state.copyWith(status: ExerciseFilterStatus.loading, isOffline: isOffline));

    final initialFilters =
        initialCategory != null ? {initialCategory.toLowerCase()} : <String>{};

    final newState = state.copyWith(
      allCategories: allCategories,
      activeFilters: initialFilters,
    );

    if(isClosed) return;

    emit(_getStateWithSortedDisplayCategories(newState));

    if (autoSearch && searchController.text.isEmpty && initialFilters.isEmpty) {
      emit(state.copyWith(status: ExerciseFilterStatus.empty, exercises: []));
    } else {
      fetchFirstPage();
    }
  }
  
  void updateExternalDependencies({
    required List<String> newAllCategories,
    required bool isOffline,
  }) {
    if (_isOffline == isOffline && newAllCategories == state.allCategories) return;
    
    _isOffline = isOffline;
    final currentFilters = Set<String>.from(state.activeFilters);
    if (isOffline) {
      currentFilters.remove(ExerciseCategory.favoritesId);
    }

    final newState = state.copyWith(
      allCategories: newAllCategories,
      activeFilters: currentFilters,
      isOffline: isOffline,
    );

    if(isClosed) return;
    
    emit(_getStateWithSortedDisplayCategories(newState));
    fetchFirstPage();
  }

  ExerciseFilterState _getStateWithSortedDisplayCategories(ExerciseFilterState currentState) {
    final allUniqueCategories = {ExerciseCategory.favoritesId, ...currentState.allCategories.map((e) => e.toLowerCase())};
    if (_isOffline) {
      allUniqueCategories.remove(ExerciseCategory.favoritesId);
    }
    
    final sortedDisplayCategories = <String>{
      ...currentState.activeFilters.where((f) => f == ExerciseCategory.favoritesId),
      ...currentState.activeFilters.where((f) => f != ExerciseCategory.favoritesId && allUniqueCategories.contains(f)),
      ...allUniqueCategories.where((c) => !currentState.activeFilters.contains(c)),
    }.toList();

    return currentState.copyWith(displayCategories: sortedDisplayCategories);
  }
  
  void onSearchChanged(String searchTerm) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchFirstPage();
    });
  }

  void toggleFilter(String category) {
    final lowerCaseCategory = category.toLowerCase();
    final currentFilters = Set<String>.from(state.activeFilters);

    if (currentFilters.contains(lowerCaseCategory)) {
      currentFilters.remove(lowerCaseCategory);
    } else {
      currentFilters.add(lowerCaseCategory);
    }
    
    if(isClosed) return;
    final newState = state.copyWith(activeFilters: currentFilters);
    emit(_getStateWithSortedDisplayCategories(newState));
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    _page = 1;
    emit(state.copyWith(
      status: ExerciseFilterStatus.loading,
      hasNextPage: true,
      errorMessage: null,
    ));
    await _fetchExercises();
  }

  Future<void> refresh() async {
    await fetchFirstPage();
  }

  Future<void> fetchNextPage() async {
    // ++ ENHANCED ++: Allow retrying a failed pagination attempt.
    if (state.status == ExerciseFilterStatus.loading ||
        state.status == ExerciseFilterStatus.loadingMore ||
        (!state.hasNextPage && state.status != ExerciseFilterStatus.loadingMoreError)) {
      return;
    }
    if(isClosed) return;
    // ++ ENHANCED ++: Clear previous error on retry.
    emit(state.copyWith(status: ExerciseFilterStatus.loadingMore, errorMessage: null));
    _page++;
    await _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final filters = Set<String>.from(state.activeFilters);
    // ++ ENHANCED ++: Using constant
    final isFavoriteFilter = filters.remove(ExerciseCategory.favoritesId);

    final result = await _getExercisesUseCase(GetExercisesParams(
      pageIndex: _page,
      searchExercise: searchController.text,
      isUserFavorite: isFavoriteFilter,
      searchCategoriesTitle: filters.isNotEmpty ? filters.toList() : null,
    ));

    if(isClosed) return;

    result.fold(
      (failure) {
        final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
        if (_page > 1) {
          emit(state.copyWith(
              status: ExerciseFilterStatus.loadingMoreError,
              hasNextPage: false,
              errorMessage: friendlyMessage,
          ));
        } else if (failure is NotFoundFailure && _page > 1) {
            emit(state.copyWith(
              hasNextPage: false, status: ExerciseFilterStatus.loaded));
        } else {
          emit(state.copyWith(
            status: ExerciseFilterStatus.error,
            errorMessage: friendlyMessage,
          ));
        }
      },
      (paginatedResult) {
        final currentExercises = (_page > 1) ? state.exercises : <Exercise>[];
        final newExercises = [...currentExercises, ...paginatedResult.items];
        final newState = state.copyWith(
          status: newExercises.isEmpty
              ? ExerciseFilterStatus.empty
              : ExerciseFilterStatus.loaded,
          exercises: newExercises,
          hasNextPage: paginatedResult.hasNextPage,
        );
        emit(_getStateWithSortedDisplayCategories(newState));
      },
    );
  }

  Future<void> toggleFavorite(String exerciseId) async {
    final originalExercises = List<Exercise>.from(state.exercises);
    final exerciseIndex = originalExercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = originalExercises[exerciseIndex];
    final isFavorited = exercise.isFavorite;

    final updatedExercise = exercise.copyWith(isFavorite: !isFavorited);
    originalExercises[exerciseIndex] = updatedExercise;
    emit(state.copyWith(exercises: originalExercises));

    final result = isFavorited
        ? await _removeExerciseFavoriteUseCase(exerciseId)
        : await _addExerciseFavoriteUseCase(exerciseId);

    if(isClosed) return;

    result.fold((failure) {
      final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
      final revertedExercises = List<Exercise>.from(state.exercises);
      revertedExercises[exerciseIndex] = exercise;
      emit(state.copyWith(
        exercises: revertedExercises,
        errorMessage: friendlyMessage,
      ));
      if (state.activeFilters.contains(ExerciseCategory.favoritesId)) {
        fetchFirstPage();
      }
    }, (_) {
      if (state.activeFilters.contains(ExerciseCategory.favoritesId)) {
        fetchFirstPage();
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    return super.close();
  }
}
