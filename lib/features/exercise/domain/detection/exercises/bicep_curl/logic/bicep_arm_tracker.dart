import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../core/abstractions/body_tracker.dart';
import '../../../core/entities/enums/feedback_type.dart';
import '../../../core/entities/feedback_event.dart';
import '../../../../../../../core/services/model_inference_processor_service/scaled_feature_model_processor_impl.dart';
import '../entities/biceb_arm_landmarks.dart';
import '../entities/bicep_arm_state.dart';
import '../entities/bicep_arm_tracker_result.dart';
import 'bicep_curl_feature_extractor.dart';

class BicepArmTracker extends BodyTracker {
  static const double _elbowAngleUpThreshold = 80;
  static const double _elbowAngleDownThreshold = 150;
  static const double _elbowExtensionTarget = 140;
  static const double _elbowSqueezeTarget = 75;
  static const double _shoulderTolerance = 25;
  static const double _repCooldownSeconds = 0.3;
  static const double _minRepDurationSeconds = 0.5;
  static const double _maxRepDurationSeconds = 3.0;
  static const double _goodFormThreshold = 70;
  static const int _minFramesForFormIssue = 10;
  static const double _minVisibilityThreshold = 0.7;

  final String side;
  final BicepCurlFeatureExtractor _featureExtractor;
  final ScaledFeatureModelProcessorImpl _modelProcessor;

  BicepArmState state = BicepArmState.down;
  int _reps = 0;
  int get reps => _reps;
  double? _shoulderNeutral;

  double _lastRepTime = 0;
  double _timeEnteredUpState = 0;

  double get lastRepTime => _lastRepTime;

  final List<bool> _currentRepPredictions = [];
  int _consecutiveIncorrectFrames = 0;

  BicepArmTracker(this.side)
      : _featureExtractor = BicepCurlFeatureExtractor(side),
        _modelProcessor = ScaledFeatureModelProcessorImpl(
            modelPath: 'assets/models/bicep/bicep_model_$side.onnx',
            scalerPath: 'assets/models/bicep/scaler_$side.json'),
        super('$side arm');

  Future<void> initialize() async {
    await _modelProcessor.loadModel();
  }

  @override
  bool areLandmarksVisible(Pose pose) {
    List<PoseLandmark?> landmarks = [];

    final shoulderLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftShoulder]
        : pose.landmarks[PoseLandmarkType.rightShoulder];
    landmarks.add(shoulderLandmark);

    final elbowLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftElbow]
        : pose.landmarks[PoseLandmarkType.rightElbow];
    landmarks.add(elbowLandmark);

    final wristLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftWrist]
        : pose.landmarks[PoseLandmarkType.rightWrist];
    landmarks.add(wristLandmark);

    final hipLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftHip]
        : pose.landmarks[PoseLandmarkType.rightHip];
    landmarks.add(hipLandmark);

    for (var element in landmarks) {
      if (element == null || element.likelihood < _minVisibilityThreshold) {
        return false;
      }
    }

    return true;
  }

  @override
  BicepArmTrackerResult processLandmarks(Pose pose, Size imageSize) {
    if (!areLandmarksVisible(pose)) {
      return BicepArmTrackerResult(
          status: false,
          isVisible: false,
          feedbackEvent: FeedbackEvent(side == 'left'
              ? FeedbackType.bicepCurlLeftArmMoveInView
              : FeedbackType.bicepCurlRightArmMoveInView));
    }

    try {
      final landmarks = _extractLandmarks(pose);
      final landmarksMap = _createLandmarksMap(landmarks);

      final features = _featureExtractor.extractFeatures(landmarksMap);
      final elbowAngleSmoothed = features[0];
      final shoulderAngleSmoothed = features[1];

      if (_shoulderNeutral == null && state == BicepArmState.down) {
        _shoulderNeutral = shoulderAngleSmoothed;
      }

      final predictionResult = _modelProcessor.predict(features);
      if (!predictionResult.isValid) {
        log(predictionResult.errorMessage ??
            "Unknown error on prediction for $side arm");

        if (state == BicepArmState.up) {
          state = BicepArmState.down;
          _lastRepTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
          _timeEnteredUpState = 0;
          _currentRepPredictions.clear();
          _consecutiveIncorrectFrames = 0;
        }

        return BicepArmTrackerResult(
          status: false,
          isVisible: true,
          feedbackEvent: FeedbackEvent(FeedbackType.errorPredictionFailed,
              args: {
                'error': predictionResult.errorMessage ?? "Arm detection error"
              }),
          isCorrectForm: false,
        );
      }

      final bool isFormCorrectThisFrame = predictionResult.prediction == 0;

      if (isFormCorrectThisFrame) {
        _consecutiveIncorrectFrames = 0;
      } else {
        _consecutiveIncorrectFrames++;
      }

      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      if (state == BicepArmState.up) {
        _currentRepPredictions.add(isFormCorrectThisFrame);
      }

      if (state == BicepArmState.up &&
          _consecutiveIncorrectFrames >= _minFramesForFormIssue) {
        state = BicepArmState.down;
        _lastRepTime = currentTime;
        _timeEnteredUpState = 0;
        _currentRepPredictions.clear();
        _consecutiveIncorrectFrames = 0;

        return BicepArmTrackerResult(
          status: true,
          isVisible: true,
          isCorrectForm: false,
          feedbackEvent: FeedbackEvent(
              FeedbackType.bicepCurlFormIssueResettingState,
              args: {'arm_side': side}),
        );
      }

      return _processRepState(currentTime, elbowAngleSmoothed,
          shoulderAngleSmoothed, isFormCorrectThisFrame);
    } catch (e, s) {
      log("Error processing $side arm landmarks: $e\n$s");
      return BicepArmTrackerResult(
        status: false,
        isVisible: true,
        feedbackEvent: FeedbackEvent(FeedbackType.errorPredictionFailed,
            args: {'error': "Processing error for $side arm"}),
        isCorrectForm: false,
      );
    }
  }

  BicebArmLandmarks _extractLandmarks(Pose pose) {
    final shoulderLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftShoulder]!
        : pose.landmarks[PoseLandmarkType.rightShoulder]!;

    final elbowLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftElbow]!
        : pose.landmarks[PoseLandmarkType.rightElbow]!;

    final wristLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftWrist]!
        : pose.landmarks[PoseLandmarkType.rightWrist]!;

    final hipLandmark = side == 'left'
        ? pose.landmarks[PoseLandmarkType.leftHip]!
        : pose.landmarks[PoseLandmarkType.rightHip]!;

    return BicebArmLandmarks(
        shoulder: shoulderLandmark,
        elbow: elbowLandmark,
        wrist: wristLandmark,
        hip: hipLandmark);
  }

  Map<String, List<double>> _createLandmarksMap(BicebArmLandmarks landmarks) {
    return {
      'shoulder': [landmarks.shoulder.x, landmarks.shoulder.y],
      'elbow': [landmarks.elbow.x, landmarks.elbow.y],
      'wrist': [landmarks.wrist.x, landmarks.wrist.y],
      'hip': [landmarks.hip.x, landmarks.hip.y]
    };
  }

  BicepArmTrackerResult _processRepState(
      double currentTime,
      double elbowAngleSmoothed,
      double shoulderAngleSmoothed,
      bool isFormCorrectThisFrame) {
    FeedbackEvent? event;
    bool isCorrectOverallForm = true;

    if (currentTime - _lastRepTime > _repCooldownSeconds) {
      if (state == BicepArmState.down &&
          elbowAngleSmoothed < _elbowAngleUpThreshold) {
        state = BicepArmState.up;
        _timeEnteredUpState = currentTime;
        _currentRepPredictions.clear();
        _currentRepPredictions.add(isFormCorrectThisFrame);
      } else if (state == BicepArmState.up &&
          elbowAngleSmoothed > _elbowAngleDownThreshold) {
        state = BicepArmState.down;
        _lastRepTime = currentTime;

        if (_timeEnteredUpState != 0) {
          final repDuration = currentTime - _timeEnteredUpState;
          int totalFrames = _currentRepPredictions.length;
          int correctFrames = _currentRepPredictions.where((b) => b).length;
          double correctPercentage =
              totalFrames > 0 ? (correctFrames / totalFrames) * 100 : 0.0;

          event = _evaluateRepQuality(repDuration, correctPercentage);

          if (correctPercentage >= _goodFormThreshold &&
              repDuration >= _minRepDurationSeconds &&
              repDuration <= _maxRepDurationSeconds) {
            _reps++;

            if (event.type != FeedbackType.bicepCurlLeftArmFocusOnForm &&
                event.type != FeedbackType.bicepCurlRightArmFocusOnForm) {
              event = FeedbackEvent(
                  side == 'left'
                      ? FeedbackType.bicepCurlLeftArmRepCounted
                      : FeedbackType.bicepCurlRightArmRepCounted,
                  args: {'rep_count': _reps.toString()});
            }
          } else {
            isCorrectOverallForm = false;
          }
        }
        _currentRepPredictions.clear();
        _timeEnteredUpState = 0;
      }
    }

    if (event == null) {
      event = _getFormFeedbackEvent(
          elbowAngleSmoothed, shoulderAngleSmoothed, isFormCorrectThisFrame);
      if (event.type == FeedbackType.bicepCurlLeftArmFocusOnForm ||
          event.type == FeedbackType.bicepCurlRightArmFocusOnForm) {
        isCorrectOverallForm = false;
      }
    }

    return BicepArmTrackerResult(
      status: true,
      feedbackEvent: event,
      isVisible: true,
      isCorrectForm: isCorrectOverallForm && isFormCorrectThisFrame,
    );
  }

  FeedbackEvent _evaluateRepQuality(
      double repDuration, double correctPercentage) {
    FeedbackType type;
    if (repDuration < _minRepDurationSeconds) {
      type = side == 'left'
          ? FeedbackType.bicepCurlLeftArmSlowDown
          : FeedbackType.bicepCurlRightArmSlowDown;
    } else if (repDuration > _maxRepDurationSeconds) {
      type = side == 'left'
          ? FeedbackType.bicepCurlLeftArmBeMoreFluid
          : FeedbackType.bicepCurlRightArmBeMoreFluid;
    } else if (correctPercentage < _goodFormThreshold) {
      type = side == 'left'
          ? FeedbackType.bicepCurlLeftArmFocusOnForm
          : FeedbackType.bicepCurlRightArmFocusOnForm;
    } else {
      type = side == 'left'
          ? FeedbackType.bicepCurlLeftArmGoodRep
          : FeedbackType.bicepCurlRightArmGoodRep;
    }
    return FeedbackEvent(type);
  }

  FeedbackEvent _getFormFeedbackEvent(double elbowAngleSmoothed,
      double shoulderAngleSmoothed, bool isFormCorrectThisFrame) {
    if (!isFormCorrectThisFrame && _consecutiveIncorrectFrames > 1) {
      return FeedbackEvent(side == 'left'
          ? FeedbackType.bicepCurlLeftArmFocusOnForm
          : FeedbackType.bicepCurlRightArmFocusOnForm);
    }

    if (_shoulderNeutral != null) {
      final shoulderDeviation = shoulderAngleSmoothed - _shoulderNeutral!;
      if (shoulderDeviation.abs() > _shoulderTolerance) {
        return FeedbackEvent(shoulderDeviation < 0
            ? (side == 'left'
                ? FeedbackType.bicepCurlLeftArmKeepShoulderStill
                : FeedbackType.bicepCurlRightArmKeepShoulderStill)
            : (side == 'left'
                ? FeedbackType.bicepCurlLeftArmKeepBackStraight
                : FeedbackType.bicepCurlRightArmKeepBackStraight));
      }
    }

    if (state == BicepArmState.down &&
        elbowAngleSmoothed < (_elbowExtensionTarget - 15)) {
      return FeedbackEvent(side == 'left'
          ? FeedbackType.bicepCurlLeftArmExtendFully
          : FeedbackType.bicepCurlRightArmExtendFully);
    } else if (state == BicepArmState.up &&
        elbowAngleSmoothed > (_elbowSqueezeTarget + 15)) {
      return FeedbackEvent(side == 'left'
          ? FeedbackType.bicepCurlLeftArmCurlHigher
          : FeedbackType.bicepCurlRightArmCurlHigher);
    }

    return FeedbackEvent(side == 'left'
        ? FeedbackType.bicepCurlLeftArmGoodForm
        : FeedbackType.bicepCurlRightArmGoodForm);
  }

  @override
  void reset() {
    _reps = 0;
    state = BicepArmState.down;
    _shoulderNeutral = null;
    _lastRepTime = 0;
    _timeEnteredUpState = 0;
    _currentRepPredictions.clear();
    _consecutiveIncorrectFrames = 0;
    _featureExtractor.reset();
  }
}
