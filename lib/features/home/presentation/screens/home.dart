import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/home/presentation/screens/chatbot.dart';
import 'package:gradproject/features/home/presentation/screens/home_content.dart';
import 'package:gradproject/features/home/presentation/screens/notification.dart';
import 'package:gradproject/features/home/presentation/screens/setting.dart';
import 'package:gradproject/features/home/presentation/screens/tasks.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePageContent(),
    TasksPage(),
    ChatPage(),
    NotificationsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> navIcons = [
      AppIcons.home,
      AppIcons.tick_square,
      AppIcons.chat,
      AppIcons.notification,
      AppIcons.setting,
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        color: AppColors.teal,
        navItems: List.generate(navIcons.length, (index) {
          final iconName = navIcons[index];
          return NavItem(
            icon: AppIcon(
              iconName.replaceAll('Bold', 'Bulk'),
            ),
            selectedIcon: AppIcon(
              iconName,
              color: AppColors.teal,
              size: 31.68.w,
            ),
            onTap: () => _onItemTapped(index),
          );
        }),
      ),
    );
  }
}
