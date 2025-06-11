import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../core/services/orientation/orientation_feedback_types.dart';
import '../../../../../core/services/orientation/orientation_thresholds.dart';
import '../../../../../core/services/orientation/user_desired_orientation.dart';
import '../../../../../core/services/orientation_service.dart';
import '../../../../../core/utils/device_orientation_utils/physical_orientation.dart';
import '../../../../../core/utils/geometry_utils.dart';
import '../../../../../core/utils/pose_processing_utils.dart';

import '../../../../common_exercise/domain/abstractions/exercise_trainer.dart';
import '../../../../common_exercise/domain/entities/enums/feedback_category.dart';
import '../../../../common_exercise/domain/entities/enums/feedback_type.dart';
import '../../../../common_exercise/domain/entities/exercise_feedback.dart';
import '../../../../common_exercise/domain/entities/feedback_event.dart';
import '../../../../common_exercise/domain/utils/hold_goal_config.dart';
import '../../../../common_exercise/domain/utils/rep_goal_config.dart';
import '../../../../common_exercise/domain/utils/timed_feedback_manager.dart';
import '../../../../common_exercise/presentation/painters/base_exercise_painter.dart';

import '../../presentation/painters/plank_pose_painter.dart';
import '../entities/plank_result.dart';
import '../entities/plank_state.dart';
import '../entities/plank_tracker_result.dart';
import 'plank_feedback_provider.dart';
import 'plank_tracker.dart';

class PlankTrainer extends ExerciseTrainer {
  late final PlankTracker _tracker;
  late final PlankFeedbackProvider _feedbackProvider;
  late final PlankFeedbackProvider _goalFeedbackProvider;

  late final RepGoalConfig _repGoalConfig;
  late final HoldGoalConfig _holdGoalConfig;
  late final TimedFeedbackManager _timedGoalFeedbackManager;

  static const int _defaultSuccessfulHoldsGoal = 5;
  static const int _successfulHoldsIncrement = 2;
  static const int _successfulHoldsMilestoneInterval = 2;

  static const double _defaultMaxHoldTimeGoal = 20.0;
  static const double _holdGoalIncrementStep = 5.0;

  int _lastTrackedSuccessfulHolds = 0;

  FeedbackType? _lastDisplayedFormCorrectionType;

  static const bool _isOrientationCheckEnabled = true;
  static const double _portraitPersonMaxWidthAspectRatio = 0.75;
  static const double _landscapePersonMinHeightAspectRatio = 1.25;
  static const double _flatScreenUpPersonMinHeightAspectRatio = 1.15;

  static final List<PoseLandmarkType> _personAspectRatioKeyLandmarks = [
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
    PoseLandmarkType.nose,
  ];
  static const double _minLandmarkVisibilityForAspectRatio = 0.05;
  static const double _minLandmarkVisibilityForProcessing = 0.4;
  static const double _minVisibleKeyLandmarksRatioForProcessing = 0.85;

  static const double _setupStraightnessThresholdRatio = 0.15;

  static const bool _isPlankPositionCheckEnabled = true;
  static const int _minFramesForPositionDetection = 3;
  int _plankPositionCounter = 0;
  bool _isUserInPlankPosition = false;

  bool _isUserCorrectlySetup = false;
  int _correctSetupFrameCounter = 0;
  static const int _minFramesForSetupConfirmation = 3;

  static int get _minVisibleLandmarksCountForProcessing =>
      (_personAspectRatioKeyLandmarks.length *
              _minVisibleKeyLandmarksRatioForProcessing)
          .round();

  late final OrientationService _orientationService;
  late final OrientationThresholds _orientationThresholds;
  late final OrientationFeedbackTypes _orientationFeedbackTypes;
  PhysicalOrientation _currentPhysicalOrientation = PhysicalOrientation.unknown;

  FeedbackEvent _currentTrainerFeedbackEvent =
      FeedbackEvent(FeedbackType.plankSetupInitialPrompt);

  String _tempPlankFeedbackSideName = "";
  String _tempPlankFeedbackOrientationName = "";
  FeedbackType? _tempPlankFeedbackType;

  PlankTrainer({
    int? initialSuccessfulHoldsGoal,
    bool enableRepGoalAutoIncrease = true,
    double? initialMaxHoldTimeGoal,
    bool enableHoldGoalAutoIncrease = true,
  }) : super('Plank Trainer') {
    _tracker = PlankTracker();
    _feedbackProvider = PlankFeedbackProvider();
    _goalFeedbackProvider = PlankFeedbackProvider();

    _repGoalConfig = RepGoalConfig(
      initialGoal: initialSuccessfulHoldsGoal ?? _defaultSuccessfulHoldsGoal,
      defaultGoal: _defaultSuccessfulHoldsGoal,
      increment: _successfulHoldsIncrement,
      milestoneInterval: _successfulHoldsMilestoneInterval,
      autoIncreaseEnabled: enableRepGoalAutoIncrease,
    );

    _holdGoalConfig = HoldGoalConfig(
      initialGoal: initialMaxHoldTimeGoal ?? _defaultMaxHoldTimeGoal,
      defaultGoal: _defaultMaxHoldTimeGoal,
      incrementStep: _holdGoalIncrementStep,
      minValidHoldTime: PlankTracker.minHoldDurationForRep,
      autoIncreaseEnabled: enableHoldGoalAutoIncrease,
    );

    _timedGoalFeedbackManager =
        TimedFeedbackManager(displayDuration: const Duration(seconds: 3));

    _orientationService = OrientationService(
      isOrientationCheckEnabled: _isOrientationCheckEnabled,
      minFramesForDetection: _minFramesForSetupConfirmation,
    );
    _orientationThresholds = OrientationThresholds(
      portrait: _portraitPersonMaxWidthAspectRatio,
      landscape: _landscapePersonMinHeightAspectRatio,
      flatScreenUp: _flatScreenUpPersonMinHeightAspectRatio,
    );
    _orientationFeedbackTypes = OrientationFeedbackTypes(
      setupHoldOrientation: FeedbackType.setupHoldHorizontalOrientation,
      setupPersonNotOriented: FeedbackType.setupPersonNotHorizontal,
      setupSuccess: FeedbackType.neutralProcessing,
      setupVisibilityPartial: FeedbackType.setupVisibilityPartial,
      setupPhoneAccelerometerWait: FeedbackType.setupPhoneAccelerometerWait,
      setupPhoneOrientationIssue: FeedbackType.setupPhoneOrientationIssue,
    );
  }

  int get successfulHoldsSetGoal => _repGoalConfig.currentGoal;
  set successfulHoldsSetGoal(int? value) {
    if (value != null && value != _repGoalConfig.currentGoal) {
      _repGoalConfig.currentGoal = value;
      _timedGoalFeedbackManager.clearEvent();
    }
  }

  bool get isRepGoalAutoIncreaseEnabled => _repGoalConfig.autoIncreaseEnabled;
  set isRepGoalAutoIncreaseEnabled(bool enabled) {
    _repGoalConfig.autoIncreaseEnabled = enabled;
  }

  double get maxHoldTimeSetGoal => _holdGoalConfig.currentGoal;
  set maxHoldTimeSetGoal(double? value) {
    if (value != null && value != _holdGoalConfig.currentGoal) {
      _holdGoalConfig.currentGoal = value;
      _timedGoalFeedbackManager.clearEvent();
    }
  }

  bool get isHoldGoalAutoIncreaseEnabled => _holdGoalConfig.autoIncreaseEnabled;
  set isHoldGoalAutoIncreaseEnabled(bool enabled) {
    _holdGoalConfig.autoIncreaseEnabled = enabled;
  }

  PoseLandmark? _getLandmark(
      Map<PoseLandmarkType, PoseLandmark> landmarks, PoseLandmarkType type,
      [double minVisibility = _minLandmarkVisibilityForProcessing]) {
    final landmark = landmarks[type];
    return (landmark != null && landmark.likelihood >= minVisibility)
        ? landmark
        : null;
  }

  List<double>? _landmarkToList(PoseLandmark? landmark) {
    return landmark != null ? [landmark.x, landmark.y] : null;
  }

  bool _isErrorFeedback(FeedbackType type) {
    return type.category == FeedbackCategory.error;
  }

  bool _isSetupIssueFeedback(FeedbackType type) {
    return type.category == FeedbackCategory.setup &&
        type != FeedbackType.plankSetupSuccess &&
        type != FeedbackType.setupSuccess;
  }

  bool _isMajorFormCorrectionFeedback(FeedbackType type) {
    return type == FeedbackType.plankHighHips ||
        type == FeedbackType.plankLowHips ||
        type == FeedbackType.plankFormIssueGeneric ||
        type == FeedbackType.plankTooFast;
  }

  bool _isMinorFormCorrectionFeedback(FeedbackType type) {
    return type == FeedbackType.plankEngageCore ||
        type == FeedbackType.plankMaintainStraightLine;
  }

  bool _isFormCorrectionFeedback(FeedbackType type) {
    return _isMajorFormCorrectionFeedback(type) ||
        _isMinorFormCorrectionFeedback(type);
  }

  bool _shouldInterruptTimedGoal(FeedbackType effectiveFeedbackType) {
    return _isErrorFeedback(effectiveFeedbackType) ||
        _isSetupIssueFeedback(effectiveFeedbackType) ||
        _isMajorFormCorrectionFeedback(effectiveFeedbackType);
  }

  @override
  Future<void> loadModels() async {
    await _tracker.initialize();
  }

  bool _checkBodySidePlankPosition(
      PoseLandmark? shoulder,
      PoseLandmark? elbow,
      PoseLandmark? wrist,
      PoseLandmark? hip,
      PoseLandmark? knee,
      PoseLandmark? ankle,
      PhysicalOrientation phoneOrientation,
      {bool provideFeedback = false,
      String sideName = ""}) {
    if (shoulder == null || hip == null || knee == null || ankle == null) {
      if (provideFeedback) {
        _tempPlankFeedbackType = FeedbackType.plankSetupIncompleteLandmarks;
        _tempPlankFeedbackSideName =
            sideName.isNotEmpty ? "$sideName side" : "your body";
      }
      return false;
    }

    double hipToKneeDist =
        GeometryUtils.calculateDistance(hip.x, hip.y, knee.x, knee.y);
    double kneeToAnkleDist =
        GeometryUtils.calculateDistance(knee.x, knee.y, ankle.x, ankle.y);

    double legSegmentRatio =
        (hipToKneeDist > 0.01) ? (kneeToAnkleDist / hipToKneeDist) : 0;
    bool legsExtended = legSegmentRatio >= 0.8 && legSegmentRatio <= 1.3;

    bool armPositionedForPlank = true;
    if (elbow != null && wrist != null) {
      double elbowToWristDist =
          GeometryUtils.calculateDistance(elbow.x, elbow.y, wrist.x, wrist.y);
      double shoulderToElbowDist = GeometryUtils.calculateDistance(
          shoulder.x, shoulder.y, elbow.x, elbow.y);

      if (shoulderToElbowDist > 0.01) {
        double armBendRatio = elbowToWristDist / shoulderToElbowDist;
        armPositionedForPlank = armBendRatio >= 0.3 && armBendRatio <= 1.5;
      }
    }

    double shoulderToAnkleAngleToImgVertical =
        GeometryUtils.calculateAngleToVertical(
            shoulder.x, shoulder.y, ankle.x, ankle.y);

    bool bodyOrientedCorrectly = false;
    FeedbackType? orientationFeedbackType;
    String orientationName = "";

    switch (phoneOrientation) {
      case PhysicalOrientation.landscapeLeft:
      case PhysicalOrientation.landscapeRight:
      case PhysicalOrientation.flatScreenUp:
        bodyOrientedCorrectly = shoulderToAnkleAngleToImgVertical >= 60;
        orientationFeedbackType = FeedbackType.setupPersonNotHorizontal;
        orientationName = "horizontal";
        break;
      case PhysicalOrientation.portrait:
      case PhysicalOrientation.invertedPortrait:
        bodyOrientedCorrectly = shoulderToAnkleAngleToImgVertical <= 30;
        orientationFeedbackType = FeedbackType.setupPersonNotHorizontal;
        orientationName = "horizontal";
        break;
      default:
        bodyOrientedCorrectly = false;
        break;
    }

    if (provideFeedback) {
      _tempPlankFeedbackType = null;
      _tempPlankFeedbackSideName = sideName;
      _tempPlankFeedbackOrientationName = "";

      if (!legsExtended) {
        _tempPlankFeedbackType = FeedbackType.plankSetupIncompleteLandmarks;
        _tempPlankFeedbackSideName =
            "$sideName legs need to be extended for plank";
      } else if (!armPositionedForPlank) {
        _tempPlankFeedbackType = FeedbackType.plankSetupIncompleteLandmarks;
        _tempPlankFeedbackSideName = "$sideName arm position for plank support";
      } else if (!bodyOrientedCorrectly && orientationFeedbackType != null) {
        _tempPlankFeedbackType = orientationFeedbackType;
        _tempPlankFeedbackSideName = "body";
        _tempPlankFeedbackOrientationName = orientationName;
      }
    }

    return legsExtended && armPositionedForPlank && bodyOrientedCorrectly;
  }

  bool _checkFaceOrientationForPlank(
      Pose pose, PhysicalOrientation physicalOrientation) {
    final landmarks = pose.landmarks;

    final leftEye = _getLandmark(landmarks, PoseLandmarkType.leftEye, 0.3);
    final rightEye = _getLandmark(landmarks, PoseLandmarkType.rightEye, 0.3);
    final nose = _getLandmark(landmarks, PoseLandmarkType.nose, 0.3);

    if (leftEye == null || rightEye == null || nose == null) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupFaceNotVisible);
      return false;
    }

    final faceOrientation = GeometryUtils.calculateFaceOrientation(
      _landmarkToList(leftEye),
      _landmarkToList(rightEye),
      _landmarkToList(nose),
      physicalOrientation,
    );

    if (faceOrientation < 0) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupFaceUp);
      return false;
    } else if (faceOrientation > 0) {
      return true;
    } else {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupFaceNotVisible);
      return false;
    }
  }

  bool _updateAndCheckPlankPosition(
      Pose pose, PhysicalOrientation physicalOrientation) {
    if (!_isPlankPositionCheckEnabled) {
      _isUserInPlankPosition = true;
      _plankPositionCounter = _minFramesForPositionDetection;
      return true;
    }

    final landmarks = pose.landmarks;
    final currentPhoneOrientation = physicalOrientation;

    List<PoseLandmark?> essential = [
      landmarks[PoseLandmarkType.leftShoulder],
      landmarks[PoseLandmarkType.rightShoulder],
      landmarks[PoseLandmarkType.leftHip],
      landmarks[PoseLandmarkType.rightHip],
    ];

    if (essential.where((lm) => lm != null).length < 4) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupIncompleteLandmarks);
      _plankPositionCounter = math.max(0, _plankPositionCounter - 1);
      _isUserInPlankPosition =
          _plankPositionCounter >= _minFramesForPositionDetection;
      return _isUserInPlankPosition;
    }

    if (!_checkFaceOrientationForPlank(pose, physicalOrientation)) {
      _plankPositionCounter = math.max(0, _plankPositionCounter - 1);
      _isUserInPlankPosition = false;
      return false;
    }

    _tempPlankFeedbackType = null;
    _tempPlankFeedbackSideName = "";
    _tempPlankFeedbackOrientationName = "";

    bool leftSideOk = _checkBodySidePlankPosition(
        landmarks[PoseLandmarkType.leftShoulder],
        landmarks[PoseLandmarkType.leftElbow],
        landmarks[PoseLandmarkType.leftWrist],
        landmarks[PoseLandmarkType.leftHip],
        landmarks[PoseLandmarkType.leftKnee],
        landmarks[PoseLandmarkType.leftAnkle],
        currentPhoneOrientation,
        provideFeedback: true,
        sideName: "left");

    bool rightSideOk = _checkBodySidePlankPosition(
        landmarks[PoseLandmarkType.rightShoulder],
        landmarks[PoseLandmarkType.rightElbow],
        landmarks[PoseLandmarkType.rightWrist],
        landmarks[PoseLandmarkType.rightHip],
        landmarks[PoseLandmarkType.rightKnee],
        landmarks[PoseLandmarkType.rightAnkle],
        currentPhoneOrientation,
        provideFeedback: !leftSideOk,
        sideName: "right");

    bool isPlankPositionCandidate = leftSideOk && rightSideOk;

    if (isPlankPositionCandidate) {
      _plankPositionCounter = math.min(
          _minFramesForPositionDetection + 2, _plankPositionCounter + 1);
      if (_plankPositionCounter >= _minFramesForPositionDetection) {
        _isUserInPlankPosition = true;
        if (_currentTrainerFeedbackEvent.type.name.startsWith("plankSetup") ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.setupHoldHorizontalOrientation ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.neutralProcessing) {
          _currentTrainerFeedbackEvent =
              FeedbackEvent(FeedbackType.neutralProcessing);
        }
      } else {
        _isUserInPlankPosition = false;
        _currentTrainerFeedbackEvent =
            FeedbackEvent(FeedbackType.plankSetupHoldStraightPosition);
      }
    } else {
      _plankPositionCounter = math.max(0, _plankPositionCounter - 1);
      _isUserInPlankPosition = false;
      if (_tempPlankFeedbackType != null) {
        Map<String, String> args = {'side_name': _tempPlankFeedbackSideName};
        if (_tempPlankFeedbackOrientationName.isNotEmpty) {
          args['orientation_name'] = _tempPlankFeedbackOrientationName;
        }
        _currentTrainerFeedbackEvent =
            FeedbackEvent(_tempPlankFeedbackType!, args: args);
      } else {
        _currentTrainerFeedbackEvent = FeedbackEvent(
            FeedbackType.plankSetupIncompleteLandmarks,
            args: {'side_name': 'position'});
      }
    }
    return _isUserInPlankPosition;
  }

  bool _updateAndCheckPlankStraightnessForSetup(
      Pose pose, PhysicalOrientation physicalOrientation) {
    final landmarks = pose.landmarks;

    final lShoulder =
        _getLandmark(landmarks, PoseLandmarkType.leftShoulder, 0.3);
    final rShoulder =
        _getLandmark(landmarks, PoseLandmarkType.rightShoulder, 0.3);
    final lHip = _getLandmark(landmarks, PoseLandmarkType.leftHip, 0.3);
    final rHip = _getLandmark(landmarks, PoseLandmarkType.rightHip, 0.3);
    final lAnkle = _getLandmark(landmarks, PoseLandmarkType.leftAnkle, 0.3);
    final rAnkle = _getLandmark(landmarks, PoseLandmarkType.rightAnkle, 0.3);

    if (lShoulder == null ||
        rShoulder == null ||
        lHip == null ||
        rHip == null ||
        lAnkle == null ||
        rAnkle == null) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupIncompleteLandmarks);
      _correctSetupFrameCounter = math.max(0, _correctSetupFrameCounter - 1);
      return false;
    }

    final shoulderMid = [
      (lShoulder.x + rShoulder.x) / 2,
      (lShoulder.y + rShoulder.y) / 2
    ];
    final hipMid = [(lHip.x + rHip.x) / 2, (lHip.y + rHip.y) / 2];
    final ankleMid = [(lAnkle.x + rAnkle.x) / 2, (lAnkle.y + rAnkle.y) / 2];

    final double shoulderAnkleDistance =
        GeometryUtils.calculateDistanceList(shoulderMid, ankleMid);

    if (shoulderAnkleDistance < 0.01) {
      _currentTrainerFeedbackEvent = FeedbackEvent(
          FeedbackType.plankSetupIncompleteLandmarks,
          args: {'reason': 'Body too compressed'});
      _correctSetupFrameCounter = math.max(0, _correctSetupFrameCounter - 1);
      return false;
    }

    final double hipDeviation =
        GeometryUtils.distancePointToLineSegment(hipMid, shoulderMid, ankleMid);
    final double normalizedDeviation = hipDeviation / shoulderAnkleDistance;

    double lineYatHipX = shoulderMid[1] +
        (ankleMid[1] - shoulderMid[1]) *
            (hipMid[0] - shoulderMid[0]) /
            (ankleMid[0] - shoulderMid[0] + 1e-6);
    double verticalDeviation = hipMid[1] - lineYatHipX;

    bool isHipsTooHigh = false;
    bool isHipsTooLow = false;

    if (normalizedDeviation > _setupStraightnessThresholdRatio) {
      if (verticalDeviation < 0) {
        isHipsTooHigh = true;
      } else {
        isHipsTooLow = true;
      }
    }

    if (isHipsTooHigh) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupHipsTooHigh);
      _correctSetupFrameCounter = math.max(0, _correctSetupFrameCounter - 1);
      return false;
    }
    if (isHipsTooLow) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupHipsTooLow);
      _correctSetupFrameCounter = math.max(0, _correctSetupFrameCounter - 1);
      return false;
    }

    _correctSetupFrameCounter = math.min(
        _minFramesForSetupConfirmation + 2, _correctSetupFrameCounter + 1);
    if (_correctSetupFrameCounter < _minFramesForSetupConfirmation) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.plankSetupHoldStraightPosition);
      return true;
    } else {
      if (_currentTrainerFeedbackEvent.type.category ==
              FeedbackCategory.setup &&
          _currentTrainerFeedbackEvent.type != FeedbackType.plankSetupSuccess &&
          _currentTrainerFeedbackEvent.type !=
              FeedbackType.plankSetupHoldStraightPosition) {
        _currentTrainerFeedbackEvent =
            FeedbackEvent(FeedbackType.neutralProcessing);
      }
      return true;
    }
  }

  bool _performSetupChecks(Pose pose, Size imageSize) {
    final orientationResult = _orientationService.checkOrientation(
      pose: pose,
      desiredUserOrientation: UserDesiredOrientation.horizontal,
      personAspectRatioKeyLandmarks: _personAspectRatioKeyLandmarks,
      minLandmarkVisibilityForAspectRatio: _minLandmarkVisibilityForAspectRatio,
      thresholds: _orientationThresholds,
      feedbackTypes: _orientationFeedbackTypes,
    );

    _currentTrainerFeedbackEvent = orientationResult.feedbackEvent;
    _currentPhysicalOrientation = orientationResult.physicalOrientation;

    if (!orientationResult.isOrientedCorrectly) {
      _correctSetupFrameCounter = 0;
      _isUserCorrectlySetup = false;
      _plankPositionCounter = 0;
      _isUserInPlankPosition = false;
      _tracker.interruptHold();
      return false;
    }

    if (!_updateAndCheckPlankPosition(pose, _currentPhysicalOrientation)) {
      _correctSetupFrameCounter = 0;
      _isUserCorrectlySetup = false;
      _tracker.interruptHold();
      return false;
    }

    if (!_updateAndCheckPlankStraightnessForSetup(
        pose, _currentPhysicalOrientation)) {
      _isUserCorrectlySetup = false;
      _tracker.interruptHold();
      return false;
    }

    if (_correctSetupFrameCounter >= _minFramesForSetupConfirmation &&
        _isUserInPlankPosition) {
      if (!_isUserCorrectlySetup) {
        _currentTrainerFeedbackEvent =
            FeedbackEvent(FeedbackType.plankSetupSuccess);
      } else if (_currentTrainerFeedbackEvent.type !=
              FeedbackType.plankSetupSuccess &&
          _currentTrainerFeedbackEvent.type.category ==
              FeedbackCategory.setup) {
        _currentTrainerFeedbackEvent =
            FeedbackEvent(FeedbackType.neutralProcessing);
      }
      _isUserCorrectlySetup = true;
      return true;
    } else {
      _isUserCorrectlySetup = false;
      return false;
    }
  }

  @override
  PlankResult processFrame(List<Pose> poses, Size imageSize) {
    if (poses.isEmpty ||
        PoseProcessingUtils.countVisibleLandmarks(
                poses.first,
                _personAspectRatioKeyLandmarks,
                _minLandmarkVisibilityForProcessing) <
            _minVisibleLandmarksCountForProcessing) {
      _orientationService.reset();
      _isUserCorrectlySetup = false;
      _correctSetupFrameCounter = 0;
      return _handleNoPersonOrNonVisible();
    }

    final pose = poses.first;

    if (!_isUserCorrectlySetup) {
      if (!_performSetupChecks(pose, imageSize)) {
        _timedGoalFeedbackManager.clearEvent();
        return PlankResult(
            status: true,
            successfulHoldsCount: _tracker.successfulHoldsCount,
            currentHoldDuration: _tracker.currentCorrectHoldDuration,
            trainerFeedback:
                _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent),
            trackerResult: PlankTrackerResult(
              status: true,
              isVisible: true,
              feedbackEvent: _currentTrainerFeedbackEvent,
              currentPoseState: _tracker.state,
            ));
      }
    }

    if (_currentTrainerFeedbackEvent.type == FeedbackType.plankSetupSuccess &&
        _tracker.state != PlankState.neutral) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.neutralProcessing);
    } else if (_currentTrainerFeedbackEvent.type ==
        FeedbackType.plankSetupSuccess) {
    } else if (_currentTrainerFeedbackEvent.type.category ==
            FeedbackCategory.setup &&
        _currentTrainerFeedbackEvent.type != FeedbackType.neutralProcessing &&
        _isUserCorrectlySetup) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.neutralProcessing);
    }

    final trackerResult = _tracker.processLandmarks(pose, imageSize);

    FeedbackEvent effectiveFeedbackEventForDisplay;
    final rawTrackerFeedbackEvent = trackerResult.feedbackEvent;

    if (_isFormCorrectionFeedback(rawTrackerFeedbackEvent.type)) {
      effectiveFeedbackEventForDisplay = rawTrackerFeedbackEvent;
      _lastDisplayedFormCorrectionType = rawTrackerFeedbackEvent.type;
    } else {
      effectiveFeedbackEventForDisplay = rawTrackerFeedbackEvent;
      if (_lastDisplayedFormCorrectionType != null &&
          !_isMinorFormCorrectionFeedback(rawTrackerFeedbackEvent.type)) {
        _lastDisplayedFormCorrectionType = null;
      }
    }

    final currentEffectiveTrackerFeedbackType =
        effectiveFeedbackEventForDisplay.type;

    if (_shouldInterruptTimedGoal(currentEffectiveTrackerFeedbackType)) {
      _timedGoalFeedbackManager.clearEvent();
    }

    ExerciseFeedback? finalGoalFeedback = _determineGoalFeedback(trackerResult);
    ExerciseFeedback? finalTrainerFeedback;
    ExerciseFeedback? finalPrimaryFeedback;

    if (finalGoalFeedback != null) {
      finalPrimaryFeedback = finalGoalFeedback;
    } else {
      bool isCriticalSetupFeedback = _currentTrainerFeedbackEvent
                  .type.category ==
              FeedbackCategory.setup &&
          _currentTrainerFeedbackEvent.type != FeedbackType.plankSetupSuccess &&
          _currentTrainerFeedbackEvent.type != FeedbackType.neutralProcessing &&
          _currentTrainerFeedbackEvent.type !=
              FeedbackType.setupHoldHorizontalOrientation;

      if (isCriticalSetupFeedback) {
        finalTrainerFeedback =
            _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent);
      } else if (effectiveFeedbackEventForDisplay.type !=
          FeedbackType.neutralProcessing) {
        finalPrimaryFeedback =
            _feedbackProvider.getFeedback(effectiveFeedbackEventForDisplay);
      } else if (_currentTrainerFeedbackEvent.type ==
              FeedbackType.plankSetupSuccess &&
          _tracker.state == PlankState.neutral &&
          _tracker.currentCorrectHoldDuration == 0) {
        finalTrainerFeedback =
            _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent);
      } else {
        finalTrainerFeedback = _feedbackProvider.getFeedback(FeedbackEvent(
            _tracker.successfulHoldsCount == 0 &&
                    _lastTrackedSuccessfulHolds == 0 &&
                    _tracker.state == PlankState.neutral
                ? FeedbackType.plankSetupInitialPrompt
                : FeedbackType.neutralProcessing));
      }
    }

    return PlankResult(
      status: trackerResult.status,
      successfulHoldsCount: _tracker.successfulHoldsCount,
      currentHoldDuration: _tracker.currentCorrectHoldDuration,
      trackerResult: trackerResult,
      feedback: finalPrimaryFeedback,
      trainerFeedback: finalTrainerFeedback,
    );
  }

  PlankResult _handleNoPersonOrNonVisible() {
    _tracker.interruptHold();
    _isUserCorrectlySetup = false;
    _correctSetupFrameCounter = 0;
    _plankPositionCounter = 0;
    _isUserInPlankPosition = false;
    _timedGoalFeedbackManager.clearEvent();
    _lastDisplayedFormCorrectionType = null;

    _currentTrainerFeedbackEvent =
        FeedbackEvent(FeedbackType.errorNoPersonDetected);

    return PlankResult(
      status: false,
      successfulHoldsCount: _tracker.successfulHoldsCount,
      currentHoldDuration: 0.0,
      feedback: null,
      trainerFeedback:
          _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent),
      trackerResult: PlankTrackerResult(
        status: true,
        isVisible: false,
        feedbackEvent: _currentTrainerFeedbackEvent,
      ),
    );
  }

  ExerciseFeedback? _determineGoalFeedback(PlankTrackerResult trackerResult) {
    FeedbackEvent? newGoalEvent =
        _evaluateAndProcessGoalAchievements(trackerResult);
    if (newGoalEvent != null) {
      _timedGoalFeedbackManager.setEvent(newGoalEvent);
    }

    FeedbackEvent? activeTimedGoal = _timedGoalFeedbackManager.getActiveEvent();
    if (activeTimedGoal != null) {
      return _goalFeedbackProvider.getFeedback(activeTimedGoal);
    }

    return null;
  }

  FeedbackEvent? _evaluateAndProcessGoalAchievements(
      PlankTrackerResult trackerResult) {
    FeedbackEvent? repGoalEvent = _checkSuccessfulHoldsGoals();
    FeedbackEvent? holdGoalEvent = _checkMaxHoldTimeGoals(trackerResult);

    return holdGoalEvent ?? repGoalEvent;
  }

  FeedbackEvent? _checkSuccessfulHoldsGoals() {
    final currentHolds = _tracker.successfulHoldsCount;
    if (currentHolds <= _lastTrackedSuccessfulHolds) return null;

    _lastTrackedSuccessfulHolds = currentHolds;
    FeedbackEvent? newEvent;

    if (currentHolds == _repGoalConfig.currentGoal) {
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
    } else if (currentHolds > _repGoalConfig.currentGoal) {
      if (!_repGoalConfig.autoIncreaseEnabled ||
          currentHolds == _repGoalConfig.currentGoal + 1) {
        newEvent = FeedbackEvent(FeedbackType.goalRepExceeded, args: {
          'reps_over_count':
              (currentHolds - _repGoalConfig.currentGoal).toString()
        });
      }
    } else if (currentHolds > 0 &&
        currentHolds % _repGoalConfig.milestoneInterval == 0) {
      HapticFeedback.lightImpact();
      newEvent = FeedbackEvent(FeedbackType.goalRepMilestone,
          args: {'reps_milestone': currentHolds.toString()});
    }
    return newEvent;
  }

  FeedbackEvent? _checkMaxHoldTimeGoals(PlankTrackerResult trackerResult) {
    final currentMaxHoldInSet = trackerResult.maxHoldDurationThisSet;

    final activeEvent = _timedGoalFeedbackManager.getActiveEvent();
    final isCurrentHoldGoalEventActive = activeEvent != null &&
        (activeEvent.type == FeedbackType.goalHoldTimeMet ||
            activeEvent.type == FeedbackType.goalHoldTimeMetNewGoal) &&
        (activeEvent.args?['target_hold_s'] ==
                "${_holdGoalConfig.currentGoal.toStringAsFixed(1)}s" ||
            activeEvent.args?['new_target_hold_s'] ==
                "${_holdGoalConfig.currentGoal.toStringAsFixed(1)}s");

    if (currentMaxHoldInSet < _holdGoalConfig.currentGoal ||
        isCurrentHoldGoalEventActive ||
        currentMaxHoldInSet < _holdGoalConfig.minValidHoldTime) {
      return null;
    }

    HapticFeedback.mediumImpact();

    double previousGoal = _holdGoalConfig.currentGoal;
    Map<String, dynamic> holdArgs = {
      'target_hold_s': previousGoal.toStringAsFixed(1),
      'actual_hold_s': currentMaxHoldInSet.toStringAsFixed(1)
    };
    FeedbackType holdFeedbackType = FeedbackType.goalHoldTimeMet;

    if (_holdGoalConfig.increaseGoal(currentMaxHoldInSet)) {
      holdArgs['new_target_hold_s'] =
          _holdGoalConfig.currentGoal.toStringAsFixed(1);
      holdFeedbackType = FeedbackType.goalHoldTimeMetNewGoal;
    }

    return FeedbackEvent(holdFeedbackType, args: holdArgs);
  }

  @override
  void reset() {
    _tracker.reset();
    _feedbackProvider.resetStickyState();
    _goalFeedbackProvider.resetStickyState();

    _repGoalConfig.reset();
    _holdGoalConfig.reset();

    _lastTrackedSuccessfulHolds = 0;
    _timedGoalFeedbackManager.clearEvent();
    _lastDisplayedFormCorrectionType = null;
    _orientationService.reset();
    _isUserCorrectlySetup = false;
    _correctSetupFrameCounter = 0;
    _plankPositionCounter = 0;
    _isUserInPlankPosition = false;
    _currentTrainerFeedbackEvent =
        FeedbackEvent(FeedbackType.plankSetupInitialPrompt);
    _currentPhysicalOrientation = PhysicalOrientation.unknown;
    log("PlankTrainer reset.");
  }

  void dispose() {
    _orientationService.dispose();
    log("PlankTrainer disposed, accelerometer listener cancelled if was active.");
  }

  @override
  String getInstructions() {
    return '''
PLANK INSTRUCTIONS:

1. Lie face down. Place forearms on the floor, elbows directly under shoulders, arms parallel. (Or, on hands for high plank).
2. Clasp hands if comfortable (for forearm plank).
3. Extend legs, tuck toes. Engage core & glutes to lift hips, forming a straight line from head to heels.
4. Avoid arching your back or letting hips sag. Neck neutral, gaze down or slightly forward.
5. Hold for the cued duration (aim for at least ${PlankTracker.minHoldDurationForRep.toStringAsFixed(1)}s, ideally ${correctHoldTimeGoalForDisplay.toStringAsFixed(1)}s or more!).
6. Current Target Holds: ${_repGoalConfig.currentGoal} successful holds.
7. Current Max Single Hold Goal: ${_holdGoalConfig.currentGoal.toStringAsFixed(1)} seconds.

TIPS:
• Keep core tight, don't let your stomach drop.
• Squeeze glutes.
• Breathe steadily.
• Listen to the AI Trainer for form cues!
    ''';
  }

  static double get allTimeMaxHoldDuration =>
      PlankTracker.allTimeMaxHoldDuration;
  static double get correctHoldTimeGoalForDisplay =>
      PlankTracker.correctHoldTimeGoal;

  static final Set<FeedbackType> _painterIncorrectFormIndicators = {
    FeedbackType.plankHighHips,
    FeedbackType.plankLowHips,
    FeedbackType.plankFormIssueGeneric,
    FeedbackType.plankTooFast,
    FeedbackType.setupPersonNotHorizontal,
    FeedbackType.plankSetupHipsTooHigh,
    FeedbackType.plankSetupHipsTooLow,
    FeedbackType.plankSetupIncompleteLandmarks,
    FeedbackType.plankSetupFaceUp,
    FeedbackType.plankSetupFaceNotVisible,
  };

  @override
  BaseExercisePainter getPainter(List<Pose> poses, Size absoluteImageSize,
      InputImageRotation rotation, bool isFrontCamera) {
    bool isFormVisuallyCorrect = true;
    final PlankState currentTrackerVisualState = _tracker.state;

    if (poses.isNotEmpty) {
      if (!_orientationService.isUserCorrectlyOriented ||
          !_isUserInPlankPosition ||
          _painterIncorrectFormIndicators
              .contains(_currentTrainerFeedbackEvent.type)) {
        isFormVisuallyCorrect = false;
      }
    } else {
      isFormVisuallyCorrect = false;
    }

    return PlankPosePainter(
      poses,
      absoluteImageSize,
      rotation,
      isFrontCamera,
      isFormCorrect: isFormVisuallyCorrect,
      trackerState: currentTrackerVisualState,
      physicalOrientation: _currentPhysicalOrientation,
    );
  }
}
