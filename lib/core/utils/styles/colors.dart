import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Colors.white;
  static const Color grey = Color(0xFFEDF2F2);
  static const Color grey50 = Color(0x7EEDF2F2);
  static const Color black = Color(0xFF0D1113);
  static const Color black50 = Color(0x800D1113);
  static const Color black30 = Color(0x4D0D1113);
  static const Color lightBlack = Color(0xFF1A2428);
  static const Color teal = Color(0xFF3EC1D3);
  static const Color yellow = Color(0xFFEBB952);
  static const Color purple = Color(0xFF806ED4);
  static const Color red = Color(0xFFE66767);
    static const Color magenta = Color(0xFFCB5D7C);
  static const Color lightTeal = Color(0xFF64CDDB);
  static const Color lightYellow = Color(0xFFF0C56C);
  static const Color lightPurple = Color(0xFF9E8EED);
  static const Color lightRed = Color(0xFFEB8686);
  static const Color lightTeal50 = Color(0x7E64CDDB);
  static const Color green = Color(0xFF4CAF50);
}

ColorScheme appScheme = ColorScheme(
  brightness: ColorScheme.light().brightness,
  surface: AppColors.grey,
  onSurface: AppColors.black,
  primary: AppColors.teal,
  onPrimary: AppColors.white,
  primaryFixed: AppColors.teal,
  onPrimaryFixed: AppColors.white,
  error: ColorScheme.light().error,
  onError: ColorScheme.light().onError,
  primaryContainer: AppColors.black,
  onPrimaryContainer: AppColors.white,
  surfaceContainerHigh: AppColors.white,
  secondary: AppColors.black,
  onSecondary: AppColors.white,
  secondaryFixed: AppColors.black,
  onSecondaryFixed: AppColors.white,
  secondaryContainer: AppColors.black,
  onSecondaryContainer: AppColors.white,
);
