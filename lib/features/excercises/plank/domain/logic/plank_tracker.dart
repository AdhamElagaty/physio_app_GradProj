import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../core/utils/pose_processing_utils.dart';
import '../../../../common_exercise/domain/abstractions/body_tracker.dart';
import '../../../../common_exercise/domain/entities/enums/feedback_type.dart';
import '../../../../common_exercise/domain/entities/feedback_event.dart';
import '../../../../model_inference/services/feature_model_processor.dart';
import '../entities/plank_landmarks.dart';
import '../entities/plank_state.dart';
import '../entities/plank_tracker_result.dart';
import 'plank_feature_extractor.dart';

class PlankTracker extends BodyTracker {
  static const String _modelPath = 'assets/models/plank/plank_model.onnx';
  static const int _correctPlankClassIndex = 0;
  static const int _highHipsClassIndex = 1;
  static const int _lowHipsClassIndex = 2;

  static const double _correctHoldTimeGoal = 5.0;
  static const double _minHoldDurationForRep = 3.0;

  static double get correctHoldTimeGoal => _correctHoldTimeGoal;
  static double get minHoldDurationForRep => _minHoldDurationForRep;

  static const double _landmarkVisibilityThreshold = 0.4;
  static const double _stateChangeCooldown = 0.5;

  final PlankFeatureExtractor _featureExtractor;
  final FeatureModelProcessor _modelProcessor;

  PlankState state = PlankState.neutral;
  int _successfulHoldsCount = 0;
  int get successfulHoldsCount => _successfulHoldsCount;

  FeedbackEvent _currentFeedbackEvent =
      FeedbackEvent(FeedbackType.plankSetupInitialPrompt);

  bool _repAlreadyCountedThisHold = false;

  double _lastStateChangeTime = 0;
  double _correctPoseStartTime = 0;
  double _currentCorrectHoldDuration = 0;
  double _maxHoldDurationThisSet = 0;

  double get currentCorrectHoldDuration => _currentCorrectHoldDuration;
  double get maxHoldDurationThisSet => _maxHoldDurationThisSet;

  static double _allTimeMaxHoldDuration = 0;
  static double get allTimeMaxHoldDuration => _allTimeMaxHoldDuration;

  PlankTracker()
      : _featureExtractor = PlankFeatureExtractor(),
        _modelProcessor = FeatureModelProcessor(modelPath: _modelPath),
        super('Plank Tracker');

  Future<void> initialize() async {
    await _modelProcessor.loadModel();
    _currentFeedbackEvent = FeedbackEvent(FeedbackType.plankSetupInitialPrompt);
    log('Plank Tracker initialized: ${_modelProcessor.isReady}');
  }

  void interruptHold() {
    if (state == PlankState.correct) {
      log("PlankTracker: Hold interrupted. Was state: $state, hold duration: ${_currentCorrectHoldDuration.toStringAsFixed(1)}s");
      _resetCorrectHoldTiming(preserveMaxHoldThisSet: true);
      state = PlankState.neutral;
      _currentFeedbackEvent = FeedbackEvent(FeedbackType.plankFormIssueGeneric);
    }
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
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
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
    return visibleCount >= 8;
  }

  PlankLandmarks _extractPlankLandmarks(Pose pose) {
    return PlankLandmarks(
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
    );
  }

  @override
  PlankTrackerResult processLandmarks(Pose pose, Size imageSize) {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final extractedLandmarks = _extractPlankLandmarks(pose);

    _currentFeedbackEvent = FeedbackEvent(FeedbackType.neutralProcessing);

    final features =
        _featureExtractor.extractFeatures({'landmarks': extractedLandmarks});
    if (features.isEmpty || !_modelProcessor.isReady) {
      _currentFeedbackEvent = _modelProcessor.isReady
          ? FeedbackEvent(FeedbackType.plankFormIssueGeneric)
          : FeedbackEvent(FeedbackType.errorModelNotReady);
      log('PlankTracker: Feature extraction or model readiness issue. Event: ${_currentFeedbackEvent.type}');

      if (state == PlankState.correct) {
        _resetCorrectHoldTiming(preserveMaxHoldThisSet: true);
        state = PlankState.adjusting;
      }

      return PlankTrackerResult(
          status: false,
          isVisible: true,
          feedbackEvent: _currentFeedbackEvent,
          currentPoseState: state,
          maxHoldDurationThisSet: _maxHoldDurationThisSet,
          currentHoldDuration: _currentCorrectHoldDuration,
          holdProgress: 0.0);
    }

    final predictionResult = _modelProcessor.predict(features);
    if (!predictionResult.isValid || predictionResult.prediction == null) {
      String errorMsg =
          predictionResult.errorMessage ?? "Unknown prediction error";
      _currentFeedbackEvent = FeedbackEvent(FeedbackType.errorPredictionFailed,
          args: {'error': errorMsg});
      log('PlankTracker: Prediction Error: $errorMsg');

      if (state == PlankState.correct) {
        _resetCorrectHoldTiming(preserveMaxHoldThisSet: true);
        state = PlankState.adjusting;
      }

      return PlankTrackerResult(
          status: false,
          isVisible: true,
          feedbackEvent: _currentFeedbackEvent,
          currentPoseState: state,
          maxHoldDurationThisSet: _maxHoldDurationThisSet,
          currentHoldDuration: _currentCorrectHoldDuration,
          holdProgress: 0.0);
    }

    int predictedClass = predictionResult.prediction!;
    _updateExerciseState(predictedClass, currentTime);

    double holdProgressValue = 0.0;
    if (state == PlankState.correct && _correctPoseStartTime > 0) {
      holdProgressValue =
          (_currentCorrectHoldDuration / _correctHoldTimeGoal).clamp(0.0, 1.0);
    }

    return PlankTrackerResult(
      status: true,
      isVisible: true,
      currentPoseState: state,
      currentHoldDuration: _currentCorrectHoldDuration,
      holdProgress: holdProgressValue,
      maxHoldDurationThisSet: _maxHoldDurationThisSet,
      feedbackEvent: _currentFeedbackEvent,
    );
  }

  void _updateExerciseState(int predictedClass, double currentTime) {
    final PlankState previousState = state;
    FeedbackEvent? eventForThisUpdate;

    if (state != PlankState.neutral &&
        state != PlankState.adjusting &&
        predictedClass != _getExpectedClassForState(state) &&
        currentTime - _lastStateChangeTime < _stateChangeCooldown) {
      if (_currentFeedbackEvent.type == FeedbackType.neutralProcessing &&
          previousState != PlankState.neutral) {
        _currentFeedbackEvent =
            _getFeedbackForState(previousState, _currentCorrectHoldDuration);
      }
      return;
    }

    PlankState newState = state;

    if (predictedClass == _correctPlankClassIndex) {
      newState = PlankState.correct;
      if (previousState != PlankState.correct) {
        _correctPoseStartTime = currentTime;
        _currentCorrectHoldDuration = 0;
        _repAlreadyCountedThisHold = false;
        eventForThisUpdate = FeedbackEvent(FeedbackType.plankCorrectForm);
      } else {
        _currentCorrectHoldDuration = currentTime - _correctPoseStartTime;
        if (_currentCorrectHoldDuration > _maxHoldDurationThisSet) {
          _maxHoldDurationThisSet = _currentCorrectHoldDuration;
          if (_maxHoldDurationThisSet > _allTimeMaxHoldDuration) {
            _allTimeMaxHoldDuration = _maxHoldDurationThisSet;
          }
        }
        eventForThisUpdate = FeedbackEvent(FeedbackType.plankHoldingCorrectly,
            args: {
              'duration_s': _currentCorrectHoldDuration.toStringAsFixed(1)
            });

        if (_currentCorrectHoldDuration >= _minHoldDurationForRep &&
            !_repAlreadyCountedThisHold) {
          _successfulHoldsCount++;
          _repAlreadyCountedThisHold = true;
        }
      }
    } else if (predictedClass == _highHipsClassIndex) {
      newState = PlankState.highHips;
      eventForThisUpdate = FeedbackEvent(FeedbackType.plankHighHips);
      if (previousState == PlankState.correct)
        _resetCorrectHoldTiming(preserveMaxHoldThisSet: true);
    } else if (predictedClass == _lowHipsClassIndex) {
      newState = PlankState.lowHips;
      eventForThisUpdate = FeedbackEvent(FeedbackType.plankLowHips);
      if (previousState == PlankState.correct)
        _resetCorrectHoldTiming(preserveMaxHoldThisSet: true);
    } else {
      newState = PlankState.adjusting;
      eventForThisUpdate = FeedbackEvent(FeedbackType.plankFormIssueGeneric);
      if (previousState == PlankState.correct)
        _resetCorrectHoldTiming(preserveMaxHoldThisSet: true);
      log("PlankTracker: Prediction $predictedClass led to adjusting state.");
    }

    if (newState != previousState) {
      state = newState;
      _lastStateChangeTime = currentTime;
      log("Plank State: $previousState -> $state, Hold: ${_currentCorrectHoldDuration.toStringAsFixed(1)}s, MaxSetHold: ${_maxHoldDurationThisSet.toStringAsFixed(1)}s, Event: ${eventForThisUpdate.type}");

      _currentFeedbackEvent = eventForThisUpdate;
    } else {
      _currentFeedbackEvent = eventForThisUpdate;
    }
  }

  FeedbackEvent _getFeedbackForState(
      PlankState currentState, double holdDuration) {
    switch (currentState) {
      case PlankState.correct:
        return FeedbackEvent(FeedbackType.plankHoldingCorrectly,
            args: {'duration_s': holdDuration.toStringAsFixed(1)});
      case PlankState.highHips:
        return FeedbackEvent(FeedbackType.plankHighHips);
      case PlankState.lowHips:
        return FeedbackEvent(FeedbackType.plankLowHips);
      case PlankState.notPlanking:
        return FeedbackEvent(FeedbackType.plankSetupInitialPrompt);
      case PlankState.adjusting:
        return FeedbackEvent(FeedbackType.plankAdjustingForm);
      case PlankState.neutral:
        return FeedbackEvent(FeedbackType.neutralProcessing);
    }
  }

  int _getExpectedClassForState(PlankState currentTrackerState) {
    switch (currentTrackerState) {
      case PlankState.correct:
        return _correctPlankClassIndex;
      case PlankState.highHips:
        return _highHipsClassIndex;
      case PlankState.lowHips:
        return _lowHipsClassIndex;
      case PlankState.notPlanking:
      case PlankState.adjusting:
      case PlankState.neutral:
        return -1;
    }
  }

  void _resetCorrectHoldTiming({bool preserveMaxHoldThisSet = false}) {
    _correctPoseStartTime = 0;
    _currentCorrectHoldDuration = 0;
    _repAlreadyCountedThisHold = false;
    if (!preserveMaxHoldThisSet) {
      _maxHoldDurationThisSet = 0;
    }
  }

  @override
  void reset() {
    _successfulHoldsCount = 0;
    state = PlankState.neutral;
    _currentFeedbackEvent = FeedbackEvent(FeedbackType.infoTrackerReset);

    _lastStateChangeTime = 0;
    _resetCorrectHoldTiming(preserveMaxHoldThisSet: false);
    _featureExtractor.reset();

    log("PlankTracker reset. Hold counts and current set max hold cleared. All-time max: $_allTimeMaxHoldDuration");
  }
}
