import '../../../../../core/utils/geometry_utils.dart';
import '../../../../common_exercise/domain/abstractions/feature_extractor.dart';
import '../../../../common_exercise/domain/utils/angle_smoothing.dart';

class BicepCurlFeatureExtractor implements FeatureExtractor {
  final String side;
  final AngleSmoothing _smoother;

  BicepCurlFeatureExtractor(this.side)
      : _smoother = AngleSmoothing(windowSize: 5);

  @override
  List<double> extractFeatures(Map<String, dynamic> landmarks) {
    final shoulderPoint = landmarks['shoulder'] as List<double>;
    final elbowPoint = landmarks['elbow'] as List<double>;
    final wristPoint = landmarks['wrist'] as List<double>;
    final hipPoint = landmarks['hip'] as List<double>;

    final elbowAngle =
        GeometryUtils.calculateAngle(shoulderPoint, elbowPoint, wristPoint);
    final shoulderAngle =
        GeometryUtils.calculateAngle(elbowPoint, shoulderPoint, hipPoint);

    _smoother.addAngles([elbowAngle, shoulderAngle]);
    return _smoother.getSmoothedAngles();
  }

  void reset() {
    _smoother.reset();
  }
}
