import 'package:equatable/equatable.dart';

class GetExercisesParams extends Equatable {
  final int pageIndex;
  final int pageSize;
  final String? searchExercise;
  final List<String>? searchCategoriesTitle;
  final bool? isUserFavorite;

  const GetExercisesParams({
    required this.pageIndex,
    this.pageSize = 12,
    this.searchExercise,
    this.searchCategoriesTitle,
    this.isUserFavorite,
  });

  @override
  List<Object?> get props => [
        pageIndex,
        pageSize,
        searchExercise,
        searchCategoriesTitle,
        isUserFavorite
      ];
}