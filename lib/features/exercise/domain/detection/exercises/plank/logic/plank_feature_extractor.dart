import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../../../core/utils/geometry_utils.dart';
import '../../../core/abstractions/feature_extractor.dart';
import '../../../core/utils/angle_smoothing.dart';
import '../entities/plank_landmarks.dart';

class PlankFeatureExtractor implements FeatureExtractor {
  final AngleSmoothing _smoother;

  List<double> _getCoords(PoseLandmark? lm) {
    if (lm == null || lm.likelihood < 0.1) return [0.0, 0.0];
    return [lm.x, lm.y];
  }

  PlankFeatureExtractor()
      : _smoother = AngleSmoothing(windowSize: 7); // Python script uses 7

  @override
  List<double> extractFeatures(Map<String, dynamic> landmarksData) {
    final landmarks = landmarksData['landmarks'] as PlankLandmarks;

    final lShoulder = _getCoords(landmarks.leftShoulder);
    final rShoulder = _getCoords(landmarks.rightShoulder);
    final lElbow = _getCoords(landmarks.leftElbow);
    final rElbow = _getCoords(landmarks.rightElbow);
    final lWrist = _getCoords(landmarks.leftWrist);
    final rWrist = _getCoords(landmarks.rightWrist);
    final lHip = _getCoords(landmarks.leftHip);
    final rHip = _getCoords(landmarks.rightHip);
    final lKnee = _getCoords(landmarks.leftKnee);
    final rKnee = _getCoords(landmarks.rightKnee);
    final lAnkle = _getCoords(landmarks.leftAnkle);
    final rAnkle = _getCoords(landmarks.rightAnkle);

    // Features based on your Python script's FEATURE_COLUMN_NAMES
    final features = <double>[
      // Elbow angles
      GeometryUtils.calculateAngle(
          lShoulder, lElbow, lWrist), // left_elbow_angle
      GeometryUtils.calculateAngle(
          rShoulder, rElbow, rWrist), // right_elbow_angle

      // Shoulder angles (elbow-shoulder-hip)
      GeometryUtils.calculateAngle(
          lElbow, lShoulder, lHip), // left_shoulder_angle
      GeometryUtils.calculateAngle(
          rElbow, rShoulder, rHip), // right_shoulder_angle

      // Hip angles (shoulder-hip-knee)
      GeometryUtils.calculateAngle(lShoulder, lHip, lKnee), // left_hip_angle
      GeometryUtils.calculateAngle(rShoulder, rHip, rKnee), // right_hip_angle

      // Knee angles (hip-knee-ankle)
      GeometryUtils.calculateAngle(lHip, lKnee, lAnkle), // left_knee_angle
      GeometryUtils.calculateAngle(rHip, rKnee, rAnkle), // right_knee_angle

      // Body align angles (shoulder-hip-ankle) - Crucial for plank
      GeometryUtils.calculateAngle(
          lShoulder, lHip, lAnkle), // left_body_align_angle
      GeometryUtils.calculateAngle(
          rShoulder, rHip, rAnkle), // right_body_align_angle

      // Hip deviation (distance from hip to line shoulder-knee)
      // As per your python script. If for plank this should be shoulder-ankle, the model needs to be trained accordingly.
      // Sticking to your script:
      GeometryUtils.distancePointToLineSegment(
          lHip, lShoulder, lKnee), // left_hip_deviation
      GeometryUtils.distancePointToLineSegment(
          rHip, rShoulder, rKnee), // right_hip_deviation

      // Shoulder-hip Y diff (abs(shoulder.y - hip.y))
      (lShoulder[1] != 0.0 && lHip[1] != 0.0)
          ? (lShoulder[1] - lHip[1]).abs()
          : 0.0, // shoulder_hip_y_diff_left
      (rShoulder[1] != 0.0 && rHip[1] != 0.0)
          ? (rShoulder[1] - rHip[1]).abs()
          : 0.0, // shoulder_hip_y_diff_right

      // Hip-ankle Y diff (abs(hip.y - ankle.y))
      (lHip[1] != 0.0 && lAnkle[1] != 0.0)
          ? (lHip[1] - lAnkle[1]).abs()
          : 0.0, // hip_ankle_y_diff_left
      (rHip[1] != 0.0 && rAnkle[1] != 0.0)
          ? (rHip[1] - rAnkle[1]).abs()
          : 0.0, // hip_ankle_y_diff_right

      // Torso length (distance shoulder-hip)
      GeometryUtils.calculateDistanceList(lShoulder, lHip), // torso_length_left
      GeometryUtils.calculateDistanceList(
          rShoulder, rHip), // torso_length_right

      // Leg length (distance hip-ankle)
      GeometryUtils.calculateDistanceList(lHip, lAnkle), // leg_length_left
      GeometryUtils.calculateDistanceList(rHip, rAnkle), // leg_length_right
    ];

    final cleanedFeatures = features.map((f) => f.isNaN ? 0.0 : f).toList();

    _smoother.addAngles(cleanedFeatures);
    return _smoother.getSmoothedAngles();
  }

  void reset() {
    _smoother.reset();
  }
}
