import 'package:flutter/material.dart';
import '../colors.dart';
import '../font.dart';

class AppInputDecorationThemes {
  static InputDecorationTheme light = InputDecorationTheme(
    fillColor: AppColors.white,
    filled: true,
    labelStyle: AppTextStyles.hint,
    hintStyle: AppTextStyles.hint,
    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    enabledBorder: inputBorder.copyWith(
        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(18)),
    focusedBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.teal),
        borderRadius: BorderRadius.circular(18)),
    errorBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.red),
        borderRadius: BorderRadius.circular(18)),
    focusedErrorBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.teal),
        borderRadius: BorderRadius.circular(18)),
    errorStyle: AppTextStyles.text.copyWith(
      color: AppColors.black,
      fontSize: 15,
    ),
    // floatingLabelBehavior: FloatingLabelBehavior.auto,
    // floatingLabelStyle: AppTextStyles.text.copyWith(fontSize: 20),
  );
  static InputDecorationTheme dark = InputDecorationTheme(
    fillColor: AppColors.lightBlack,
    filled: true,
    labelStyle: AppTextStyles_darkMode.hint.copyWith(color: AppColors.black),
    hintStyle: AppTextStyles_darkMode.hint.copyWith(color: AppColors.black50),
    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
    enabledBorder: inputBorder.copyWith(borderSide: BorderSide.none),
    //focusedBorder: inputBorder.copyWith(borderSide:borderSide.copyWith(color: appScheme.surface)),
    errorBorder: inputBorder.copyWith(
      borderSide: borderSide.copyWith(color: appScheme.error),
    ),
    focusedErrorBorder: inputBorder.copyWith(
      borderSide: borderSide.copyWith(color: appScheme.onSurface),
    ),
    errorStyle: AppTextStyles_darkMode.text.copyWith(
      color: AppColors.black,
      fontSize: 15,
    ),
    // floatingLabelBehavior: FloatingLabelBehavior.auto,
    // floatingLabelStyle: AppTextStyles.text.copyWith(fontSize: 20),
  );

  static BorderSide borderSide = BorderSide(
    color: AppColors.white,
    width: 3,
    strokeAlign: BorderSide.strokeAlignOutside,
  );

  static OutlineInputBorder inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.white,
      width: 3,
      strokeAlign: BorderSide.strokeAlignOutside,
    ),
    borderRadius: BorderRadius.circular(13),
  );
}
