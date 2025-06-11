import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'connection_config.dart';
import 'joint_config.dart';
import 'pose_painter.dart';

abstract class BaseExercisePainter extends PosePainter {

  BaseExercisePainter(
    super.poses,
    super.absoluteImageSize,
    super.rotation,
    super.isFrontCamera,
  );

  List<ConnectionConfig> get connections;
  Map<PoseLandmarkType, JointConfig> get joints;

  @override
  void paint(Canvas canvas, Size size) {
    if (absoluteImageSize == Size.zero || size == Size.zero) return;

    for (final pose in poses) {
      pose.landmarks.forEach((type, landmark) {
        final jointConfig = joints[type];
        if (landmark.likelihood > 0.7 && jointConfig != null) {

        final center = _transform(Offset(landmark.x, landmark.y), size);
        final radius = jointConfig.radius;
        final paint = jointConfig.paint;

        canvas.drawCircle(center, radius, paint);

        if (jointConfig.arrow != null) {
          final arrowConfig = jointConfig.arrow!;
          final theta = arrowConfig.angle;
          final end = center + Offset(
            arrowConfig.length * cos(theta),
            arrowConfig.length * sin(theta),
          );
          
          canvas.drawLine(center, end, arrowConfig.paint);
          
          final leftAngle = theta + pi - arrowConfig.arrowheadAngle;
          final rightAngle = theta + pi + arrowConfig.arrowheadAngle;
          final leftPoint = end + Offset(
            arrowConfig.arrowheadLength * cos(leftAngle),
            arrowConfig.arrowheadLength * sin(leftAngle),
          );
          final rightPoint = end + Offset(
            arrowConfig.arrowheadLength * cos(rightAngle),
            arrowConfig.arrowheadLength * sin(rightAngle),
          );
          
          canvas.drawLine(end, leftPoint, arrowConfig.paint);
          canvas.drawLine(end, rightPoint, arrowConfig.paint);
        }
          
        if (jointConfig.arc != null) {
          final arc = jointConfig.arc!;
          final rect = Rect.fromCircle(center: center, radius: radius);
          canvas.drawArc(
            rect,
            arc.startAngle,
            arc.sweepAngle,
            arc.useCenter,
            arc.paint,
          );
        }

        if (jointConfig.label != null) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: jointConfig.label,
              style: TextStyle(
                color: paint.color.withValues(alpha: 0.8),
                fontSize: 12.0,
              ),
            ),
            textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              _transform(Offset(landmark.x, landmark.y), size) +
                  Offset(-textPainter.width / 2, -textPainter.height / 2),
            );
          }
        }
      });

      // Draw connections
      for (final connection in connections) {
        final joint1 = pose.landmarks[connection.type1];
        final joint2 = pose.landmarks[connection.type2];
        if (joint1 != null &&
            joint2 != null &&
            joint1.likelihood > 0.5 &&
            joint2.likelihood > 0.5) {
          canvas.drawLine(
            _transform(Offset(joint1.x, joint1.y), size),
            _transform(Offset(joint2.x, joint2.y), size),
            connection.paint,
          );
        }
      }
    }
  }

  Offset _transform(Offset point, Size size) {
    final double imageWidth = rotation == InputImageRotation.rotation90deg ||
            rotation == InputImageRotation.rotation270deg
        ? absoluteImageSize.height
        : absoluteImageSize.width;
    final double imageHeight = rotation == InputImageRotation.rotation90deg ||
            rotation == InputImageRotation.rotation270deg
        ? absoluteImageSize.width
        : absoluteImageSize.height;

    if (imageWidth == 0 || imageHeight == 0) return Offset.zero;

    final double scaleX = size.width / imageWidth;
    final double scaleY = size.height / imageHeight;
    final double scale = max(scaleX, scaleY);

    final double scaledWidth = imageWidth * scale;
    final double scaledHeight = imageHeight * scale;

    final double offsetX = (size.width - scaledWidth) / 2.0;
    final double offsetY = (size.height - scaledHeight) / 2.0;

    double x = point.dx;
    double y = point.dy;

    double translatedX;
    double translatedY;

    switch (rotation) {
      case InputImageRotation.rotation90deg:
        translatedX = absoluteImageSize.height - y;
        translatedY = x;
        break;
      case InputImageRotation.rotation180deg:
        translatedX = absoluteImageSize.width - x;
        translatedY = absoluteImageSize.height - y;
        break;
      case InputImageRotation.rotation270deg:
        translatedX = y;
        translatedY = absoluteImageSize.width - x;
        break;
      case InputImageRotation.rotation0deg:
        translatedX = x;
        translatedY = y;
        break;
    }

    translatedX *= scale;
    translatedY *= scale;

    translatedX += offsetX;
    translatedY += offsetY;

    if (isFrontCamera) {
      translatedX = size.width - translatedX;
    }
    return Offset(translatedX, translatedY);
  }
}