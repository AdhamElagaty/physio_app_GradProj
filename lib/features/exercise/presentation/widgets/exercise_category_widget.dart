import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/app_assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseCategoryWidget extends StatelessWidget {
  const ExerciseCategoryWidget({
    super.key,
    required this.color,
    this.backgroundColor = Colors.white,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final Color backgroundColor;
  final void Function() onTap;
  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.alphaBlend(
        color.withAlpha(38),
        backgroundColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.r)),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: color,
        borderRadius: BorderRadius.all(Radius.circular(25.r)),
        onTap: onTap, // Directly pass the onTap function
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.patternAndEffect.pattern,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keep this to prevent layout errors
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 15.h),
                          Text(
                            title,
                            style: AppTextStyles.header.copyWith(
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      icon,
                    ],
                  ),
                  Text(subtitle, style: AppTextStyles.subHeader),
                  SizedBox(height: 10.h),
                  AppIcon(
                    AppAssets.iconly.bold.arrowRightSquare,
                    color: color,
                    size: 35.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
