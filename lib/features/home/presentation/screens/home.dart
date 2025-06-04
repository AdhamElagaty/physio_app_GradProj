import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 75.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exercises',
                      style: AppTextStyles.title,
                    ),
                    Text(
                      'Choose category',
                      style: AppTextStyles.subTitle,
                    )
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: 35.w,
                    vertical: 15.h,
                  ),
                  onPressed: () {},
                  icon: AppIcon(
                    AppIcons.search_bulk,
                    size: 30.w,
                  ),
                  color: AppColors.teal,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
