import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../core/utils/pose_processing_utils.dart';
import '../../../../common_exercise/domain/abstractions/body_tracker.dart';
import '../../../../common_exercise/domain/entities/enums/feedback_type.dart';
import '../../../../common_exercise/domain/entities/feedback_event.dart';
import '../../../../model_inference/services/feature_model_processor.dart';
import '../entities/glute_bridge_landmarks.dart';
import '../entities/glute_bridge_state.dart';
import '../entities/glute_bridge_tracker_result.dart';
import 'glute_bridge_feature_extractor.dart';

class GluteBridgeTracker extends BodyTracker {
  static const String _modelPath =
      'assets/models/glute_bridge/glute_bridge_model.onnx';
  static const int _downPoseClassIndex = 0;
  static const int _upPoseClassIndex = 1;

  static const double _correctHoldTimeGoal = 2.0;
  static const double _minHoldTimeForRep = 0.8;

  static double get correctHoldTimeGoal => _correctHoldTimeGoal;
  static double get minHoldTimeForRep => _minHoldTimeForRep;

  static const double _landmarkVisibilityThreshold = 0.3;
  static const double _stateChangeCooldown = 0.4;

  final GluteBridgeFeatureExtractor _featureExtractor;
  final FeatureModelProcessor _modelProcessor;

  GluteBridgeState state = GluteBridgeState.neutral;
  int _reps = 0;
  int get reps => _reps;

  FeedbackEvent _currentFeedbackEvent =
      FeedbackEvent(FeedbackType.setupInitialPrompt);

  bool _initialDownPoseForRepCycleAchieved = false;

  double _lastStateChangeTime = 0;
  double _upPoseStartTime = 0;
  double _currentHoldDuration = 0;
  double _maxHoldDurationThisSet = 0;
  double get maxHoldDurationThisSet => _maxHoldDurationThisSet;
  double get currentHoldDuration => _currentHoldDuration;

  static double _allTimeMaxHoldDuration = 0;
  static double get allTimeMaxHoldDuration => _allTimeMaxHoldDuration;

  GluteBridgeTracker()
      : _featureExtractor = GluteBridgeFeatureExtractor(),
        _modelProcessor = FeatureModelProcessor(modelPath: _modelPath),
        super('Glute Bridge Tracker');

  Future<void> initialize() async {
    await _modelProcessor.loadModel();
    _currentFeedbackEvent = FeedbackEvent(FeedbackType.setupInitialPrompt);
    log('Glute Bridge Tracker initialized: ${_modelProcessor.isReady}');
  }

  void resetActiveHold() {
    if (state == GluteBridgeState.up || state == GluteBridgeState.holding) {
      log("GluteBridgeTracker: Resetting active hold due to external interruption. Was state: $state, hold duration: ${_currentHoldDuration.toStringAsFixed(1)}s");
      _resetUpStateTracking(preserveMaxHoldThisSet: true);
      state = GluteBridgeState.neutral;
    }
    _initialDownPoseForRepCycleAchieved = false;
    log("GluteBridgeTracker: Active hold reset. Initial down pose flag reset.");
  }

  PoseLandmark? _getLandmark(Pose pose, PoseLandmarkType type) {
    return PoseProcessingUtils.getLandmark(
        pose, type, _landmarkVisibilityThreshold);
  }

  @override
  bool areLandmarksVisible(Pose pose) {
    final requiredForFeatures = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    int visibleCount = 0;
    for (var type in requiredForFeatures) {
      final landmark = pose.landmarks[type];
      if (landmark != null &&
          landmark.likelihood >= _landmarkVisibilityThreshold) {
        visibleCount++;
      }
    }
    return visibleCount >= 6;
  }

  GluteBridgeLandmarks _extractGluteBridgeLandmarks(Pose pose) {
    return GluteBridgeLandmarks(
      leftShoulder: _getLandmark(pose, PoseLandmarkType.leftShoulder),
      rightShoulder: _getLandmark(pose, PoseLandmarkType.rightShoulder),
      leftElbow: _getLandmark(pose, PoseLandmarkType.leftElbow),
      rightElbow: _getLandmark(pose, PoseLandmarkType.rightElbow),
      leftWrist: _getLandmark(pose, PoseLandmarkType.leftWrist),
      rightWrist: _getLandmark(pose, PoseLandmarkType.rightWrist),
      leftHip: _getLandmark(pose, PoseLandmarkType.leftHip),
      rightHip: _getLandmark(pose, PoseLandmarkType.rightHip),
      leftKnee: _getLandmark(pose, PoseLandmarkType.leftKnee),
      rightKnee: _getLandmark(pose, PoseLandmarkType.rightKnee),
      leftAnkle: _getLandmark(pose, PoseLandmarkType.leftAnkle),
      rightAnkle: _getLandmark(pose, PoseLandmarkType.rightAnkle),
      nose: _getLandmark(pose, PoseLandmarkType.nose),
      leftEye: _getLandmark(pose, PoseLandmarkType.leftEye),
      rightEye: _getLandmark(pose, PoseLandmarkType.rightEye),
    );
  }

  @override
  GluteBridgeTrackerResult processLandmarks(Pose pose, Size imageSize) {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    final extractedLandmarks = _extractGluteBridgeLandmarks(pose);

    _currentFeedbackEvent = FeedbackEvent(FeedbackType.neutralProcessing);

    final features =
        _featureExtractor.extractFeatures({'landmarks': extractedLandmarks});
    if (features.isEmpty || !_modelProcessor.isReady) {
      _currentFeedbackEvent = _modelProcessor.isReady
          ? FeedbackEvent(FeedbackType.exerciseFormUnclearAdjust)
          : FeedbackEvent(FeedbackType.errorModelNotReady);
      log('Feature extraction or model readiness issue. Event: ${_currentFeedbackEvent.type}');

      if (state == GluteBridgeState.up || state == GluteBridgeState.holding) {
        _resetUpStateTracking(preserveMaxHoldThisSet: true);
        state = GluteBridgeState.neutral;
      }

      return GluteBridgeTrackerResult(
          status: false,
          isVisible: true,
          feedbackEvent: _currentFeedbackEvent,
          currentPoseState: state,
          maxHoldDuration: _maxHoldDurationThisSet,
          holdProgress: 0.0);
    }

    final predictionResult = _modelProcessor.predict(features);
    if (!predictionResult.isValid || predictionResult.prediction == null) {
      String errorMsg =
          predictionResult.errorMessage ?? "Unknown prediction error";
      _currentFeedbackEvent = FeedbackEvent(FeedbackType.errorPredictionFailed,
          args: {'error': errorMsg});
      log('Prediction Error: $errorMsg');

      if (state == GluteBridgeState.up || state == GluteBridgeState.holding) {
        _resetUpStateTracking(preserveMaxHoldThisSet: true);
        state = GluteBridgeState.neutral;
      }

      return GluteBridgeTrackerResult(
          status: false,
          isVisible: true,
          feedbackEvent: _currentFeedbackEvent,
          currentPoseState: state,
          maxHoldDuration: _maxHoldDurationThisSet,
          holdProgress: 0.0);
    }

    int predictedClass = predictionResult.prediction!;
    _updateExerciseState(predictedClass, currentTime);

    return GluteBridgeTrackerResult(
      status: true,
      isVisible: true,
      currentPoseState: state,
      holdProgress:
          (state == GluteBridgeState.holding || state == GluteBridgeState.up) &&
                  _upPoseStartTime > 0
              ? (_currentHoldDuration / _correctHoldTimeGoal).clamp(0.0, 1.0)
              : 0.0,
      maxHoldDuration: _maxHoldDurationThisSet,
      feedbackEvent: _currentFeedbackEvent,
    );
  }

  void _updateExerciseState(int predictedClass, double currentTime) {
    final GluteBridgeState previousState = state;
    FeedbackEvent? exerciseFeedbackEvent;

    if (currentTime - _lastStateChangeTime < _stateChangeCooldown &&
        predictedClass != _getExpectedClassForState(state)) {}

    if (predictedClass == _downPoseClassIndex) {
      bool repAttemptCompleted = false;
      if (state == GluteBridgeState.up || state == GluteBridgeState.holding) {
        repAttemptCompleted = _upPoseStartTime > 0;

        if (_currentHoldDuration >= _minHoldTimeForRep) {
          _reps++;
          exerciseFeedbackEvent =
              FeedbackEvent(FeedbackType.exerciseLowerHipsGoodRep, args: {
            'reps_count': _reps.toString(),
            'duration_s': '${_currentHoldDuration.toStringAsFixed(1)}s'
          });
        } else if (repAttemptCompleted) {
          exerciseFeedbackEvent =
              FeedbackEvent(FeedbackType.exerciseLowerHipsShortHold, args: {
            'duration_s': '${_currentHoldDuration.toStringAsFixed(1)}s',
            'min_hold_s': '${_minHoldTimeForRep.toStringAsFixed(1)}s'
          });
        }
        _resetUpStateTracking(preserveMaxHoldThisSet: true);
        if (repAttemptCompleted) {
          _initialDownPoseForRepCycleAchieved = false;
        }
      }

      state = GluteBridgeState.down;
      _initialDownPoseForRepCycleAchieved = true;

      exerciseFeedbackEvent ??=
          FeedbackEvent(FeedbackType.exerciseDownPositionReady, args: {
        'is_first_time': _reps == 0 &&
            (previousState == GluteBridgeState.neutral ||
                previousState == GluteBridgeState.down),
      });

      if (previousState == GluteBridgeState.neutral && !repAttemptCompleted) {
        _resetUpStateTracking(preserveMaxHoldThisSet: true);
      }
    } else if (predictedClass == _upPoseClassIndex) {
      if (_initialDownPoseForRepCycleAchieved &&
          (state == GluteBridgeState.down ||
              state == GluteBridgeState.neutral)) {
        state = GluteBridgeState.up;
        _upPoseStartTime = currentTime;
        _currentHoldDuration = 0;
        exerciseFeedbackEvent = FeedbackEvent(FeedbackType.exerciseLiftHips);
      } else if (state == GluteBridgeState.up ||
          state == GluteBridgeState.holding) {
        if (_upPoseStartTime == 0) {
          log("Error: In UP/HOLDING state but _upPoseStartTime is 0. Resetting state to neutral.");
          _resetUpStateTracking(preserveMaxHoldThisSet: true);
          state = GluteBridgeState.neutral;
          _initialDownPoseForRepCycleAchieved = false;
          exerciseFeedbackEvent =
              FeedbackEvent(FeedbackType.exerciseStartFromDownPosition);
        } else {
          _currentHoldDuration = currentTime - _upPoseStartTime;
          if (_currentHoldDuration > _maxHoldDurationThisSet) {
            _maxHoldDurationThisSet = _currentHoldDuration;
            if (_maxHoldDurationThisSet > _allTimeMaxHoldDuration) {
              _allTimeMaxHoldDuration = _maxHoldDurationThisSet;
            }
          }
          if (_currentHoldDuration >= _correctHoldTimeGoal) {
            state = GluteBridgeState.holding;
            exerciseFeedbackEvent = FeedbackEvent(
                FeedbackType.exerciseHoldingUpGoodDuration,
                args: {
                  'duration_s': '${_currentHoldDuration.toStringAsFixed(1)}s'
                });
          } else {
            state = GluteBridgeState.up;
            exerciseFeedbackEvent =
                FeedbackEvent(FeedbackType.exerciseHoldingUp, args: {
              'duration_s': '${_currentHoldDuration.toStringAsFixed(1)}s'
            });
          }
        }
      } else {
        exerciseFeedbackEvent =
            FeedbackEvent(FeedbackType.exerciseStartFromDownPosition);
        if (state == GluteBridgeState.up || state == GluteBridgeState.holding) {
          _resetUpStateTracking(preserveMaxHoldThisSet: true);
          state = GluteBridgeState.neutral;
        }
      }
    } else {
      FeedbackType unclearType = FeedbackType.exerciseFormUnclearAdjust;
      if (state == GluteBridgeState.up || state == GluteBridgeState.holding) {
        unclearType = FeedbackType.exerciseFormUnclearWasUp;
        _resetUpStateTracking(preserveMaxHoldThisSet: true);
      } else if (state == GluteBridgeState.down) {
        unclearType = FeedbackType.exerciseFormUnclearWasDown;
      }
      exerciseFeedbackEvent = FeedbackEvent(unclearType);
      state = GluteBridgeState.neutral;
    }

    _currentFeedbackEvent = exerciseFeedbackEvent;

    if (state != previousState ||
        ((state == GluteBridgeState.up || state == GluteBridgeState.holding) &&
            _upPoseStartTime > 0 &&
            previousState == state)) {
      log("Glute Bridge State: $previousState -> $state (InitialDownDone: $_initialDownPoseForRepCycleAchieved), Reps: $_reps, Hold: ${_currentHoldDuration.toStringAsFixed(1)}s, Event: ${_currentFeedbackEvent.type} (Args: ${_currentFeedbackEvent.args})");
    }
  }

  int _getExpectedClassForState(GluteBridgeState currentState) {
    switch (currentState) {
      case GluteBridgeState.up:
      case GluteBridgeState.holding:
        return _upPoseClassIndex;
      case GluteBridgeState.down:
        return _downPoseClassIndex;
      default:
        return -1;
    }
  }

  void _resetUpStateTracking({bool preserveMaxHoldThisSet = false}) {
    _upPoseStartTime = 0;
    _currentHoldDuration = 0;
    if (!preserveMaxHoldThisSet) {
      _maxHoldDurationThisSet = 0;
    }
  }

  @override
  void reset() {
    _reps = 0;
    state = GluteBridgeState.neutral;
    _currentFeedbackEvent = FeedbackEvent(FeedbackType.infoTrackerReset);
    _initialDownPoseForRepCycleAchieved = false;

    _lastStateChangeTime = 0;
    _resetUpStateTracking(preserveMaxHoldThisSet: false);
    _featureExtractor.reset();

    log("GluteBridgeTracker reset. Reps and current set max hold cleared. All-time max: $_allTimeMaxHoldDuration");
  }
}
