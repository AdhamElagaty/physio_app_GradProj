import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../../../core/services/orientation_service/data/orientation_feedback_types.dart';
import '../../../../../../../core/services/orientation_service/data/orientation_thresholds.dart';
import '../../../../../../../core/services/orientation_service/data/user_desired_orientation.dart';
import '../../../../../../../core/services/orientation_service/orientation_service.dart';
import '../../../../../../../core/utils/device_orientation_utils/physical_orientation.dart';
import '../../../../../../../core/utils/geometry_utils.dart';
import '../../../../../../../core/utils/pose_processing_utils.dart';
import '../../../../../presentation/widgets/shared/painters/base_exercise_painter.dart';
import '../../../../../presentation/widgets/specific_exercise/glute_bridge/glute_bridge_pose_painter.dart';
import '../../../core/abstractions/exercise_trainer.dart';
import '../../../core/entities/enums/feedback_type.dart';
import '../../../core/entities/exercise_feedback.dart';
import '../../../core/entities/feedback_event.dart';
import '../../../core/utils/hold_goal_config.dart';
import '../../../core/utils/rep_goal_config.dart';
import '../../../core/utils/timed_feedback_manager.dart';
import '../entities/glute_bridge_landmarks.dart';
import '../entities/glute_bridge_result.dart';
import '../entities/glute_bridge_state.dart';
import '../entities/glute_bridge_tracker_result.dart';
import 'glute_bridge_feedback_provider.dart';
import 'glute_bridge_tracker.dart';

class GluteBridgeTrainer extends ExerciseTrainer {
  late final GluteBridgeTracker _tracker;
  late final GluteBridgeFeedbackProvider _feedbackProvider;
  late final GluteBridgeFeedbackProvider _goalFeedbackProvider;

  late final RepGoalConfig _repGoalConfig;
  late final HoldGoalConfig _holdGoalConfig;
  late final TimedFeedbackManager _timedGoalFeedbackManager;

  static const int _defaultTotalSetGoal = 15;
  static const int _repGoalIncrement = 5;
  static const int _repMilestoneInterval = 5;

  static const double _defaultMaxHoldTimeGoal = 3.0;
  static const double _holdGoalIncrementStep = 0.5;

  int _lastTrackedReps = 0;

  FeedbackType? _lastDisplayedFormCorrectionType;
  DateTime? _lastDisplayedFormCorrectionTime;
  static const Duration _formCorrectionDebounceInterval = Duration(seconds: 3);

  static const bool _isOrientationCheckEnabled = true;
  static const double _portraitPersonMaxWidthAspectRatio = 0.75;
  static const double _landscapePersonMinHeightAspectRatio = 1.25;
  static const double _flatScreenUpPersonMinHeightAspectRatio = 1.15;

  static const bool _isSupineCheckEnabled = true;
  static final List<PoseLandmarkType> _personAspectRatioKeyLandmarks = [
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
    PoseLandmarkType.nose,
  ];
  static const double _minLandmarkVisibilityForAspectRatio = 0.05;
  static const double _minLandmarkVisibilityForProcessing = 0.1;
  static const int _minVisibleKeyLandmarksForProcessing = 6;

  static const int _minFramesForPositionDetection = 3;
  int _supinePositionCounter = 0;
  bool _isUserSupine = false;

  late final OrientationService _orientationService;
  late final OrientationThresholds _orientationThresholds;
  late final OrientationFeedbackTypes _orientationFeedbackTypes;
  PhysicalOrientation _currentPhysicalOrientation = PhysicalOrientation.unknown;

  FeedbackEvent _currentTrainerFeedbackEvent =
      FeedbackEvent(FeedbackType.setupInitialPrompt);

  String _tempSupineFeedbackSideName = "";
  String _tempSupineFeedbackOrientationName = "";
  FeedbackType? _tempSupineFeedbackType;

  GluteBridgeTrainer({
    int? initialRepGoal,
    bool enableRepGoalAutoIncrease = true,
    double? initialMaxHoldTimeGoal,
    bool enableHoldGoalAutoIncrease = true,
  }) : super('Glute Bridge Trainer') {
    _tracker = GluteBridgeTracker();
    _feedbackProvider = GluteBridgeFeedbackProvider();
    _goalFeedbackProvider = GluteBridgeFeedbackProvider();

    _repGoalConfig = RepGoalConfig(
      initialGoal: initialRepGoal ?? _defaultTotalSetGoal,
      defaultGoal: _defaultTotalSetGoal,
      increment: _repGoalIncrement,
      milestoneInterval: _repMilestoneInterval,
      autoIncreaseEnabled: enableRepGoalAutoIncrease,
    );

    _holdGoalConfig = HoldGoalConfig(
      initialGoal: initialMaxHoldTimeGoal ?? _defaultMaxHoldTimeGoal,
      defaultGoal: _defaultMaxHoldTimeGoal,
      incrementStep: _holdGoalIncrementStep,
      minValidHoldTime: GluteBridgeTracker.minHoldTimeForRep,
      autoIncreaseEnabled: enableHoldGoalAutoIncrease,
    );

    _timedGoalFeedbackManager =
        TimedFeedbackManager(displayDuration: const Duration(seconds: 3));

    _orientationService = OrientationService(
      isOrientationCheckEnabled: _isOrientationCheckEnabled,
      minFramesForDetection: _minFramesForPositionDetection,
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

  int get totalSetGoal => _repGoalConfig.currentGoal;
  set totalSetGoal(int? value) {
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

  static double get allTimeMaxHoldDuration =>
      GluteBridgeTracker.allTimeMaxHoldDuration;
  static double get correctHoldTimeGoalDisplay =>
      GluteBridgeTracker.correctHoldTimeGoal;

  bool _isErrorFeedback(FeedbackType type) {
    return type == FeedbackType.errorModelNotReady ||
        type == FeedbackType.errorPredictionFailed ||
        type == FeedbackType.errorNoPersonDetected;
  }

  bool _isSetupIssueFeedback(FeedbackType type) {
    return type.name.startsWith("SETUP_") && type != FeedbackType.setupSuccess;
  }

  bool _isFormCorrectionFeedback(FeedbackType type) {
    return _isMajorFormCorrectionFeedback(type) ||
        _isMinorFormCorrectionFeedback(type);
  }

  bool _isMajorFormCorrectionFeedback(FeedbackType type) {
    return type.name.startsWith("EXERCISE_FORM_") ||
        type == FeedbackType.gluteBridgeAvoidArchingBack;
  }

  bool _isMinorFormCorrectionFeedback(FeedbackType type) {
    return type == FeedbackType.gluteBridgeSqueezeGlutes;
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

  PoseLandmark? _getLandmark(
      Pose pose, PoseLandmarkType type, double minVisibility) {
    final landmark = pose.landmarks[type];
    if (landmark != null && landmark.likelihood >= minVisibility) {
      return landmark;
    }
    return null;
  }

  GluteBridgeLandmarks _extractGluteBridgeLandmarks(Pose pose) {
    const double extractionVisibilityThreshold = 0.1;
    return GluteBridgeLandmarks(
      leftShoulder: _getLandmark(
          pose, PoseLandmarkType.leftShoulder, extractionVisibilityThreshold),
      rightShoulder: _getLandmark(
          pose, PoseLandmarkType.rightShoulder, extractionVisibilityThreshold),
      leftElbow: _getLandmark(
          pose, PoseLandmarkType.leftElbow, extractionVisibilityThreshold),
      rightElbow: _getLandmark(
          pose, PoseLandmarkType.rightElbow, extractionVisibilityThreshold),
      leftWrist: _getLandmark(
          pose, PoseLandmarkType.leftWrist, extractionVisibilityThreshold),
      rightWrist: _getLandmark(
          pose, PoseLandmarkType.rightWrist, extractionVisibilityThreshold),
      leftHip: _getLandmark(
          pose, PoseLandmarkType.leftHip, extractionVisibilityThreshold),
      rightHip: _getLandmark(
          pose, PoseLandmarkType.rightHip, extractionVisibilityThreshold),
      leftKnee: _getLandmark(
          pose, PoseLandmarkType.leftKnee, extractionVisibilityThreshold),
      rightKnee: _getLandmark(
          pose, PoseLandmarkType.rightKnee, extractionVisibilityThreshold),
      leftAnkle: _getLandmark(
          pose, PoseLandmarkType.leftAnkle, extractionVisibilityThreshold),
      rightAnkle: _getLandmark(
          pose, PoseLandmarkType.rightAnkle, extractionVisibilityThreshold),
      nose: _getLandmark(
          pose, PoseLandmarkType.nose, extractionVisibilityThreshold),
      leftEye: _getLandmark(
          pose, PoseLandmarkType.leftEye, extractionVisibilityThreshold),
      rightEye: _getLandmark(
          pose, PoseLandmarkType.rightEye, extractionVisibilityThreshold),
    );
  }

  bool _checkBodySideSupine(
      PoseLandmark? shoulder,
      PoseLandmark? hip,
      PoseLandmark? knee,
      PoseLandmark? ankle,
      PhysicalOrientation
          phoneOrientation, // Takes PhysicalOrientation directly
      {bool provideFeedback = false,
      String sideName = ""}) {
    if (shoulder == null || hip == null || knee == null || ankle == null) {
      if (provideFeedback) {
        _tempSupineFeedbackType =
            FeedbackType.setupSupineCheckIncompleteLandmarks;
        _tempSupineFeedbackSideName =
            sideName.isNotEmpty ? "$sideName side" : "your body";
      }
      return false;
    }

    double hipToKneeDist =
        GeometryUtils.calculateDistance(hip.x, hip.y, knee.x, knee.y);
    double kneeToAnkleDist =
        GeometryUtils.calculateDistance(knee.x, knee.y, ankle.x, ankle.y);
    double kneeToAnkleAngleToImgVertical =
        GeometryUtils.calculateAngleToVertical(
            knee.x, knee.y, ankle.x, ankle.y);
    double hipToKneeAngleToImgVertical =
        GeometryUtils.calculateAngleToVertical(hip.x, hip.y, knee.x, knee.y);

    double legSegmentRatio =
        (hipToKneeDist > 0.01) ? (kneeToAnkleDist / hipToKneeDist) : 0;
    bool kneeIsBent = legSegmentRatio >= 0.4 && legSegmentRatio <= 1.6;

    bool shinPositionedCorrectly = false;
    bool thighPositionedCorrectly = false;
    FeedbackType? shinFeedbackType;
    FeedbackType? thighFeedbackType;
    String shinOrientationName = "";

    switch (phoneOrientation) {
      case PhysicalOrientation.landscapeLeft:
      case PhysicalOrientation.landscapeRight:
      case PhysicalOrientation.flatScreenUp:
        shinPositionedCorrectly = kneeToAnkleAngleToImgVertical <= 45;
        shinFeedbackType = FeedbackType.setupSupineShinPositionIncorrect;
        shinOrientationName = "vertical";
        thighPositionedCorrectly = hipToKneeAngleToImgVertical >= 10 &&
            hipToKneeAngleToImgVertical <= 80; // Thigh angled up
        thighFeedbackType = FeedbackType.setupSupineThighPositionIncorrect;
        break;
      case PhysicalOrientation.portrait:
      case PhysicalOrientation.invertedPortrait:
        shinPositionedCorrectly = kneeToAnkleAngleToImgVertical >= 40;
        shinFeedbackType = FeedbackType.setupSupineShinPositionIncorrect;
        shinOrientationName = "horizontal";
        thighPositionedCorrectly = hipToKneeAngleToImgVertical >= 10 &&
            hipToKneeAngleToImgVertical <= 80; // Thigh angled up
        thighFeedbackType = FeedbackType.setupSupineThighPositionIncorrect;
        break;
      default:
        shinPositionedCorrectly = false;
        thighPositionedCorrectly = false;
        break;
    }

    if (provideFeedback) {
      _tempSupineFeedbackType = null;
      _tempSupineFeedbackSideName = sideName;
      _tempSupineFeedbackOrientationName = "";

      if (!kneeIsBent) {
        if (legSegmentRatio < 0.4 && hipToKneeDist > 0.01) {
          _tempSupineFeedbackType = FeedbackType.setupSupineKneesNotBentEnough;
          _tempSupineFeedbackSideName = "$sideName knee";
        } else if (legSegmentRatio > 1.6) {
          _tempSupineFeedbackType = FeedbackType.setupSupineKneesTooStraight;
          _tempSupineFeedbackSideName = "$sideName leg";
        } else {
          _tempSupineFeedbackType = FeedbackType.setupSupineAdjustGeneral;
          _tempSupineFeedbackSideName = "$sideName leg";
        }
      } else if (!shinPositionedCorrectly && shinFeedbackType != null) {
        _tempSupineFeedbackType = shinFeedbackType;
        _tempSupineFeedbackSideName = "$sideName lower leg";
        _tempSupineFeedbackOrientationName = shinOrientationName;
      } else if (!thighPositionedCorrectly && thighFeedbackType != null) {
        _tempSupineFeedbackType = thighFeedbackType;
        _tempSupineFeedbackSideName = "$sideName thigh";
      }
    }
    return kneeIsBent && shinPositionedCorrectly && thighPositionedCorrectly;
  }

  bool _updateAndCheckSupinePosition(
      GluteBridgeLandmarks landmarks, PhysicalOrientation physicalOrientation) {
    if (!_isSupineCheckEnabled) {
      _isUserSupine = true;
      _supinePositionCounter = _minFramesForPositionDetection;
      return true;
    }

    final currentPhoneOrientation = physicalOrientation;

    List<PoseLandmark?> essential = [
      landmarks.leftShoulder,
      landmarks.rightShoulder,
      landmarks.leftHip,
      landmarks.rightHip,
    ];
    if (essential.where((lm) => lm != null).length < 4) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.setupSupineCheckIncompleteLandmarks);
      _supinePositionCounter = math.max(0, _supinePositionCounter - 1);
      _isUserSupine = _supinePositionCounter >= _minFramesForPositionDetection;
      return _isUserSupine;
    }

    _tempSupineFeedbackType = null;
    _tempSupineFeedbackSideName = "";
    _tempSupineFeedbackOrientationName = "";

    bool leftSideOk = _checkBodySideSupine(
        landmarks.leftShoulder,
        landmarks.leftHip,
        landmarks.leftKnee,
        landmarks.leftAnkle,
        currentPhoneOrientation,
        provideFeedback: true,
        sideName: "left");
    bool rightSideOk = _checkBodySideSupine(
        landmarks.rightShoulder,
        landmarks.rightHip,
        landmarks.rightKnee,
        landmarks.rightAnkle,
        currentPhoneOrientation,
        provideFeedback: !leftSideOk,
        sideName: "right");

    bool isSupineCandidate = leftSideOk || rightSideOk;

    if (isSupineCandidate) {
      _supinePositionCounter = math.min(
          _minFramesForPositionDetection + 2, _supinePositionCounter + 1);
      if (_supinePositionCounter >= _minFramesForPositionDetection) {
        _isUserSupine = true;
        if (_currentTrainerFeedbackEvent.type.name
                .startsWith("SETUP_SUPINE_") ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.setupHoldHorizontalOrientation ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.neutralProcessing) {
          _currentTrainerFeedbackEvent =
              FeedbackEvent(FeedbackType.neutralProcessing);
        }
      } else {
        _isUserSupine = false;
        _currentTrainerFeedbackEvent =
            FeedbackEvent(FeedbackType.setupSupineHoldPosition);
      }
    } else {
      _supinePositionCounter = math.max(0, _supinePositionCounter - 1);
      _isUserSupine = false;
      if (_tempSupineFeedbackType != null) {
        Map<String, String> args = {'side_name': _tempSupineFeedbackSideName};
        if (_tempSupineFeedbackOrientationName.isNotEmpty) {
          args['orientation_name'] = _tempSupineFeedbackOrientationName;
        }
        _currentTrainerFeedbackEvent =
            FeedbackEvent(_tempSupineFeedbackType!, args: args);
      } else {
        _currentTrainerFeedbackEvent = FeedbackEvent(
            FeedbackType.setupSupineAdjustGeneral,
            args: {'side_name': 'position'});
      }
    }
    return _isUserSupine;
  }

  @override
  GluteBridgeResult processFrame(List<Pose> poses, Size imageSize) {
    if (poses.isEmpty ||
        PoseProcessingUtils.countVisibleLandmarks(
                poses.first,
                _personAspectRatioKeyLandmarks,
                _minLandmarkVisibilityForProcessing) <
            _minVisibleKeyLandmarksForProcessing) {
      _orientationService.reset();
      return _handleNoPersonOrNonVisible();
    }

    final pose = poses.first;
    final landmarksForSetup = _extractGluteBridgeLandmarks(pose);
    if (_currentTrainerFeedbackEvent.type != FeedbackType.setupInitialPrompt &&
        !_currentTrainerFeedbackEvent.type.name.startsWith("ERROR_")) {
      _currentTrainerFeedbackEvent =
          FeedbackEvent(FeedbackType.neutralProcessing);
    }

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
      _timedGoalFeedbackManager.clearEvent();
      _supinePositionCounter = 0;
      _isUserSupine = false;
      _tracker.resetActiveHold();
      return GluteBridgeResult(
          status: true,
          reps: _tracker.reps,
          holdDurationNow: _tracker.currentHoldDuration,
          trainerFeedback:
              _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent),
          trackerResult: GluteBridgeTrackerResult(
              status: true,
              isVisible: true,
              feedbackEvent: FeedbackEvent(FeedbackType.neutralProcessing)));
    }

    if (!_updateAndCheckSupinePosition(
        landmarksForSetup, _currentPhysicalOrientation)) {
      _timedGoalFeedbackManager.clearEvent();
      _tracker.resetActiveHold();
      return GluteBridgeResult(
          status: true,
          reps: _tracker.reps,
          holdDurationNow: _tracker.currentHoldDuration,
          trainerFeedback: _feedbackProvider.getFeedback(
              _currentTrainerFeedbackEvent), // Feedback from supine check
          trackerResult: GluteBridgeTrackerResult(
              status: true,
              isVisible: true,
              feedbackEvent: FeedbackEvent(FeedbackType.neutralProcessing)));
    }

    if (_orientationService.isUserCorrectlyOriented &&
        _isUserSupine &&
        (_currentTrainerFeedbackEvent.type == FeedbackType.neutralProcessing ||
            _currentTrainerFeedbackEvent.type.name
                .startsWith("SETUP_SUPINE_") ||
            _currentTrainerFeedbackEvent.type ==
                FeedbackType.setupHoldHorizontalOrientation)) {
      _currentTrainerFeedbackEvent = FeedbackEvent(FeedbackType.setupSuccess);
    }

    final trackerResult = _tracker.processLandmarks(pose, imageSize);

    FeedbackEvent effectiveFeedbackEventForDisplay;
    final rawTrackerFeedbackEvent = trackerResult.feedbackEvent;

    if (_isFormCorrectionFeedback(rawTrackerFeedbackEvent.type)) {
      if (rawTrackerFeedbackEvent.type == _lastDisplayedFormCorrectionType &&
          _lastDisplayedFormCorrectionTime != null &&
          DateTime.now().difference(_lastDisplayedFormCorrectionTime!) <
              _formCorrectionDebounceInterval) {
        effectiveFeedbackEventForDisplay =
            FeedbackEvent(FeedbackType.neutralProcessing);
      } else {
        effectiveFeedbackEventForDisplay = rawTrackerFeedbackEvent;
        _lastDisplayedFormCorrectionType = rawTrackerFeedbackEvent.type;
        _lastDisplayedFormCorrectionTime = DateTime.now();
      }
    } else {
      effectiveFeedbackEventForDisplay = rawTrackerFeedbackEvent;
      if (_lastDisplayedFormCorrectionType != null) {
        _lastDisplayedFormCorrectionType = null;
        _lastDisplayedFormCorrectionTime = null;
      }
    }

    final currentEffectiveTrackerFeedbackType =
        effectiveFeedbackEventForDisplay.type;

    if (_shouldInterruptTimedGoal(currentEffectiveTrackerFeedbackType)) {
      _timedGoalFeedbackManager.clearEvent();
    }

    ExerciseFeedback? finalGoalFeedback = _determineGoalFeedback(trackerResult);
    ExerciseFeedback? finalTrainerFeedback;

    if (finalGoalFeedback == null) {
      if (_currentTrainerFeedbackEvent.type == FeedbackType.setupSuccess &&
          (effectiveFeedbackEventForDisplay.type ==
                  FeedbackType.neutralProcessing ||
              effectiveFeedbackEventForDisplay.type ==
                  FeedbackType.exerciseDownPositionReady ||
              effectiveFeedbackEventForDisplay.type ==
                  FeedbackType.exerciseLiftHips)) {
        finalTrainerFeedback =
            _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent);
      } else if (_currentTrainerFeedbackEvent.type !=
              FeedbackType.setupSuccess &&
          _currentTrainerFeedbackEvent.type != FeedbackType.neutralProcessing) {
        finalTrainerFeedback =
            _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent);
      } else if (!_isFormCorrectionFeedback(
              effectiveFeedbackEventForDisplay.type) &&
          effectiveFeedbackEventForDisplay.type !=
              FeedbackType.neutralProcessing) {
        finalTrainerFeedback =
            _feedbackProvider.getFeedback(effectiveFeedbackEventForDisplay);
      } else if (_currentTrainerFeedbackEvent.type ==
              FeedbackType.neutralProcessing &&
          effectiveFeedbackEventForDisplay.type ==
              FeedbackType.neutralProcessing) {
        finalTrainerFeedback = _feedbackProvider.getFeedback(
            _tracker.reps == 0 && _lastTrackedReps == 0
                ? FeedbackEvent(FeedbackType.setupInitialPrompt)
                : FeedbackEvent(FeedbackType.neutralProcessing));
      }
    }

    ExerciseFeedback? formCorrectionDisplayFeedback;
    if (finalGoalFeedback == null &&
        _isFormCorrectionFeedback(effectiveFeedbackEventForDisplay.type) &&
        effectiveFeedbackEventForDisplay.type !=
            FeedbackType.neutralProcessing) {
      formCorrectionDisplayFeedback =
          _feedbackProvider.getFeedback(effectiveFeedbackEventForDisplay);
      finalTrainerFeedback = null;
    }

    return GluteBridgeResult(
      status: trackerResult.status,
      reps: _tracker.reps,
      holdDurationNow: _tracker.currentHoldDuration,
      trackerResult: trackerResult,
      feedback: finalGoalFeedback ?? formCorrectionDisplayFeedback,
      trainerFeedback: finalTrainerFeedback,
    );
  }

  GluteBridgeResult _handleNoPersonOrNonVisible() {
    _tracker.resetActiveHold();
    _supinePositionCounter = 0;
    _isUserSupine = false;
    _timedGoalFeedbackManager.clearEvent();
    _lastDisplayedFormCorrectionType = null;
    _lastDisplayedFormCorrectionTime = null;

    _currentTrainerFeedbackEvent =
        FeedbackEvent(FeedbackType.errorNoPersonDetected);

    return GluteBridgeResult(
      status: false,
      reps: _tracker.reps,
      holdDurationNow: 0.0,
      feedback: null,
      trainerFeedback:
          _feedbackProvider.getFeedback(_currentTrainerFeedbackEvent),
      trackerResult: GluteBridgeTrackerResult(
        status: true,
        isVisible: false,
        feedbackEvent: _currentTrainerFeedbackEvent,
      ),
    );
  }

  ExerciseFeedback? _determineGoalFeedback(
      GluteBridgeTrackerResult trackerResult) {
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
      GluteBridgeTrackerResult trackerResult) {
    FeedbackEvent? repGoalEvent = _checkRepetitionGoals();
    FeedbackEvent? holdGoalEvent = _checkHoldTimeGoals(trackerResult);

    return holdGoalEvent ?? repGoalEvent;
  }

  FeedbackEvent? _checkRepetitionGoals() {
    final currentReps = _tracker.reps;
    if (currentReps <= _lastTrackedReps) return null;

    _lastTrackedReps = currentReps;
    FeedbackEvent? newEvent;

    if (currentReps == _repGoalConfig.currentGoal) {
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
    } else if (currentReps > _repGoalConfig.currentGoal) {
      if (!_repGoalConfig.autoIncreaseEnabled ||
          currentReps == _repGoalConfig.currentGoal + 1) {
        newEvent = FeedbackEvent(FeedbackType.goalRepExceeded, args: {
          'reps_over_count':
              (currentReps - _repGoalConfig.currentGoal).toString()
        });
      }
    } else if (currentReps > 0 &&
        currentReps % _repGoalConfig.milestoneInterval == 0) {
      newEvent = FeedbackEvent(FeedbackType.goalRepMilestone,
          args: {'reps_milestone': currentReps.toString()});
    }
    return newEvent;
  }

  FeedbackEvent? _checkHoldTimeGoals(GluteBridgeTrackerResult trackerResult) {
    final currentMaxHoldDurationInRep = trackerResult.maxHoldDuration;
    final activeEvent = _timedGoalFeedbackManager.getActiveEvent();
    final isCurrentHoldGoalEventActive = activeEvent != null &&
        (activeEvent.type == FeedbackType.goalHoldTimeMet ||
            activeEvent.type == FeedbackType.goalHoldTimeMetNewGoal) &&
        (activeEvent.args?['target_hold_s'] ==
                "${_holdGoalConfig.currentGoal.toStringAsFixed(1)}s" ||
            activeEvent.args?['new_target_hold_s'] ==
                "${_holdGoalConfig.currentGoal.toStringAsFixed(1)}s");

    if (currentMaxHoldDurationInRep < _holdGoalConfig.currentGoal ||
        isCurrentHoldGoalEventActive ||
        currentMaxHoldDurationInRep <= _holdGoalConfig.minValidHoldTime) {
      return null;
    }

    HapticFeedback.mediumImpact();

    double previousGoal = _holdGoalConfig.currentGoal;
    Map<String, dynamic> holdArgs = {
      'target_hold_s': "${previousGoal.toStringAsFixed(1)}s",
      'actual_hold_s': "${currentMaxHoldDurationInRep.toStringAsFixed(1)}s"
    };
    FeedbackType holdFeedbackType = FeedbackType.goalHoldTimeMet;

    if (_holdGoalConfig.increaseGoal(currentMaxHoldDurationInRep)) {
      holdArgs['new_target_hold_s'] =
          "${_holdGoalConfig.currentGoal.toStringAsFixed(1)}s";
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

    _lastTrackedReps = 0;
    _timedGoalFeedbackManager.clearEvent();

    _lastDisplayedFormCorrectionType = null;
    _lastDisplayedFormCorrectionTime = null;

    _orientationService.reset();
    _isUserSupine = false;
    _supinePositionCounter = 0;
    _currentTrainerFeedbackEvent =
        FeedbackEvent(FeedbackType.setupInitialPrompt);
    _currentPhysicalOrientation = PhysicalOrientation.unknown;
  }

  void dispose() {
    _orientationService.dispose();
    log("GluteBridgeTrainer disposed, accelerometer listener cancelled.");
  }

  static final Set<FeedbackType> _painterIncorrectFormIndicators = {
    FeedbackType.exerciseFormUnclearAdjust,
    FeedbackType.exerciseFormUnclearWasUp,
    FeedbackType.gluteBridgeAvoidArchingBack,
    FeedbackType.gluteBridgeSqueezeGlutes,
    FeedbackType.setupSupineKneesNotBentEnough,
    FeedbackType.setupSupineKneesTooStraight,
    FeedbackType.setupSupineShinPositionIncorrect,
    FeedbackType.setupSupineThighPositionIncorrect,
  };

  @override
  BaseExercisePainter getPainter(List<Pose> poses, Size absoluteImageSize,
      InputImageRotation rotation, bool isFrontCamera) {
    bool isFormVisuallyCorrect = true;
    final GluteBridgeState currentTrackerVisualState = _tracker.state;

    if (poses.isNotEmpty) {
      if (_orientationService.isUserCorrectlyOriented && _isUserSupine) {
        // Check OrientationService state
        if (_painterIncorrectFormIndicators
            .contains(_currentTrainerFeedbackEvent.type)) {
          isFormVisuallyCorrect = false;
        }
      } else {
        isFormVisuallyCorrect = false;
      }
    }

    return GluteBridgePosePainter(
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
