import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../shared/painters/base_exercise_painter.dart';
import '../../shared/painters/connection_config.dart';
import '../../shared/painters/joint_config.dart';

class BicepCurlPosePainter extends BaseExercisePainter {
  final List<ConnectionConfig> _connections;
  final Map<PoseLandmarkType, JointConfig> _joints;
  bool isCorrectLeftElbow;
  bool isCorrectRightElbow;

  BicepCurlPosePainter(
    super.poses,
    super.absoluteImageSize,
    super.rotation,
    super.isFrontCamera, {
    this.isCorrectLeftElbow = false,
    this.isCorrectRightElbow = false,
  })  : _connections = _createConnections(),
        _joints = _createJoints(isCorrectLeftElbow, isCorrectRightElbow);

  static List<ConnectionConfig> _createConnections() {
    final armLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    final bodyLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.cyan;

    return [
      ConnectionConfig(PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftElbow, armLinePaint),
      ConnectionConfig(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, armLinePaint),
      ConnectionConfig(PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightElbow, armLinePaint),
      ConnectionConfig(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist,
          armLinePaint),
      ConnectionConfig(PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder, bodyLinePaint),
      ConnectionConfig(
          PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, bodyLinePaint),
      ConnectionConfig(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip,
          bodyLinePaint),
      ConnectionConfig(PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightHip, bodyLinePaint),
    ];
  }

  static Map<PoseLandmarkType, JointConfig> _createJoints(
      bool isCorrectLeftElbow, bool isCorrectRightElbow) {
    final JointConfig defaultJointConfig = JointConfig(
      6.0,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 5.0
        ..color = Color(0xffb8edff),
    );

    final JointConfig correctElbowJointConfig = JointConfig(
      8.0,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 5.0
        ..color = Colors.greenAccent,
    );

    final JointConfig inCorrectElbowJointConfig = JointConfig(
      8.0,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 5.0
        ..color = Colors.redAccent,
    );
    return {
      PoseLandmarkType.leftShoulder: defaultJointConfig,
      PoseLandmarkType.leftWrist: defaultJointConfig,
      PoseLandmarkType.rightShoulder: defaultJointConfig,
      PoseLandmarkType.rightWrist: defaultJointConfig,
      PoseLandmarkType.leftHip: defaultJointConfig,
      PoseLandmarkType.rightHip: defaultJointConfig,
      PoseLandmarkType.leftElbow: isCorrectLeftElbow
          ? correctElbowJointConfig
          : inCorrectElbowJointConfig,
      PoseLandmarkType.rightElbow: isCorrectRightElbow
          ? correctElbowJointConfig
          : inCorrectElbowJointConfig,
    };
  }

  @override
  List<ConnectionConfig> get connections => _connections;

  @override
  Map<PoseLandmarkType, JointConfig> get joints => _joints;
}
