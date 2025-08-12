import '../../domain/entities/exercise_history.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../exercise/data/model/exercise_model.dart';

class ExerciseHistoryModel extends ExerciseHistory {
  const ExerciseHistoryModel({
    required super.exercise,
    required super.date,
    required super.repsCount,
    super.maxHoldDuration,
  });

  factory ExerciseHistoryModel.fromJson(Map<String, dynamic> json) {
    final exerciseJson = {
      'id': json['id'],
      'modelKey': json['modelKey'],
      'title': json['title'],
      'subTitle': json['subTitle'],
      'description': json['description'],
      'exerciseType': json['exerciseType'],
      'iconURL': json['iconURL'],
      'imageURL': json['imageURL'],
      'isFavorite': json['isFavorite'],
    };

    final exerciseModel = ExerciseModel.fromRemoteJson(exerciseJson, 
        localModelKey: exerciseJson['modelKey'],
        localCategoryTitle: '',
        localIconAsset: '',
        localImageAsset: '',
        localIsActive: true
    );
    
    return ExerciseHistoryModel(
      exercise: exerciseModel,
      date: DateUtils.parseBackendDate(json['createdAt']),
      repsCount: json['repsCount'],
      maxHoldDuration: (json['maxHoldDuration'] as num?)?.toDouble(),
    );
  }
}
