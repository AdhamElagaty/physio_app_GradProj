import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../../core/utils/device_orientation_utils/physical_orientation.dart';
import '../../shared/painters/arrow_config.dart';
import '../../shared/painters/base_exercise_painter.dart';
import '../../shared/painters/connection_config.dart';
import '../../shared/painters/joint_config.dart';
import '../../../../domain/detection/exercises/plank/entities/plank_state.dart';

class PlankPosePainter extends BaseExercisePainter {
  final Map<PoseLandmarkType, JointConfig> _joints;
  final List<ConnectionConfig> _connections;
  final bool isFormCorrect;
  final PlankState trackerState;
  final PhysicalOrientation physicalOrientation;

  static final Color _neutralColor = Colors.grey.shade400;
  static final Color _correctStateColor = Colors.greenAccent;
  static final Color _highHipsColor = Colors.orangeAccent;
  static final Color _lowHipsColor = Colors.orangeAccent;
  static final Color _adjustingColor = Colors.yellowAccent;
  static final Color _notPlankingColor = Colors.blueGrey;
  static final Color _incorrectFormGenericColor = Colors.redAccent;

  static final Color _arrowUpColor = Colors.red.shade400;
  static final Color _arrowDownColor = Colors.red.shade400;

  PlankPosePainter(
    super.poses,
    super.absoluteImageSize,
    super.rotation,
    super.isFrontCamera, {
    this.isFormCorrect = true,
    this.trackerState = PlankState.neutral,
    required this.physicalOrientation,
  })  : _connections = _createConnections(trackerState, isFormCorrect),
        _joints =
            _createJoints(trackerState, isFormCorrect, physicalOrientation);

  static List<ConnectionConfig> _createConnections(
      PlankState trackerState, bool isFormCorrect) {
    Paint bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    Paint limbPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    Color baseColor = _neutralColor;
    if (!isFormCorrect &&
        trackerState != PlankState.neutral &&
        trackerState != PlankState.notPlanking) {
      baseColor = _incorrectFormGenericColor;
    } else {
      switch (trackerState) {
        case PlankState.correct:
          baseColor = _correctStateColor;
          break;
        case PlankState.highHips:
        case PlankState.lowHips:
          baseColor = isFormCorrect
              ? _adjustingColor
              : _incorrectFormGenericColor; // Show adjustment or error
          break;
        case PlankState.adjusting:
          baseColor = _adjustingColor;
          break;
        case PlankState.notPlanking:
          baseColor = _notPlankingColor;
          break;
        case PlankState.neutral:
          baseColor = _neutralColor;
          break;
      }
    }
    bodyPaint.color = baseColor.withValues(alpha: 0.8);
    limbPaint.color = baseColor;

    return [
      // Torso
      ConnectionConfig(PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, bodyPaint),

      // Arms (Shoulder to Elbow, Elbow to Wrist)
      ConnectionConfig(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, limbPaint),
      ConnectionConfig(PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightElbow, limbPaint),
      ConnectionConfig(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, limbPaint),
      ConnectionConfig(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, limbPaint),

      // Legs (Hip to Knee, Knee to Ankle)
      ConnectionConfig(
          PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, limbPaint),
      ConnectionConfig(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, limbPaint),
      ConnectionConfig(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, limbPaint),
      ConnectionConfig(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, limbPaint),
    ];
  }

  static Map<PoseLandmarkType, JointConfig> _createJoints(
      PlankState trackerState,
      bool isFormCorrect,
      PhysicalOrientation physicalOrientation) {
    Color baseJointColor = _neutralColor;
    Color highlightJointColor = _neutralColor.withAlpha(200);
    double radius = 5.0;
    ArrowConfig? hipArrow;

    if (!isFormCorrect &&
        trackerState != PlankState.neutral &&
        trackerState != PlankState.notPlanking) {
      baseJointColor = _incorrectFormGenericColor;
      highlightJointColor = _incorrectFormGenericColor.withValues(alpha: 0.8);
      radius = 6.0;
    } else {
      switch (trackerState) {
        case PlankState.correct:
          baseJointColor = _correctStateColor;
          highlightJointColor = _correctStateColor.withValues(alpha: 0.8);
          radius = 6.0;
          break;
        case PlankState.highHips:
          baseJointColor = _highHipsColor;
          highlightJointColor = _highHipsColor.withValues(alpha: 0.8);
          radius = 6.5;
          hipArrow = _getCorrectiveArrow(physicalOrientation,
              isUpward: false, color: _arrowDownColor);
          break;
        case PlankState.lowHips:
          baseJointColor = _lowHipsColor;
          highlightJointColor = _lowHipsColor.withValues(alpha: 0.8);
          radius = 6.5;
          hipArrow = _getCorrectiveArrow(physicalOrientation,
              isUpward: true, color: _arrowUpColor);
          break;
        case PlankState.adjusting:
          baseJointColor = _adjustingColor;
          highlightJointColor = _adjustingColor.withValues(alpha: 0.8);
          radius = 5.5;
          break;
        case PlankState.notPlanking:
          baseJointColor = _notPlankingColor;
          highlightJointColor = _notPlankingColor.withValues(alpha: 0.8);
          break;
        case PlankState.neutral:
          break;
      }
    }

    final defaultJointPaint = Paint()..color = baseJointColor;
    final torsoJointPaint = Paint()..color = highlightJointColor;

    Map<PoseLandmarkType, JointConfig> jointsMap = {
      // Key joints for plank alignment
      PoseLandmarkType.leftShoulder: JointConfig(radius, torsoJointPaint),
      PoseLandmarkType.rightShoulder: JointConfig(radius, torsoJointPaint),
      PoseLandmarkType.leftHip:
          JointConfig(radius + 1, torsoJointPaint, arrow: hipArrow),
      PoseLandmarkType.rightHip:
          JointConfig(radius + 1, torsoJointPaint, arrow: hipArrow),
      PoseLandmarkType.leftKnee: JointConfig(radius, defaultJointPaint),
      PoseLandmarkType.rightKnee: JointConfig(radius, defaultJointPaint),
      PoseLandmarkType.leftAnkle: JointConfig(radius, defaultJointPaint),
      PoseLandmarkType.rightAnkle: JointConfig(radius, defaultJointPaint),

      // Arms
      PoseLandmarkType.leftElbow: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.rightElbow: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.leftWrist: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.rightWrist: JointConfig(radius - 1, defaultJointPaint),

      PoseLandmarkType.nose: JointConfig(radius - 2, defaultJointPaint),
      PoseLandmarkType.leftEye: JointConfig(radius - 2, defaultJointPaint),
      PoseLandmarkType.rightEye: JointConfig(radius - 2, defaultJointPaint),
    };
    return jointsMap;
  }

  static ArrowConfig? _getCorrectiveArrow(
      PhysicalOrientation physicalOrientation,
      {required bool isUpward,
      required Color color}) {
    double arrowAngle = 0;

    switch (physicalOrientation) {
      case PhysicalOrientation.portrait:
      case PhysicalOrientation.flatScreenUp:
        arrowAngle = isUpward ? -math.pi / 2 : math.pi / 2;
        break;
      case PhysicalOrientation.invertedPortrait:
        arrowAngle = isUpward ? math.pi / 2 : -math.pi / 2;
        break;
      case PhysicalOrientation.landscapeLeft:
        arrowAngle = isUpward ? math.pi : 0;
        break;
      case PhysicalOrientation.landscapeRight:
        arrowAngle = isUpward ? 0 : math.pi;
        break;
      default:
        return null;
    }

    return ArrowConfig(
      length: 25,
      angle: arrowAngle,
      paint: Paint()
        ..color = color
        ..strokeWidth = 2.5,
      arrowheadLength: 8,
    );
  }

  @override
  List<ConnectionConfig> get connections => _connections;

  @override
  Map<PoseLandmarkType, JointConfig> get joints => _joints;
}
