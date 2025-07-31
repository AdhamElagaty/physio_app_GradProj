part of 'exercise_category_cubit.dart';

// ++ ENHANCED ++: Sentinel object for advanced copyWith functionality.
const Object _sentinel = Object();

enum ExerciseCategoryStatus { initial, loading, loaded, error }

class ExerciseCategoryState extends Equatable {
  final ExerciseCategoryStatus status;
  final List<ExerciseCategory> categories;
  final bool isOffline;
  final String? errorMessage;

  const ExerciseCategoryState({
    this.status = ExerciseCategoryStatus.initial,
    this.categories = const [],
    this.isOffline = false,
    this.errorMessage,
  });

  // ++ ENHANCED ++: More robust copyWith that allows explicitly setting fields to null.
  ExerciseCategoryState copyWith({
    ExerciseCategoryStatus? status,
    List<ExerciseCategory>? categories,
    bool? isOffline,
    dynamic errorMessage = _sentinel,
  }) {
    return ExerciseCategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}