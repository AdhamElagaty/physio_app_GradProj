import 'package:equatable/equatable.dart';

class GetExerciseHistoriesParams extends Equatable {
  final int pageIndex;
  final int pageSize;
  final String? searchExercise;
  final List<String>? searchCategoriesTitle;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool? isUserFavorite;

  const GetExerciseHistoriesParams({
    required this.pageIndex,
    this.pageSize = 12,
    this.searchExercise,
    this.searchCategoriesTitle,
    this.dateFrom,
    this.dateTo,
    this.isUserFavorite,
  });

  @override
  List<Object?> get props => [
        pageIndex,
        pageSize,
        searchExercise,
        searchCategoriesTitle,
        dateFrom,
        dateTo,
        isUserFavorite
      ];
}