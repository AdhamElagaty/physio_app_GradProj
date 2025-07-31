import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_colors.dart';
import '../font.dart';

class AppInputDecorationThemes {
  static InputDecorationTheme light = InputDecorationTheme(
    fillColor: AppColors.white,
    filled: true,
    labelStyle: AppTextStyles.hint,
    hintStyle: AppTextStyles.hint,
    contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
    enabledBorder: inputBorder.copyWith(
        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.r)),
    focusedBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.teal),
        borderRadius: BorderRadius.circular(20.r)),
    errorBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.red),
        borderRadius: BorderRadius.circular(20.r)),
    focusedErrorBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.teal),
        borderRadius: BorderRadius.circular(20.r)),
    errorStyle: AppTextStyles.text.copyWith(
      color: AppColors.black,
      fontSize: 18.sp,
    ),
    // floatingLabelBehavior: FloatingLabelBehavior.auto,
    // floatingLabelStyle: AppTextStyles.text.copyWith(fontSize: 20),
  );
  static InputDecorationTheme dark = InputDecorationTheme(
    fillColor: AppColors.lightBlack,
    filled: true,
    labelStyle: AppTextStylesDarkMode.hint.copyWith(color: AppColors.black),
    hintStyle: AppTextStylesDarkMode.hint.copyWith(color: AppColors.black50),
    contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
    enabledBorder: inputBorder.copyWith(
        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.r)),
    focusedBorder: inputBorder.copyWith(
        borderSide: borderSide.copyWith(color: AppColors.teal),
        borderRadius: BorderRadius.circular(20.r)),
    errorBorder: inputBorder.copyWith(
      borderSide: borderSide.copyWith(color: appScheme.error),
    ),
    focusedErrorBorder: inputBorder.copyWith(
      borderSide: borderSide.copyWith(color: appScheme.onSurface),
    ),
    errorStyle: AppTextStylesDarkMode.text.copyWith(
      color: AppColors.black,
      fontSize: 15.sp,
    ),
    // floatingLabelBehavior: FloatingLabelBehavior.auto,
    // floatingLabelStyle: AppTextStyles.text.copyWith(fontSize: 20),
  );

  static BorderSide borderSide = BorderSide(
    color: AppColors.white,
    width: 3.w,
    strokeAlign: BorderSide.strokeAlignOutside,
  );

  static OutlineInputBorder inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.white,
      width: 3.w,
      strokeAlign: BorderSide.strokeAlignOutside,
    ),
    borderRadius: BorderRadius.circular(13.r),
  );
}
