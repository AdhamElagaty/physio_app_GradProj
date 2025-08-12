import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class GluteBridgeLandmarks {
  final PoseLandmark? leftShoulder;
  final PoseLandmark? rightShoulder;
  final PoseLandmark? leftElbow;
  final PoseLandmark? rightElbow;
  final PoseLandmark? leftWrist;
  final PoseLandmark? rightWrist;
  final PoseLandmark? leftHip;
  final PoseLandmark? rightHip;
  final PoseLandmark? leftKnee;
  final PoseLandmark? rightKnee;
  final PoseLandmark? leftAnkle;
  final PoseLandmark? rightAnkle;
  // For supine check
  final PoseLandmark? nose;
  final PoseLandmark? leftEye;
  final PoseLandmark? rightEye;


  GluteBridgeLandmarks({
    this.leftShoulder,
    this.rightShoulder,
    this.leftElbow,
    this.rightElbow,
    this.leftWrist,
    this.rightWrist,
    this.leftHip,
    this.rightHip,
    this.leftKnee,
    this.rightKnee,
    this.leftAnkle,
    this.rightAnkle,
    this.nose,
    this.leftEye,
    this.rightEye,
  });
}