import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../colors.dart';
import '../font.dart';

class AppButtonThemes {
  static FilledButtonThemeData filledButton = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      fixedSize: Size(133.w, 65.h),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.grey),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(50.r),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      fixedSize: Size(420.w, 60.h),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.white),
      foregroundColor: AppColors.white,
      side: BorderSide(
        width: 3.w,
        color: AppColors.black,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
    ),
  );

  static ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      //iconSize: 30.72.w,
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 11.h),
      minimumSize: Size(80.72.w, 52.72.h),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(80.r),
      ),
    ),
  );
  static IconButtonThemeData iconButton = IconButtonThemeData(
    style: FilledButton.styleFrom(
      //iconSize: 25.w,
      minimumSize: Size(51.w, 40.h),
      maximumSize: Size(60.w, 40.h),
      padding: EdgeInsets.symmetric(horizontal: 13.33.w),
      //fixedSize: Size(80.72,52.72),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(80.r),
      ),
    ),
  );
  static IconButtonThemeData iconButtonSmall = IconButtonThemeData(
    style: FilledButton.styleFrom(
      //iconSize: 25.w,
      minimumSize: Size(32.w, 32.h),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,

      padding: EdgeInsets.all(0.w),
      //fixedSize: Size(80.72,52.72),
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.teal,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(80.r),
      ),
    ),
  );
  static IconButtonThemeData filterButton = IconButtonThemeData(
    style: FilledButton.styleFrom(
      //iconSize: 25.w,
      minimumSize: Size(51.w, 40.h),
      maximumSize: Size(200.w, 40.h),
      padding: EdgeInsets.symmetric(horizontal: 13.33.w),
      //fixedSize: Size(80.72,52.72),
      backgroundColor: AppColors.red.withAlpha(39),

      foregroundColor: AppColors.red,

      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(13.r),
      ),
    ),
  );
  static TextButtonThemeData textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: AppTextStyles.secondaryTextButton,
      foregroundColor: AppColors.black,
      backgroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ),
  );
  static TextButtonThemeData altTextButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 4.h),
      textStyle: AppTextStyles.secondaryTextButton,
      foregroundColor: AppColors.teal,
      backgroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ),
  );
}

class AppButtonThemes_dark {
  static FilledButtonThemeData filledButton = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      fixedSize: Size(420.w, 60.h),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.black),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.black,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(25.r),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      fixedSize: Size(420.w, 60.h),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.black),
      foregroundColor: AppColors.black,
      side: BorderSide(
        width: 3.w,
        color: AppColors.black,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
    ),
  );

  static ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      fixedSize: Size(420.w, 70.h),
      textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.black),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.black,
      shadowColor: AppColors.black50,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(25.r),
      ),
    ),
  );
  static TextButtonThemeData textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.r)),
    ),
  );
}
