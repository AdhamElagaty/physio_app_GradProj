import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseProcessingUtils {
  static PoseLandmark? getLandmark(
      Pose pose, PoseLandmarkType type, double visibilityThreshold) {
    final lm = pose.landmarks[type];
    return (lm != null && lm.likelihood >= visibilityThreshold) ? lm : null;
  }

  static int countVisibleLandmarks(
    Pose pose,
    List<PoseLandmarkType> landmarkTypes,
    double visibilityThreshold,
  ) {
    int visibleCount = 0;
    for (var type in landmarkTypes) {
      final lm = pose.landmarks[type];
      if (lm != null && lm.likelihood >= visibilityThreshold) {
        visibleCount++;
      }
    }
    return visibleCount;
  }

  static double? calculatePersonAspectRatioInImage(
      Pose pose, List<PoseLandmarkType> keyLandmarkTypes, double minLandmarkVisibilityForAspectRatio) {
    final visY = <double>[];
    final visX = <double>[];

    for (var type in keyLandmarkTypes) {
      final lm = pose.landmarks[type];
      if (lm != null && lm.likelihood > minLandmarkVisibilityForAspectRatio) {
        visY.add(lm.y);
        visX.add(lm.x);
      }
    }
    if (visY.length < 4) return null;

    final minY = visY.reduce(math.min);
    final maxY = visY.reduce(math.max);
    final minX = visX.reduce(math.min);
    final maxX = visX.reduce(math.max);
    final spanY = maxY - minY;
    final spanX = maxX - minX;

    if (spanX < 1.0) return (spanY > 1.0) ? double.infinity : null;
    return spanY / spanX;
  }
}