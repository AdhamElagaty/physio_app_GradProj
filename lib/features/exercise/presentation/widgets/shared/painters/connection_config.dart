import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ConnectionConfig {
  final PoseLandmarkType type1;
  final PoseLandmarkType type2;
  final Paint paint;

  ConnectionConfig(this.type1, this.type2, this.paint);
}