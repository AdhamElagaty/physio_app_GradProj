import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../../../../core/utils/geometry_utils.dart';
import '../../../core/abstractions/feature_extractor.dart';
import '../../../core/utils/angle_smoothing.dart';
import '../entities/glute_bridge_landmarks.dart';

class GluteBridgeFeatureExtractor implements FeatureExtractor {
  final AngleSmoothing _smoother;

  List<double> _getCoords(PoseLandmark? lm) {
    if (lm == null || lm.likelihood < 0.1) return [0.0, 0.0];
    return [lm.x, lm.y];
  }

  GluteBridgeFeatureExtractor() : _smoother = AngleSmoothing(windowSize: 5);

  @override
  List<double> extractFeatures(Map<String, dynamic> landmarksData) {
    final landmarks = landmarksData['landmarks'] as GluteBridgeLandmarks;

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

    final features = <double>[
      // Elbow angles
      GeometryUtils.calculateAngle(lShoulder, lElbow, lWrist),
      GeometryUtils.calculateAngle(rShoulder, rElbow, rWrist),
      // Shoulder angles (elbow-shoulder-hip)
      GeometryUtils.calculateAngle(lElbow, lShoulder, lHip),
      GeometryUtils.calculateAngle(rElbow, rShoulder, rHip),
      // Hip angles (shoulder-hip-knee)
      GeometryUtils.calculateAngle(lShoulder, lHip, lKnee),
      GeometryUtils.calculateAngle(rShoulder, rHip, rKnee),
      // Knee angles (hip-knee-ankle)
      GeometryUtils.calculateAngle(lHip, lKnee, lAnkle),
      GeometryUtils.calculateAngle(rHip, rKnee, rAnkle),
      // Body align angles (shoulder-hip-ankle)
      GeometryUtils.calculateAngle(lShoulder, lHip, lAnkle),
      GeometryUtils.calculateAngle(rShoulder, rHip, rAnkle),
      // Hip deviation (distance from hip to line shoulder-knee)
      GeometryUtils.distancePointToLineSegment(lHip, lShoulder, lKnee),
      GeometryUtils.distancePointToLineSegment(rHip, rShoulder, rKnee),
      // Shoulder-hip Y diff (abs(shoulder.y - hip.y))
      (lShoulder[1] != 0.0 && lHip[1] != 0.0)
          ? (lShoulder[1] - lHip[1]).abs()
          : 0.0,
      (rShoulder[1] != 0.0 && rHip[1] != 0.0)
          ? (rShoulder[1] - rHip[1]).abs()
          : 0.0,
      // Hip-ankle Y diff (abs(hip.y - ankle.y))
      (lHip[1] != 0.0 && lAnkle[1] != 0.0) ? (lHip[1] - lAnkle[1]).abs() : 0.0,
      (rHip[1] != 0.0 && rAnkle[1] != 0.0) ? (rHip[1] - rAnkle[1]).abs() : 0.0,
      // Torso length (distance shoulder-hip)
      GeometryUtils.calculateDistanceList(lShoulder, lHip),
      GeometryUtils.calculateDistanceList(rShoulder, rHip),
      // Leg length (distance hip-ankle)
      GeometryUtils.calculateDistanceList(lHip, lAnkle),
      GeometryUtils.calculateDistanceList(rHip, rAnkle),
    ];

    final cleanedFeatures = features.map((f) => f.isNaN ? 0.0 : f).toList();

    _smoother.addAngles(cleanedFeatures);
    return _smoother.getSmoothedAngles();
  }

  void reset() {
    _smoother.reset();
  }
}
