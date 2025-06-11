import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../common_exercise/domain/entities/enums/exercise_type.dart';
import '../../../common_exercise/domain/entities/exercise_result.dart';
import '../../../common_exercise/domain/abstractions/exercise_trainer.dart';

abstract class ExerciseSessionState extends Equatable {
  const ExerciseSessionState();
  @override
  List<Object?> get props => [];
}

class ExerciseSessionInitial extends ExerciseSessionState {}

class ExerciseSessionLoadingModels extends ExerciseSessionState {
  final ExerciseType type;
  const ExerciseSessionLoadingModels(this.type);
  @override List<Object?> get props => [type];
}

class ExerciseSessionReady extends ExerciseSessionState {
  final ExerciseType type;
  final ExerciseTrainer trainer;
  final String instructions;
  const ExerciseSessionReady(this.type, this.trainer, this.instructions);
  @override List<Object?> get props => [type, trainer, instructions];
}

class ExerciseSessionInProgress extends ExerciseSessionState {
  final ExerciseType type;
  final ExerciseTrainer trainer;
  final ExerciseResult? lastResult;
  final List<Pose>? latestPosesForPainter;
  final Size? latestImageSizeForPainter;
  final InputImageRotation? latestRotationForPainter;

  const ExerciseSessionInProgress(
    this.type,
    this.trainer, {
    this.lastResult,
    this.latestPosesForPainter,
    this.latestImageSizeForPainter,
    this.latestRotationForPainter,
  });

  @override
  List<Object?> get props => [
        type,
        trainer,
        lastResult,
        latestPosesForPainter,
        latestImageSizeForPainter,
        latestRotationForPainter,
      ];
}

class ExerciseSessionError extends ExerciseSessionState {
  final String message;
  final String? errorDetails;
  
  const ExerciseSessionError({
    required this.message,
    this.errorDetails,
  });
}