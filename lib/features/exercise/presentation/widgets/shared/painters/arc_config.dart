import 'package:flutter/material.dart';

class ArcConfig {
  final double startAngle;
  final double sweepAngle;
  final bool useCenter;
  final Paint paint;

  ArcConfig({
    required this.startAngle,
    required this.sweepAngle,
    required this.useCenter,
    required this.paint,
  });
}