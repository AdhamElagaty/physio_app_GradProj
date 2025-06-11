import 'dart:math';

import 'package:gradproject/core/utils/device_orientation_utils/physical_orientation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DeviceOrientationUtils {
  static PhysicalOrientation getPhonePhysicalOrientation(
      AccelerometerEvent? event) {
    if (event == null) return PhysicalOrientation.unknown;

    final double x = event.x;
    final double y = event.y;
    final double z = event.z;
    final double absX = x.abs();
    final double absY = y.abs();
    final double absZ = z.abs();

    final double gravityMagnitude = sqrt(x * x + y * y + z * z);
    if (gravityMagnitude < 1.0) return PhysicalOrientation.unknown;

    final double dominantThresholdFactor = 0.75;
    final double minorThresholdFactor = 0.35;

    if (absZ / gravityMagnitude > dominantThresholdFactor &&
        absX / gravityMagnitude < minorThresholdFactor &&
        absY / gravityMagnitude < minorThresholdFactor) {
      return z > 0
          ? PhysicalOrientation.flatScreenUp
          : PhysicalOrientation.flatScreenDown;
    } else if (absY / gravityMagnitude > dominantThresholdFactor &&
        absX / gravityMagnitude < minorThresholdFactor &&
        absZ / gravityMagnitude < minorThresholdFactor) {
      return y > 0
          ? PhysicalOrientation.portrait
          : PhysicalOrientation.invertedPortrait;
    } else if (absX / gravityMagnitude > dominantThresholdFactor &&
        absY / gravityMagnitude < minorThresholdFactor &&
        absZ / gravityMagnitude < minorThresholdFactor) {
      return x > 0
          ? PhysicalOrientation.landscapeRight
          : PhysicalOrientation.landscapeLeft;
    }
    return PhysicalOrientation.unknown;
  }
}
