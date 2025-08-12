import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.color = Colors.black,
    this.size = 20,
  });
  final String icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      width: size.w,
      height: size.h,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
