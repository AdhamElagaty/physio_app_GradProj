import 'package:flutter/material.dart';
import '../colors.dart';
import '../font.dart';

class AppButtonThemes {
  static FilledButtonThemeData filledButton = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8),
      fixedSize: Size(133, 61),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.grey),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(50),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8),
      fixedSize: Size(420, 60),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.white),
      foregroundColor: AppColors.white,
      side: BorderSide(
        width: 3,
        color: AppColors.black,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );

  static ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8),
      fixedSize: Size(420, 70),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.white),
      backgroundColor: appScheme.primary,
      foregroundColor: appScheme.onPrimary,
      shadowColor: AppColors.black50,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  );
  static TextButtonThemeData textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    ),
  );
}

class AppButtonThemes_dark {
  static FilledButtonThemeData filledButton = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8),
      fixedSize: Size(420, 60),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.black),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.black,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8),
      fixedSize: Size(420, 60),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.black),
      foregroundColor: AppColors.black,
      side: BorderSide(
        width: 3,
        color: AppColors.black,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );

  static ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8),
      fixedSize: Size(420, 70),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.black),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.black,
      shadowColor: AppColors.black50,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  );
  static TextButtonThemeData textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    ),
  );
}
