import 'package:flutter/material.dart';

class ExerciseFeedbackColor {
  final Color textColor;
  late Color backgroundColor;
  late Color borderColor;
  late Color iconColor;

  ExerciseFeedbackColor(this.textColor, {Color? backgroundColor, Color? borderColor, Color? iconColor}){
    this.backgroundColor = backgroundColor ?? textColor.withValues(alpha: 0.15);
    this.borderColor = borderColor ?? textColor;
    this.iconColor = iconColor ?? textColor;
  }
}