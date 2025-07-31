import '../../domain/detection/core/entities/enums/exercise_trainer_type.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_type.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.modelKey,
    required super.exerciseTrainerType,
    required super.title,
    required super.subTitle,
    required super.description,
    required super.exerciseType,
    super.localFallbackIconAsset,
    super.iconUrl,
    super.localFallbackImageAsset,
    super.imageUrl,
    required super.isFavorite,
    required super.categoryTitle,
    required super.isActive,
  });

  factory ExerciseModel.fromRemoteJson(Map<String, dynamic> json, {
    required String localModelKey,
    required String localCategoryTitle,
    required String localIconAsset,
    required String localImageAsset,
    required bool localIsActive,
  }) {
    return ExerciseModel(
      id: json['id'],
      modelKey: localModelKey,
      exerciseTrainerType: ExerciseTrainerType.getExerciseTypeFromModelKey(localModelKey),
      title: json['title'],
      subTitle: json['subTitle'],
      description: json['description'],
      exerciseType: ExerciseType.fromString(json['exerciseType']),
      iconUrl: json['iconUrl'] ?? localIconAsset,
      imageUrl: json['imageUrl'] ?? localImageAsset,
      isFavorite: json['isFavorite'] ,
      categoryTitle: localCategoryTitle,
      isActive: localIsActive,
    );
  }

  factory ExerciseModel.fromLocalJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['ModelKey'],
      modelKey: json['ModelKey'],
      exerciseTrainerType: ExerciseTrainerType.getExerciseTypeFromModelKey(json['ModelKey']),
      title: json['Title'],
      subTitle: json['SubTitle'],
      description: json['Description'],
      exerciseType: ExerciseType.fromString(json['ExerciseType']),
      localFallbackIconAsset: json['IconAsset'], 
      localFallbackImageAsset: json['ImageAsset'],
      isFavorite: false,
      categoryTitle: json['CategorTitle'],
      isActive: (json['IsActive'] as String).toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'Title': title,
      'SubTitle': subTitle,
      'ModelKey': modelKey,
      'Description': description,
      'IconAsset': localFallbackIconAsset,
      'ImageAsset': localFallbackImageAsset,
      'ExerciseType': exerciseType == ExerciseType.repCount ? 'RepCount' : 'DurationHoldWithRepCount',
      'CategorTitle': categoryTitle,
      'IsActive': isActive.toString(),
    };
  }
}
