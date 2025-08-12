import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../core/services/pose_detection_service/data/exceptions/pose_detection_exception.dart';
import '../../../domain/detection/exercises/bicep_curl/logic/bicep_curl_trainer.dart';
import '../../../domain/detection/core/abstractions/exercise_trainer.dart';
import '../../../domain/detection/core/entities/enums/exercise_trainer_type.dart';
import '../../../domain/detection/exercises/glute_bridge/logic/glute_bridge_trainer.dart';
import '../../../../../core/services/pose_detection_service/pose_detection_service.dart';
import '../../../domain/detection/exercises/plank/logic/plank_trainer.dart';
import 'exercise_session_state.dart';

class ExerciseSessionCubit extends Cubit<ExerciseSessionState> {
  final PoseDetectionService poseDetectionService;
  ExerciseTrainer? currentTrainer;

  ExerciseSessionCubit(this.poseDetectionService)
      : super(ExerciseSessionInitial());

  Future<void> selectExercise(ExerciseTrainerType type) async {
    emit(ExerciseSessionLoadingModels(type));
    try {
      currentTrainer?.reset();

      switch (type) {
        case ExerciseTrainerType.bicepCurl:
          currentTrainer = BicepCurlTrainer();
          break;
        case ExerciseTrainerType.gluteBridge:
          currentTrainer = GluteBridgeTrainer();
          break;
        case ExerciseTrainerType.plank:
          currentTrainer = PlankTrainer();
      }
      await currentTrainer!.loadModels();
      emit(ExerciseSessionReady(
          type, currentTrainer!, ""));
    } catch (e) {
      emit(ExerciseSessionError(
          message: "Failed to load exercise models: ${e.toString()}"));
    }
  }

  void startExercise() {
    if (state is ExerciseSessionReady) {
      final readyState = state as ExerciseSessionReady;
      currentTrainer?.reset();
      emit(ExerciseSessionInProgress(readyState.type, readyState.trainer));
    }
  }

  void processFrameData({
    required List<Pose> poses,
    required Size imageSize,
    required InputImageRotation imageRotation,
    required bool isFrontCamera,
  }) {
    if (state is ExerciseSessionInProgress && currentTrainer != null) {
      final currentProgressState = state as ExerciseSessionInProgress;
      final result = currentTrainer!.processFrame(poses, imageSize);
      emit(ExerciseSessionInProgress(
        currentProgressState.type,
        currentTrainer!,
        lastResult: result,
        latestPosesForPainter: poses,
        latestImageSizeForPainter: imageSize,
        latestRotationForPainter: imageRotation,
      ));
    }
  }

  void handleProcessingError(PoseDetectionException exception) {
    if (isClosed) return;
    emit(ExerciseSessionError(
      message: exception.message,
      errorDetails: exception.cause?.toString(),
    ));
  }

  void stopExercise() {
    if (state is ExerciseSessionInProgress) {
      final currentProgressState = state as ExerciseSessionInProgress;
      emit(ExerciseSessionReady(
          currentProgressState.type,
          currentProgressState.trainer, ""));
    }
  }

  void resetExercise() {
    if (currentTrainer != null) {
      currentTrainer!.reset();
      if (state is ExerciseSessionInProgress) {
        final currentProgressState = state as ExerciseSessionInProgress;
        emit(ExerciseSessionInProgress(
            currentProgressState.type, currentTrainer!,
            lastResult: null)); // Clear last result
      } else if (state is ExerciseSessionReady) {
        final readyState = state as ExerciseSessionReady;
        emit(ExerciseSessionReady(
            readyState.type, currentTrainer!, readyState.instructions));
      }
    }
  }

  @override
  Future<void> close() async {
    currentTrainer?.reset();
    await poseDetectionService.dispose();
    return super.close();
  }
}
