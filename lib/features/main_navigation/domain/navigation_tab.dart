import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/error_handler_service.dart';
import '../../../core/utils/styles/app_assets.dart';
import '../../../injection_container.dart';
import '../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../chat_bot/domain/usecases/delete_chat/delete_chat_usecase.dart';
import '../../chat_bot/domain/usecases/get_chats/get_chats_usecase.dart';
import '../../chat_bot/domain/usecases/update_chat_title/update_chat_title_usecase.dart';
import '../../chat_bot/presentation/cubit/chat_history/chat_history_cubit.dart';
import '../../chat_bot/presentation/screens/chat_history_screen.dart';
import '../../exercise/presentation/cubit/exercise_category/exercise_category_cubit.dart';
import '../../exercise/presentation/screens/exercise_categories_screen.dart';
import '../../user_profile/presentation/cubit/user_profile_cubit.dart';
import '../../user_profile/presentation/screens/user_settings_screen.dart';

enum NavigationTab {
  exerciseHome,
  chatBot,
  settings;

  Widget _buildPage(Key? key) {
    switch (this) {
      case NavigationTab.exerciseHome:
        return BlocProvider(
          create: (context) => sl<ExerciseCategoryCubit>()..getCategories(isOffline: context.read<AppManagerCubit>().state.connectivityStatus == ConnectivityStatus.offline),
          child: ExerciseCategoriesScreen(key: key),
        );
      case NavigationTab.chatBot:
        return BlocProvider(
          create: (context) => ChatHistoryCubit(
            getChatsUseCase: sl<GetChatsUseCase>(),
            deleteChatUseCase: sl<DeleteChatUseCase>(),
            updateChatTitleUseCase: sl<UpdateChatTitleUseCase>(),
            errorHandler: sl<ErrorHandlerService>(),
          )..fetchFirstPage(),
          child: ChatHistoryScreen(),
        );
      case NavigationTab.settings:
        return BlocProvider(
          key: key,
          create: (context) => sl<UserProfileCubit>()..fetchUserDetails(),
          child: const UserSettingsScreen(),
        );
    }
  }

  Widget get page {
    switch (this) {
      case NavigationTab.settings:
        return _buildPage(ValueKey(DateTime.now()));
      case NavigationTab.exerciseHome:
      case NavigationTab.chatBot:
        return _buildPage(null);
    }
  }

  String get icon {
    switch (this) {
      case NavigationTab.exerciseHome:
        return AppAssets.iconly.bulk.home;
      case NavigationTab.chatBot:
        return AppAssets.iconly.bulk.chat;
      case NavigationTab.settings:
        return AppAssets.iconly.bulk.setting;
    }
  }

  String get selectedIcon {
    switch (this) {
      case NavigationTab.exerciseHome:
        return AppAssets.iconly.bold.home;
      case NavigationTab.chatBot:
        return AppAssets.iconly.bold.chat;
      case NavigationTab.settings:
        return AppAssets.iconly.bold.setting;
    }
  }
}
