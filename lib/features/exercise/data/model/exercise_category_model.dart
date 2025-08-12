import 'package:flutter/material.dart';
import '../../domain/entities/exercise_category.dart';

class ExerciseCategoryModel extends ExerciseCategory {
  const ExerciseCategoryModel({
    required super.id,
    required super.title,
    required super.subTitle,
    super.localFallbackIconAsset,
    super.iconUrl,
    super.iconColor,
  });

  factory ExerciseCategoryModel.fromRemoteJson(Map<String, dynamic> json) {
    return ExerciseCategoryModel(
      id: json['id'],
      title: json['title'],
      subTitle: json['subTitle'],
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  factory ExerciseCategoryModel.fromLocalJson(Map<String, dynamic> json) {
    return ExerciseCategoryModel(
      id: json['Title'],
      title: json['Title'],
      subTitle: json['SubTitle'],
      localFallbackIconAsset: json['IconAsset'],
      iconColor: Color(int.parse(json['IconColor'])),
    );
  }
  
  Map<String, dynamic> toLocalJson() {
      return {
          'Title': title,
          'SubTitle': subTitle,
          'IconAsset': localFallbackIconAsset,
          'IconColor': '0x${iconColor?.toARGB32().toRadixString(16).padLeft(8, '0')}',
      };
  }
}
