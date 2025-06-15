import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppIcons {
  static const String arrow_right_square =
      'assets/images/Iconly/Bold/Arrow-Right-Square.svg';
  static const String category = 'assets/images/Iconly/Bold/Category.svg';
  static const String chat = 'assets/images/Iconly/Bold/Chat.svg';
  static const String heart = 'assets/images/Iconly/Bold/Heart.svg';
  static const String home = 'assets/images/Iconly/Bold/Home.svg';
  static const String profile = 'assets/images/Iconly/Bold/Profile.svg';
  static const String send = 'assets/images/Iconly/Bold/Send.svg';
  static const String setting = 'assets/images/Iconly/Bold/Setting.svg';
  static const String notification =
      'assets/images/Iconly/Bold/Notification.svg';
  static const String tick_square = 'assets/images/Iconly/Bold/Tick-Square.svg';
  static const String category_bulk = 'assets/images/Iconly/Bulk/Category.svg';
  static const String chat_bulk = 'assets/images/Iconly/Bulk/Chat.svg';
  static const String hide_bulk = 'assets/images/Iconly/Bulk/Hide.svg';
  static const String home_bulk = 'assets/images/Iconly/Bulk/Home.svg';
  static const String notification_bulk =
      'assets/images/Iconly/Bulk/Notification.svg';
  static const String search_bulk = 'assets/images/Iconly/Bulk/Search.svg';
  static const String setting_bulk = 'assets/images/Iconly/Bulk/Setting.svg';
  static const String show_bulk = 'assets/images/Iconly/Bulk/Show.svg';
  static const String add = 'assets/images/Iconly/Bulk/Plus.svg';
  static const String edit = 'assets/images/Iconly/Bulk/Edit.svg';
  static const String delete = 'assets/images/Iconly/Bulk/Delete.svg';
  static const String tick_square_bulk =
      'assets/images/Iconly/Bulk/Tick-Square.svg';
  static const String arrow_left_bulk =
      'assets/images/Iconly/Bulk/Arrow-Left-3.svg';
      static const String arms=
      'assets/images/Arms.svg';
      static const String core_strength =
      'assets/images/Core-Strength.svg';
      static const String lower_body=
      'assets/images/Lower-Body.svg';
      static const String biceps =
      'assets/images/Dumbbell-Small-Streamline-Solar-Bold.svg';
      static const String glute_bridge =
      'assets/images/Yoga-Bridge-Pose-2-Streamline-Ultimate-Bold-Free.svg';
      static const String plank =
      'assets/images/Yoga-Low-Plank-Pose-Streamline-Ultimate-Bold.svg';
}

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
