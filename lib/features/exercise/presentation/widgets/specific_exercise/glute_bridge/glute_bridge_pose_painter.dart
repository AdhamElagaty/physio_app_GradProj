import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../../../core/utils/device_orientation_utils/physical_orientation.dart';
import '../../../../domain/detection/exercises/glute_bridge/entities/glute_bridge_state.dart';
import '../../shared/painters/arrow_config.dart';
import '../../shared/painters/base_exercise_painter.dart';
import '../../shared/painters/connection_config.dart';
import '../../shared/painters/joint_config.dart';

class GluteBridgePosePainter extends BaseExercisePainter {
  final Map<PoseLandmarkType, JointConfig> _joints;
  final List<ConnectionConfig> _connections;
  final bool isFormCorrect;
  final GluteBridgeState trackerState;
  final PhysicalOrientation physicalOrientation;

  static final Color _neutralColor = Colors.grey.shade400;
  static final Color _upStateColor = Colors.greenAccent;
  static final Color _holdingStateColor = Colors.tealAccent;
  static final Color _downStateColor = Colors.lightBlueAccent;
  static final Color _incorrectFormColor = Colors.redAccent;

  static final Color _arrowUpColor = Colors.green;

  GluteBridgePosePainter(
    super.poses,
    super.absoluteImageSize,
    super.rotation,
    super.isFrontCamera, {
    this.isFormCorrect = true,
    this.trackerState = GluteBridgeState.neutral,
    required this.physicalOrientation, // Added
  })  : _connections = _createConnections(trackerState, isFormCorrect),
        _joints = _createJoints(
            trackerState, isFormCorrect, physicalOrientation); // Modified

  static List<ConnectionConfig> _createConnections(
      GluteBridgeState trackerState, bool isFormCorrect) {
    Paint bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    Paint legPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    if (!isFormCorrect && trackerState != GluteBridgeState.neutral) {
      bodyPaint.color = _incorrectFormColor.withValues(alpha: 0.7);
      legPaint.color = _incorrectFormColor;
    } else {
      switch (trackerState) {
        case GluteBridgeState.up:
          bodyPaint.color = _upStateColor.withValues(alpha: 0.7);
          legPaint.color = _upStateColor;
          break;
        case GluteBridgeState.holding:
          bodyPaint.color = _holdingStateColor.withValues(alpha: 0.8);
          legPaint.color = _holdingStateColor;
          legPaint.strokeWidth = 5.0; // Emphasize hold
          break;
        case GluteBridgeState.down:
          bodyPaint.color = _downStateColor.withValues(alpha: 0.7);
          legPaint.color = _downStateColor;
          break;
        case GluteBridgeState.neutral:
      }
    }

    return [
      ConnectionConfig(PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, bodyPaint),
      ConnectionConfig(
          PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, legPaint),
      ConnectionConfig(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, legPaint),
      ConnectionConfig(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, legPaint),
      ConnectionConfig(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, legPaint),
    ];
  }

  static Map<PoseLandmarkType, JointConfig> _createJoints(
      GluteBridgeState trackerState,
      bool isFormCorrect,
      PhysicalOrientation physicalOrientation) {
    // Modified
    Color baseJointColor = _neutralColor;
    Color highlightJointColor = _neutralColor.withAlpha(200);
    double radius = 5.0;
    ArrowConfig? hipArrow;

    if (!isFormCorrect && trackerState != GluteBridgeState.neutral) {
      baseJointColor = _incorrectFormColor;
      highlightJointColor = _incorrectFormColor.withAlpha(220);
      radius = 6.0;
    } else {
      switch (trackerState) {
        case GluteBridgeState.up:
          baseJointColor = _upStateColor;
          highlightJointColor = _upStateColor.withAlpha(220);
          radius = 7.0;

          double? arrowAngle = 0;

          switch (physicalOrientation) {
            case PhysicalOrientation.landscapeLeft:
              arrowAngle = math.pi;
              break;
            case PhysicalOrientation.landscapeRight:
              arrowAngle = 0;
              break;
            case PhysicalOrientation.portrait:
              arrowAngle = -math.pi / 2;
              break;
            case PhysicalOrientation.invertedPortrait:
              arrowAngle = math.pi / 2;
              break;
            default:
              arrowAngle = null;
          }

          hipArrow = arrowAngle != null
              ? ArrowConfig(
                  length: 25,
                  angle: arrowAngle,
                  paint: Paint()
                    ..color = _arrowUpColor
                    ..strokeWidth = 2.5,
                  arrowheadLength: 8,
                )
              : null;
          break;
        case GluteBridgeState.holding:
          baseJointColor = _holdingStateColor;
          highlightJointColor = _holdingStateColor.withAlpha(220);
          radius = 8.0;
          break;
        case GluteBridgeState.down:
          baseJointColor = _downStateColor;
          highlightJointColor = _downStateColor.withAlpha(220);
          radius = 6.0;
          break;
        case GluteBridgeState.neutral:
          break;
      }
    }

    final defaultJointPaint = Paint()..color = baseJointColor;
    final highlightJointPaint = Paint()..color = highlightJointColor;

    Map<PoseLandmarkType, JointConfig> jointsMap = {
      PoseLandmarkType.leftShoulder: JointConfig(radius, defaultJointPaint),
      PoseLandmarkType.rightShoulder: JointConfig(radius, defaultJointPaint),
      PoseLandmarkType.leftElbow: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.rightElbow: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.leftWrist: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.rightWrist: JointConfig(radius - 1, defaultJointPaint),
      PoseLandmarkType.leftHip:
          JointConfig(radius + 1, highlightJointPaint, arrow: hipArrow),
      PoseLandmarkType.rightHip:
          JointConfig(radius + 1, highlightJointPaint, arrow: hipArrow),
      PoseLandmarkType.leftKnee: JointConfig(radius + 1, highlightJointPaint),
      PoseLandmarkType.rightKnee: JointConfig(radius + 1, highlightJointPaint),
      PoseLandmarkType.leftAnkle: JointConfig(radius, defaultJointPaint),
      PoseLandmarkType.rightAnkle: JointConfig(radius, defaultJointPaint),
    };

    return jointsMap;
  }

  @override
  List<ConnectionConfig> get connections => _connections;

  @override
  Map<PoseLandmarkType, JointConfig> get joints => _joints;
}
