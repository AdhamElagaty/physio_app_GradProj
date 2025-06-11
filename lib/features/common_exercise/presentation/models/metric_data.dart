import 'package:flutter/material.dart';

class MetricData {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final bool isHighlighted;

  const MetricData({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.isHighlighted = false,
  });
}