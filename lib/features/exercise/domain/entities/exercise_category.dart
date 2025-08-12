import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ExerciseCategory extends Equatable {
  static const String favoritesId = 'favorites';
  
  final String id;
  final String title;
  final String subTitle;
  final String? localFallbackIconAsset;
  final String? iconUrl;
  final Color? iconColor;

  const ExerciseCategory({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.localFallbackIconAsset,
    required this.iconUrl,
    this.iconColor,
  });

  @override
  List<Object?> get props => [id, title, subTitle, iconUrl, iconColor];
}