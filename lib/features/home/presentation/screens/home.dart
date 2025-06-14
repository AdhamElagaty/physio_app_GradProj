import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/cubit/exercise_session_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/chatbot.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/screen/chat_history_screen.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/screen/chat_screen.dart';
import 'package:gradproject/features/home/presentation/screens/home_content/home_content.dart';
import 'package:gradproject/features/home/presentation/screens/notification/notification.dart';
import 'package:gradproject/features/home/presentation/screens/setting/setting.dart';
import 'package:gradproject/features/home/presentation/screens/tasks/tasks.dart';
import 'package:gradproject/features/pose_detection_handling/services/pose_detection_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ChatRepository>(
      create: (context) => ChatRepository(ApiManager()),
      child: BlocProvider(
        create: (context) =>
            ChatHistoryCubit(context.read<ChatRepository>())..fetchFirstPage(),
        child:
            const Home(), // دي مهمة جدًا، خليه يورّث الـ context اللي فيه الـ provider
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static List<Widget> pages = <Widget>[
    HomePageContent(),
    TasksPage(),
    MultiBlocProvider(
      providers: [
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepository(ApiManager()),
        ),
        BlocProvider(
          create: (context) => ChatHistoryCubit(context.read<ChatRepository>())
            ..fetchFirstPage(),
        ),
      ],
      child: ChatHistoryScreen(),
    ),
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
      body: pages[_selectedIndex],
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
