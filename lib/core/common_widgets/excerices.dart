import 'dart:ui';

import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/features/common_exercise/domain/entities/enums/exercise_type.dart';

class Exercise {
  final String name;
  final String subtitle;
  final String description;
  final String category;
  final String iconPath;
  final Color iconColor;
  bool isFavorite;
  final ExerciseType type;
  final String gifPath;

  Exercise({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.iconPath,
    required this.iconColor,
    this.isFavorite = false,
    required this.type,
    required this.gifPath,
  });
}

final List<Exercise> allExercises = [
  Exercise(
      name: 'Bicep Curls',
      subtitle: 'Classic arm builder',
      description:
          'Bicep curls are a classic strength training exercise that targets the biceps brachii muscle. It involves flexing the elbow to bring the weight towards the shoulder.',
      category: 'arms',
      iconPath: AppIcons.biceps,
      iconColor: AppColors.green,
      isFavorite: true,
      gifPath: 'assets/gif/bicep_curl_image.gif',
      type: ExerciseType.bicepCurl),
  Exercise(
      name: 'Glute Bridges',
      subtitle: 'Targets glutes and hamstrings',
      description:
          'The glute bridge is a simple yet effective exercise for strengthening the glutes and hamstrings. Lie on your back with knees bent, feet flat, and lift your hips off the ground.',
      category: 'lower body',
      iconPath: AppIcons.glute_bridge,
      iconColor: AppColors.purple,
      isFavorite: true,
      gifPath: 'assets/gif/glute_bridge_image.gif',
      type: ExerciseType.gluteBridge),
  // Exercise(
  //     name: 'Push-ups',
  //     subtitle: 'Full body classic',
  //     description:
  //         'A fundamental bodyweight exercise that works the chest, shoulders, triceps, and core. Start in a plank position and lower your body until your chest nearly touches the floor.',
  //     category: 'core strength',
  //     iconPath: AppIcons.heart,
  //     iconColor: AppColors.yellow,
  //     isFavorite: true),
  // Exercise(
  //   name: 'Squats',
  //   subtitle: 'Leg and glute power',
  //   description:
  //       'A full-body exercise that primarily works the glutes, quadriceps, and hamstrings. Lower your hips as if sitting back into an imaginary chair.',
  //   category: 'lower body',
  //   iconPath: AppIcons.heart,
  //   iconColor: AppColors.purple,
  // ),
  Exercise(
      name: 'Plank',
      subtitle: 'Core stability',
      description:
          'The plank is an isometric core strength exercise that involves maintaining a position similar to a push-up for the maximum possible time. It strengthens the abdominals, back, and shoulders.',
      category: 'core strength',
      iconPath: AppIcons.plank,
      iconColor: AppColors.yellow,
      isFavorite: true,
      gifPath: 'assets/gif/plank_image.gif',
      type: ExerciseType.plank),
];
