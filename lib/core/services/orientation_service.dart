import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:gradproject/core/utils/device_orientation_utils/device_orientation_utils.dart';
import 'package:gradproject/core/utils/device_orientation_utils/physical_orientation.dart';
import 'package:gradproject/core/utils/pose_processing_utils.dart';
import 'package:gradproject/features/common_exercise/domain/entities/feedback_event.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'orientation/user_desired_orientation.dart';
import 'orientation/orientation_check_result.dart';
import 'orientation/orientation_thresholds.dart';
import 'orientation/orientation_feedback_types.dart';

class OrientationService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  AccelerometerEvent? _lastAccelerometerEvent;
  bool _isAccelerometerInitialized = false;
  int _orientationDetectionCounter = 0;
  bool _internalIsUserCorrectlyOrientedState = false;

  final bool _isOrientationCheckEnabled;
  final int _minFramesForDetection;

  OrientationService({
    bool isOrientationCheckEnabled = true,
    int minFramesForDetection = 3,
  })  : _isOrientationCheckEnabled = isOrientationCheckEnabled,
        _minFramesForDetection = minFramesForDetection {
    _initializeAccelerometer();
  }

  void _initializeAccelerometer() {
    if (!_isOrientationCheckEnabled) {
      log("OrientationService: Accelerometer initialization skipped as orientation check is disabled.");
      _isAccelerometerInitialized =
          true; // Mark as initialized to allow flow without accelerometer
      return;
    }
    if (_isAccelerometerInitialized && _accelerometerSubscription != null)
      return;
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (AccelerometerEvent event) {
          _lastAccelerometerEvent = event;
          if (!_isAccelerometerInitialized) _isAccelerometerInitialized = true;
        },
        onError: (e) {
          log("OrientationService Accel Error: $e", error: e);
          _lastAccelerometerEvent = null;
        },
        cancelOnError: false,
      );
      _isAccelerometerInitialized = true;
    } catch (e) {
      log("OrientationService Accel Init Fail: $e", error: e);
      _isAccelerometerInitialized = false;
    }
  }

  bool get isUserCorrectlyOriented => _internalIsUserCorrectlyOrientedState;

  OrientationCheckResult checkOrientation({
    required Pose pose,
    required UserDesiredOrientation desiredUserOrientation,
    required List<PoseLandmarkType> personAspectRatioKeyLandmarks,
    required double minLandmarkVisibilityForAspectRatio,
    required OrientationThresholds thresholds,
    required OrientationFeedbackTypes feedbackTypes,
  }) {
    PhysicalOrientation physicalOrientation = PhysicalOrientation.unknown;

    if (!_isOrientationCheckEnabled) {
      _internalIsUserCorrectlyOrientedState = true;
      _orientationDetectionCounter = _minFramesForDetection;
      return OrientationCheckResult(
          true, FeedbackEvent(feedbackTypes.setupSuccess), physicalOrientation);
    }

    if (!_isAccelerometerInitialized || _lastAccelerometerEvent == null) {
      _initializeAccelerometer();
      if (!_isAccelerometerInitialized || _lastAccelerometerEvent == null) {
        _orientationDetectionCounter =
            math.max(0, _orientationDetectionCounter - 1);
        _internalIsUserCorrectlyOrientedState =
            _orientationDetectionCounter >= _minFramesForDetection;
        return OrientationCheckResult(
            _internalIsUserCorrectlyOrientedState,
            FeedbackEvent(feedbackTypes.setupPhoneAccelerometerWait),
            physicalOrientation);
      }
    }

    physicalOrientation = DeviceOrientationUtils.getPhonePhysicalOrientation(
        _lastAccelerometerEvent!); // Assign here
    final double? personAspectRatio =
        PoseProcessingUtils.calculatePersonAspectRatioInImage(pose,
            personAspectRatioKeyLandmarks, minLandmarkVisibilityForAspectRatio);

    if (personAspectRatio == null) {
      _orientationDetectionCounter =
          math.max(0, _orientationDetectionCounter - 1);
      _internalIsUserCorrectlyOrientedState =
          _orientationDetectionCounter >= _minFramesForDetection;
      return OrientationCheckResult(
          _internalIsUserCorrectlyOrientedState,
          FeedbackEvent(feedbackTypes.setupVisibilityPartial),
          physicalOrientation);
    }

    bool worldOrientationConditionMet = false;
    String guidanceMessage = "";

    switch (physicalOrientation) {
      case PhysicalOrientation.portrait:
      case PhysicalOrientation.invertedPortrait:
        if (desiredUserOrientation == UserDesiredOrientation.vertical) {
          worldOrientationConditionMet =
              personAspectRatio < thresholds.portrait;
          if (!worldOrientationConditionMet)
            guidanceMessage =
                "Stand upright, ensuring your body is vertical in the camera when your phone is upright.";
        } else {
          worldOrientationConditionMet =
              personAspectRatio > thresholds.portrait;
          if (!worldOrientationConditionMet)
            guidanceMessage =
                "Lie down so your body is horizontal in the camera when your phone is upright.";
        }
        break;
      case PhysicalOrientation.landscapeLeft:
      case PhysicalOrientation.landscapeRight:
        if (desiredUserOrientation == UserDesiredOrientation.vertical) {
          worldOrientationConditionMet =
              personAspectRatio > thresholds.landscape;
          if (!worldOrientationConditionMet)
            guidanceMessage =
                "Stand upright. With phone sideways, you should appear wider than tall in camera.";
        } else {
          worldOrientationConditionMet =
              personAspectRatio < thresholds.landscape;
          if (!worldOrientationConditionMet)
            guidanceMessage =
                "Lie down so your body is horizontal in the camera when your phone is sideways.";
        }
        break;
      case PhysicalOrientation.flatScreenUp:
        if (desiredUserOrientation == UserDesiredOrientation.vertical) {
          worldOrientationConditionMet =
              personAspectRatio < thresholds.flatScreenUp;
          if (!worldOrientationConditionMet)
            guidanceMessage =
                "Stand upright. With phone flat (screen up), you should appear taller than wide.";
        } else {
          worldOrientationConditionMet =
              personAspectRatio > thresholds.flatScreenUp;
          if (!worldOrientationConditionMet)
            guidanceMessage =
                "Lie down so your body is horizontal in the camera when your phone is flat (screen up).";
        }
        break;
      case PhysicalOrientation.flatScreenDown:
        guidanceMessage =
            "Is the camera blocked? Please turn your phone screen-up so I can see you.";
        worldOrientationConditionMet = false;
        break;
      case PhysicalOrientation.unknown:
        guidanceMessage =
            "Your phone seems a bit wobbly. Try holding it steady.";
        worldOrientationConditionMet = false;
        break;
    }

    FeedbackEvent currentFeedbackEvent;
    if (worldOrientationConditionMet) {
      _orientationDetectionCounter = math.min(
          _minFramesForDetection + 2, _orientationDetectionCounter + 1);
      if (_orientationDetectionCounter >= _minFramesForDetection) {
        _internalIsUserCorrectlyOrientedState = true;
        currentFeedbackEvent = FeedbackEvent(feedbackTypes.setupSuccess);
      } else {
        _internalIsUserCorrectlyOrientedState = false;
        currentFeedbackEvent =
            FeedbackEvent(feedbackTypes.setupHoldOrientation);
      }
    } else {
      _orientationDetectionCounter =
          math.max(0, _orientationDetectionCounter - 1);
      _internalIsUserCorrectlyOrientedState = false;
      if (physicalOrientation == PhysicalOrientation.unknown ||
          physicalOrientation == PhysicalOrientation.flatScreenDown) {
        currentFeedbackEvent = FeedbackEvent(
            feedbackTypes.setupPhoneOrientationIssue,
            args: {'guidance': guidanceMessage});
      } else {
        currentFeedbackEvent = FeedbackEvent(
            feedbackTypes.setupPersonNotOriented,
            args: {'guidance': guidanceMessage});
      }
    }
    return OrientationCheckResult(_internalIsUserCorrectlyOrientedState,
        currentFeedbackEvent, physicalOrientation);
  }

  void reset() {
    _orientationDetectionCounter = 0;
    _internalIsUserCorrectlyOrientedState = false;

    if (_isOrientationCheckEnabled &&
        (_accelerometerSubscription == null || !_isAccelerometerInitialized)) {
      _initializeAccelerometer();
    }
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isAccelerometerInitialized = false;
    _lastAccelerometerEvent = null;
    log("OrientationService disposed, accelerometer listener cancelled.");
  }
}
