import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:async';
import 'dart:developer';

import '../../../../../../../core/services/orientation_service/data/orientation_feedback_types.dart';
import '../../../../../../../core/services/orientation_service/data/orientation_thresholds.dart';
import '../../../../../../../core/services/orientation_service/data/user_desired_orientation.dart';
import '../../../../../../../core/services/orientation_service/orientation_service.dart';
import '../../../../../../../core/utils/pose_processing_utils.dart';
import '../../../core/abstractions/exercise_trainer.dart';
import '../../../core/entities/enums/feedback_type.dart';
import '../../../core/entities/exercise_feedback.dart';
import '../../../core/entities/feedback_event.dart';
import '../../../core/utils/rep_goal_config.dart';
import '../../../core/utils/timed_feedback_manager.dart';
import '../../../../../presentation/widgets/shared/painters/base_exercise_painter.dart';
import '../../../../../presentation/widgets/specific_exercise/bicep_curl/bicep_curl_pose_painter.dart';
import '../entities/bicep_curl_result.dart';
import 'bicep_arm_tracker.dart';
import 'bicep_curl_feedback_provider.dart';

class BicepCurlTrainer extends ExerciseTrainer {
  late BicepArmTracker _leftArm;
  late BicepArmTracker _rightArm;

  bool _isCorrectLeftForm = false;
  bool _isCorrectRightForm = false;

  late final RepGoalConfig _repGoalConfig;
  late final BicepCurlFeedbackProvider _leftArmfeedbackProvider;
  late final BicepCurlFeedbackProvider _rightArmfeedbackProvider;
  late final BicepCurlFeedbackProvider _goalfeedbackProvider;
  late final BicepCurlFeedbackProvider _feedbackProvider;
  late final TimedFeedbackManager _timedGoalFeedbackManager;

  int _lastTrackedTotalReps = 0;

  static const bool _isOrientationCheckEnabled = true;
  static const double _portraitPersonMinHeightAspectRatio = 0.8;
  static const double _landscapePersonMaxWidthAspectRatio = 1.2;
  static const double _flatScreenUpPersonMinHeightAspectRatio =
      _portraitPersonMinHeightAspectRatio;

  static final List<PoseLandmarkType> _personAspectRatioKeyLandmarks = [
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
  ];
  static const double _minLandmarkVisibilityForAspectRatio = 0.05;
  static const int _minFramesForPositionDetection = 3;

  late final OrientationService _orientationService;
  late final OrientationThresholds _orientationThresholds;
  late final OrientationFeedbackTypes _orientationFeedbackTypes;

  FeedbackEvent _currentTrainerFeedbackEvent =
      FeedbackEvent(FeedbackType.bicepCurlSetupInitialPrompt);

  static const double _minVisibilityForInitialDetection = 0.1;
  static const int _minVisibleKeyLandmarksForProcessing = 6;

  BicepCurlTrainer({
    int? initialRepGoal,
    bool enableRepGoalAutoIncrease = true,
  }) : super('Bicep Curl Trainer') {
    _leftArm = BicepArmTracker('left');
    _rightArm = BicepArmTracker('right');
    _leftArmfeedbackProvider = BicepCurlFeedbackProvider();
    _rightArmfeedbackProvider = BicepCurlFeedbackProvider();
    _goalfeedbackProvider = BicepCurlFeedbackProvider();
    _feedbackProvider = BicepCurlFeedbackProvider();
    _timedGoalFeedbackManager =
        TimedFeedbackManager(displayDuration: const Duration(seconds: 3));

    _repGoalConfig = RepGoalConfig(
      initialGoal: initialRepGoal ?? 15,
      defaultGoal: 15,
      increment: 5,
      milestoneInterval: 5,
      autoIncreaseEnabled: enableRepGoalAutoIncrease,
    );

    _orientationService = OrientationService(
      isOrientationCheckEnabled: _isOrientationCheckEnabled,
      minFramesForDetection: _minFramesForPositionDetection,
    );
    _orientationThresholds = OrientationThresholds(
      portrait: _portraitPersonMinHeightAspectRatio,
      landscape: _landscapePersonMaxWidthAspectRatio,
      flatScreenUp: _flatScreenUpPersonMinHeightAspectRatio,
    );
    _orientationFeedbackTypes = OrientationFeedbackTypes(
      setupHoldOrientation: FeedbackType.bicepCurlSetupHoldVerticalOrientation,
      setupPersonNotOriented: FeedbackType.bicepCurlSetupPersonNotVertical,
      setupSuccess: FeedbackType.bicepCurlSetupSuccess,
      setupVisibilityPartial: FeedbackType.setupVisibilityPartial,
      setupPhoneAccelerometerWait: FeedbackType.setupPhoneAccelerometerWait,
      setupPhoneOrientationIssue: FeedbackType.setupPhoneOrientationIssue,
    );
  }

  int get totalSetGoal => _repGoalConfig.currentGoal;
  set totalSetGoal(int? value) {
    if (value != null && value > 0 && value != _repGoalConfig.currentGoal) {
      _repGoalConfig.currentGoal = value;
      _timedGoalFeedbackManager.clearEvent();
    }
  }

  bool get isRepGoalAutoIncreaseEnabled => _repGoalConfig.autoIncreaseEnabled;
  set isRepGoalAutoIncreaseEnabled(bool enabled) {
    _repGoalConfig.autoIncreaseEnabled = enabled;
  }

  @override
  Future<void> loadModels() async {
    await Future.wait([_leftArm.initialize(), _rightArm.initialize()]);
  }

  @override
  BicepCurlResult processFrame(List<Pose> poses, Size imageSize) {
    if (poses.isEmpty ||
        PoseProcessingUtils.countVisibleLandmarks(
                poses.first,
                _personAspectRatioKeyLandmarks,
                _minVisibilityForInitialDetection) <
            _minVisibleKeyLandmarksForProcessing) {
      _orientationService.reset();
      _currentTrainerFeedbackEvent = _handleNoPersonOrNonVisible();
      return BicepCurlResult(
        status: false,
        leftReps: _leftArm.reps,
        rightReps: _rightArm.reps,
        generalTrainerFeedback:
            _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent),
      );
    }

    final pose = poses.first;

    final orientationResult = _orientationService.checkOrientation(
      pose: pose,
      desiredUserOrientation: UserDesiredOrientation.vertical,
      personAspectRatioKeyLandmarks: _personAspectRatioKeyLandmarks,
      minLandmarkVisibilityForAspectRatio: _minLandmarkVisibilityForAspectRatio,
      thresholds: _orientationThresholds,
      feedbackTypes: _orientationFeedbackTypes,
    );

    _currentTrainerFeedbackEvent = orientationResult.feedbackEvent;

    if (!orientationResult.isOrientedCorrectly) {
      _timedGoalFeedbackManager.clearEvent();
      return BicepCurlResult(
        status: true,
        leftReps: _leftArm.reps,
        rightReps: _rightArm.reps,
        generalTrainerFeedback:
            _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent),
      );
    }

    if (_orientationService.isUserCorrectlyOriented &&
        (_currentTrainerFeedbackEvent.type ==
                FeedbackType.bicepCurlSetupHoldVerticalOrientation ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.bicepCurlSetupPersonNotVertical ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.setupPhoneOrientationIssue)) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.bicepCurlSetupSuccess);
    }

    final leftArmResult = _leftArm.processLandmarks(pose, imageSize);
    final rightArmResult = _rightArm.processLandmarks(pose, imageSize);

    _isCorrectLeftForm = leftArmResult.isCorrectForm;
    _isCorrectRightForm = rightArmResult.isCorrectForm;

    ExerciseFeedback? leftArmFb = leftArmResult.feedbackEvent != null
        ? _leftArmfeedbackProvider.getFeedback(leftArmResult.feedbackEvent!)
        : null;
    ExerciseFeedback? rightArmFb = rightArmResult.feedbackEvent != null
        ? _rightArmfeedbackProvider.getFeedback(rightArmResult.feedbackEvent!)
        : null;

    FeedbackEvent? goalEvent = _checkRepetitionGoals();
    FeedbackEvent? activeTimedGoal = _timedGoalFeedbackManager.getActiveEvent();
    if (goalEvent != null &&
        (activeTimedGoal == null || goalEvent.type != activeTimedGoal.type)) {
      _timedGoalFeedbackManager.setEvent(goalEvent);
      HapticFeedback.mediumImpact();
    }

    ExerciseFeedback? finalGoalFeedback;
    if (activeTimedGoal != null) {
      finalGoalFeedback = _goalfeedbackProvider.getFeedback(activeTimedGoal);
    }

    ExerciseFeedback? generalFb;
    if (activeTimedGoal == null) {
      _currentTrainerFeedbackEvent = _currentTrainerFeedbackEvent.type ==
                  FeedbackType.bicepCurlSetupSuccess &&
              (_leftArm.reps + _rightArm.reps) > 0
          ? FeedbackEvent(FeedbackType.bicepCurlEncourage)
          : _currentTrainerFeedbackEvent;
      generalFb = _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent);
    }

    return BicepCurlResult(
      status: true,
      leftReps: _leftArm.reps,
      rightReps: _rightArm.reps,
      leftArm: leftArmResult,
      rightArm: rightArmResult,
      leftArmTrainerFeedback: leftArmFb,
      rightArmTrainerFeedback: rightArmFb,
      goalFeedback: finalGoalFeedback,
      generalTrainerFeedback: generalFb,
      currentRepGoal: _repGoalConfig.currentGoal,
    );
  }

  FeedbackEvent _handleNoPersonOrNonVisible() {
    _timedGoalFeedbackManager.clearEvent();

    bool wasRecentlyDetecting =
        _leftArm.reps > 0 || _rightArm.reps > 0 || _lastTrackedTotalReps > 0;
    if (wasRecentlyDetecting) {
      return FeedbackEvent(FeedbackType.bicepCurlMoveIntoView);
    } else {
      return FeedbackEvent(FeedbackType.bicepCurlErrorNoPersonDetected);
    }
  }

  FeedbackEvent? _checkRepetitionGoals() {
    final currentTotalReps = _leftArm.reps + _rightArm.reps;
    if (currentTotalReps <= _lastTrackedTotalReps) return null;

    _lastTrackedTotalReps = currentTotalReps;
    FeedbackEvent? newEvent;

    if (currentTotalReps == _repGoalConfig.currentGoal) {
      HapticFeedback.heavyImpact();
      int previousGoal = _repGoalConfig.currentGoal;
      if (_repGoalConfig.increaseGoal()) {
        newEvent = FeedbackEvent(
          FeedbackType.goalRepTargetMetNewGoal,
          args: {
            'reps_achieved': previousGoal.toString(),
            'new_reps_goal': _repGoalConfig.currentGoal.toString()
          },
        );
      } else {
        newEvent = FeedbackEvent(FeedbackType.goalRepTargetMet,
            args: {'reps_goal': _repGoalConfig.currentGoal.toString()});
      }
    } else if (currentTotalReps > _repGoalConfig.currentGoal) {
      if (!_repGoalConfig.autoIncreaseEnabled ||
          currentTotalReps == _repGoalConfig.currentGoal + 1) {
        newEvent = FeedbackEvent(FeedbackType.goalRepExceeded, args: {
          'reps_over_count':
              (currentTotalReps - _repGoalConfig.currentGoal).toString()
        });
      }
    } else if (currentTotalReps > 0 &&
        currentTotalReps % _repGoalConfig.milestoneInterval == 0) {
      newEvent = FeedbackEvent(FeedbackType.goalRepMilestone,
          args: {'reps_milestone': currentTotalReps.toString()});
    }
    return newEvent;
  }

  @override
  void reset() {
    _leftArm.reset();
    _rightArm.reset();
    _repGoalConfig.reset();
    _timedGoalFeedbackManager.clearEvent();
    _lastTrackedTotalReps = 0;
    _orientationService.reset();
    _currentTrainerFeedbackEvent =
        FeedbackEvent(FeedbackType.bicepCurlSetupInitialPrompt);
  }

  @override
  BaseExercisePainter getPainter(List<Pose> poses, Size absoluteImageSize,
      InputImageRotation rotation, bool isFrontCamera) {
    log("BicepCurlTrainer: getPainter called. Poses count: ${poses.length}, ImageSize: $absoluteImageSize, Rotation: $rotation, IsFrontCamera: $isFrontCamera");
    return BicepCurlPosePainter(
        poses, absoluteImageSize, rotation, isFrontCamera,
        isCorrectLeftElbow: _isCorrectLeftForm,
        isCorrectRightElbow: _isCorrectRightForm);
  }

  void dispose() {
    _orientationService.dispose();
  }
}
