import 'package:equatable/equatable.dart';

import '../detection/core/entities/enums/exercise_trainer_type.dart';
import 'exercise_type.dart';

class Exercise extends Equatable {
  final String id;
  final String modelKey;
  final ExerciseTrainerType? exerciseTrainerType;
  final String title;
  final String subTitle;
  final String description;
  final ExerciseType exerciseType;
  final String? localFallbackIconAsset;
  final String? iconUrl;
  final String? localFallbackImageAsset;
  final String? imageUrl;
  final bool isFavorite;
  final String categoryTitle;
  final bool isActive;

  const Exercise({
    required this.id,
    required this.modelKey,
    required this.exerciseTrainerType,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.exerciseType,
    required this.localFallbackIconAsset,
    required this.iconUrl,
    required this.localFallbackImageAsset,
    required this.imageUrl,
    required this.isFavorite,
    required this.categoryTitle,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        modelKey,
        title,
        subTitle,
        description,
        exerciseType,
        iconUrl,
        imageUrl,
        isFavorite,
        categoryTitle,
        isActive,
      ];

      copyWith({
        String? id,
        String? modelKey,
        ExerciseTrainerType? exerciseTrainerType,
        String? title,
        String? subTitle,
        String? description,
        ExerciseType? exerciseType,
        String? localFallbackIconAsset,
        String? iconUrl,
        String? localFallbackImageAsset,
        String? imageUrl,
        bool? isFavorite,
        String? categoryTitle,
        bool? isActive,
      }) {
        return Exercise(
          id: id ?? this.id,
          modelKey: modelKey ?? this.modelKey,
          exerciseTrainerType: exerciseTrainerType ?? this.exerciseTrainerType,
          title: title ?? this.title,
          subTitle: subTitle ?? this.subTitle,
          description: description ?? this.description,
          exerciseType: exerciseType ?? this.exerciseType,
          localFallbackIconAsset: localFallbackIconAsset ?? this.localFallbackIconAsset,
          iconUrl: iconUrl ?? this.iconUrl,
          localFallbackImageAsset: localFallbackImageAsset ?? this.localFallbackImageAsset,
          imageUrl: imageUrl ?? this.imageUrl,
          isFavorite: isFavorite ?? this.isFavorite,
          categoryTitle: categoryTitle ?? this.categoryTitle,
          isActive: isActive ?? this.isActive,
        );
      }
}