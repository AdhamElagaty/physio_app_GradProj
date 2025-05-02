import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppIcons {
  static const String arrow_right_square =
      'assets/images/Iconly/Bold/Arrow - Right Square.svg';
  static const String category = 'assets/images/Iconly/Bold/Category.svg';
  static const String chat = 'assets/images/Iconly/Bold/Chat.svg';
  static const String heart = 'assets/images/Iconly/Bold/Heart.svg';
  static const String home = 'assets/images/Iconly/Bold/Home.svg';
  static const String profile = 'assets/images/Iconly/Bold/Profile.svg';
  static const String send = 'assets/images/Iconly/Bold/Send.svg';
  static const String setting = 'assets/images/Iconly/Bold/Setting.svg';
  static const String tick_square = 'assets/images/Iconly/Bold/Tick Square.svg';
  static const String category_bulk = 'assets/images/Iconly/Bulk/Category.svg';
  static const String chat_bulk = 'assets/images/Iconly/Bulk/Chat.svg';
  static const String hide_bulk = 'assets/images/Iconly/Bulk/Hide.svg';
  static const String home_bulk = 'assets/images/Iconly/Bulk/Home.svg';
  static const String notification_bulk =
      'assets/images/Iconly/Bulk/Notification.svg';
  static const String search_bulk = 'assets/images/Iconly/Bulk/Search.svg';
  static const String setting_bulk = 'assets/images/Iconly/Bulk/Setting.svg';
  static const String show_bulk = 'assets/images/Iconly/Bulk/Show.svg';
  static const String tick_square_bulk =
      'assets/images/Iconly/Bulk/Tick Square.svg';
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
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
