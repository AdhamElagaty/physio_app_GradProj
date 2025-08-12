part of 'exercise_filter_cubit.dart';

const Object _sentinel = Object();

enum ExerciseFilterStatus { initial, loading, loadingMore, loaded, empty, error, loadingMoreError }

class ExerciseFilterState extends Equatable {
  final ExerciseFilterStatus status;
  final List<Exercise> exercises;
  final Set<String> activeFilters;
  final List<String> allCategories;
  final List<String> displayCategories;
  final bool hasNextPage;
  final bool isOffline;
  final String? errorMessage;

  const ExerciseFilterState({
    this.status = ExerciseFilterStatus.initial,
    this.exercises = const [],
    this.activeFilters = const {},
    this.allCategories = const [],
    this.displayCategories = const [],
    this.hasNextPage = true,
    this.isOffline = true,
    this.errorMessage,
  });

  ExerciseFilterState copyWith({
    ExerciseFilterStatus? status,
    List<Exercise>? exercises,
    Set<String>? activeFilters,
    List<String>? allCategories,
    List<String>? displayCategories,
    bool? hasNextPage,
    bool? isOffline,
    dynamic errorMessage = _sentinel,
  }) {
    return ExerciseFilterState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      activeFilters: activeFilters ?? this.activeFilters,
      allCategories: allCategories ?? this.allCategories,
      displayCategories: displayCategories ?? this.displayCategories,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exercises,
        activeFilters,
        allCategories,
        displayCategories,
        hasNextPage,
        isOffline,
        errorMessage,
      ];
}
