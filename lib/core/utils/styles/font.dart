import 'package:flutter/material.dart';
import '../styles/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  static TextStyle title = TextStyle(
    color: AppColors.black,
    fontSize: 45.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
  );

  static TextStyle subTitle = TextStyle(
    color: AppColors.black50,
    fontSize: 25.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle header = TextStyle(
    color: AppColors.black,
    fontSize: 25.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
  );

  static TextStyle body = TextStyle(
    color: AppColors.black,
    fontSize: 20.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle text = TextStyle(
    color: AppColors.black,
    fontSize: 20.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle hint = TextStyle(
    color: AppColors.black30,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 18.sp,
  );

  static TextStyle bottomText = TextStyle(
    color: AppColors.black,
    fontSize: 18.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle secondaryTextButton = TextStyle(
    color: AppColors.black,
    fontSize: 18.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
  );

  static TextStyle buttonText = TextStyle(
    color: AppColors.grey,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
    fontSize: 25.sp,
  );
}

class AppTextStyles_darkMode {
  static TextStyle title = TextStyle(
    color: AppColors.grey,
    fontSize: 45.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
  );

  static TextStyle subTitle = TextStyle(
    color: AppColors.grey50,
    fontSize: 25.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle header = TextStyle(
    color: AppColors.grey,
    fontSize: 25.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
  );

  static TextStyle body = TextStyle(
    color: AppColors.grey,
    fontSize: 20.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle text = TextStyle(
    color: AppColors.grey,
    fontSize: 20.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle hint = TextStyle(
    color: AppColors.grey50,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 18.sp,
  );

  static TextStyle bottomText = TextStyle(
    color: AppColors.grey,
    fontSize: 18.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle secondaryTextButton = TextStyle(
    color: AppColors.grey,
    fontSize: 18.sp,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
  );

  static TextStyle buttonText = TextStyle(
    color: AppColors.black,
    fontFamily: 'Urbanist',
    fontVariations: [FontVariation('wght', 800)],
    fontSize: 25.sp,
  );
}
