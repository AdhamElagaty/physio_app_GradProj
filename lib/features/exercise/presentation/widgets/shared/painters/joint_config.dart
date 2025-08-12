import 'package:flutter/material.dart';

import 'arc_config.dart';
import 'arrow_config.dart';

class JointConfig {
  final double radius;
  final Paint paint;
  final String? label;
  final ArrowConfig? arrow;
  final ArcConfig? arc;

  JointConfig(this.radius, this.paint, {this.label, this.arrow, this.arc});
}