import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class BicebArmLandmarks {
  final PoseLandmark shoulder;
  final PoseLandmark elbow;
  final PoseLandmark wrist;
  final PoseLandmark hip;
  
  BicebArmLandmarks({
    required this.shoulder,
    required this.elbow,
    required this.wrist,
    required this.hip
  });
}