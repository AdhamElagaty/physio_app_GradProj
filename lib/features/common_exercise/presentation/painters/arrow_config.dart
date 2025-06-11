import 'dart:math';

import 'package:flutter/material.dart';

class ArrowConfig {
  final double length;
  final double angle; // in radians
  final Paint paint;
  final double arrowheadLength;
  final double arrowheadAngle; // in radians

  ArrowConfig({
    required this.length,
    required this.angle,
    required this.paint,
    this.arrowheadLength = 10.0,
    this.arrowheadAngle = pi / 6, // 30 degrees
  });
}