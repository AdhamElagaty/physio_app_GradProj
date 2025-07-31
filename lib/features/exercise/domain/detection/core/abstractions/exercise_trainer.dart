import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../presentation/widgets/shared/painters/base_exercise_painter.dart';
import '../entities/exercise_result.dart';

abstract class ExerciseTrainer{
  final String name;
  
  ExerciseTrainer(this.name);
  
  Future<void> loadModels();
  
  ExerciseResult processFrame(List<Pose> poses, Size imageSize);

  BaseExercisePainter getPainter(List<Pose> poses, Size absoluteImageSize, InputImageRotation rotation, bool isFrontCamera);

  void reset();
}