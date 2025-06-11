import 'dart:math' as math;

import 'device_orientation_utils/physical_orientation.dart';

class GeometryUtils {
  static double calculateDistance(double x1, double y1, double x2, double y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }

  static double calculateAngleToVertical(double x1, double y1, double x2, double y2) {
    double dy = y2 - y1;
    double dx = x2 - x1;

    if (dx == 0 && dy == 0) return 0;

    double angleRad = math.atan2(dx.abs(), dy.abs());

    return angleRad * (180 / math.pi);
  }

  static double calculateDistanceList(List<double> p1, List<double> p2) {
    if ((p1[0] == 0.0 && p1[1] == 0.0) || (p2[0] == 0.0 && p2[1] == 0.0)) {
      return 0.0;
    }
    return math.sqrt(math.pow(p2[0] - p1[0], 2) + math.pow(p2[1] - p1[1], 2));
  }

  static double calculateAngle(List<double> p1, List<double> pVertex, List<double> p3) {
    if ((p1[0] == 0.0 && p1[1] == 0.0) ||
        (pVertex[0] == 0.0 && pVertex[1] == 0.0) ||
        (p3[0] == 0.0 && p3[1] == 0.0)) {
      return 0.0;
    }

    final vectorVertexP1 = [p1[0] - pVertex[0], p1[1] - pVertex[1]];
    final vectorVertexP3 = [p3[0] - pVertex[0], p3[1] - pVertex[1]];

    final dotProduct = vectorVertexP1[0] * vectorVertexP3[0] + vectorVertexP1[1] * vectorVertexP3[1];
    final magnitudeVertexP1 = math.sqrt(math.pow(vectorVertexP1[0], 2) + math.pow(vectorVertexP1[1], 2));
    final magnitudeVertexP3 = math.sqrt(math.pow(vectorVertexP3[0], 2) + math.pow(vectorVertexP3[1], 2));

    if (magnitudeVertexP1 == 0 || magnitudeVertexP3 == 0) {
      return 0.0;
    }

    var cosine = dotProduct / (magnitudeVertexP1 * magnitudeVertexP3);
    cosine = cosine.clamp(-1.0, 1.0);
    final angleRad = math.acos(cosine);
    return angleRad * (180 / math.pi);
  }

  static double distancePointToLineSegment(List<double> pt, List<double> segmentP1, List<double> segmentP2) {
    if ((pt[0] == 0.0 && pt[1] == 0.0) ||
        (segmentP1[0] == 0.0 && segmentP1[1] == 0.0) ||
        (segmentP2[0] == 0.0 && segmentP2[1] == 0.0)) {
      return 0.0;
    }

    final double dxLine = segmentP2[0] - segmentP1[0];
    final double dyLine = segmentP2[1] - segmentP1[1];
    
    final double lineLengthSq = dxLine * dxLine + dyLine * dyLine;

    if (lineLengthSq == 0.0) {
      return calculateDistanceList(pt, segmentP1);
    }

    double t = ((pt[0] - segmentP1[0]) * dxLine + (pt[1] - segmentP1[1]) * dyLine) / lineLengthSq;
    t = t.clamp(0.0, 1.0);

    final List<double> projection = [
      segmentP1[0] + t * dxLine,
      segmentP1[1] + t * dyLine,
    ];
    
    return calculateDistanceList(pt, projection);
  }

  static double calculateFaceOrientation(
      List<double>? leftEye, 
      List<double>? rightEye, 
      List<double>? nose,
      PhysicalOrientation deviceOrientation) {
    
    if (leftEye == null || rightEye == null || nose == null) {
      return 0.0;
    }

    final eyeMidpoint = [(leftEye[0] + rightEye[0]) / 2, (leftEye[1] + rightEye[1]) / 2];
    
    final eyeToNose = [nose[0] - eyeMidpoint[0], nose[1] - eyeMidpoint[1]];
    
    switch (deviceOrientation) {
      case PhysicalOrientation.landscapeLeft:
      case PhysicalOrientation.landscapeRight:
      case PhysicalOrientation.flatScreenUp:

        if (eyeToNose[1] > 0.02) return 1.0; 
        if (eyeToNose[1] < -0.02) return -1.0;
        break;
        
      case PhysicalOrientation.portrait:
      case PhysicalOrientation.invertedPortrait:
        if (eyeToNose[0].abs() > 0.02) {
          if (eyeToNose[1] > 0.01) return 1.0;
          if (eyeToNose[1] < -0.01) return -1.0;
        }
        break;
        
      default:
        break;
    }
    
    return 0.0;
  }

  static double calculateEyeLineAngle(List<double>? leftEye, List<double>? rightEye) {
    if (leftEye == null || rightEye == null) return 0.0;
    
    final dx = rightEye[0] - leftEye[0];
    final dy = rightEye[1] - leftEye[1];
    
    if (dx == 0 && dy == 0) return 0.0;
    
    return math.atan2(dy, dx) * (180 / math.pi);
  }
}