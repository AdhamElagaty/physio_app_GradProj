import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import '../../../features/auth/presentation/cubit/otp_verification_cubit/otp_verification_cubit.dart';
import '../../../features/auth/presentation/cubit/request_password_reset_cubit/request_password_reset_cubit.dart';
import '../../../features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import '../../../features/auth/presentation/cubit/signup_cubit/signup_cubit.dart';
import '../../../features/auth/presentation/models/otp_screen_args.dart';
import '../../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/auth/presentation/screens/forget_new_password_screen.dart';
import '../../../features/auth/presentation/screens/otp_screen.dart';
import '../../../features/auth/presentation/screens/signup_screeen.dart';
import '../../../features/chat_bot/presentation/cubit/chat_messages/chat_message_cubit.dart';
import '../../../features/chat_bot/presentation/model/chat_screen_args.dart';
import '../../../features/chat_bot/presentation/screens/chat_screen.dart';
import '../../../features/exercise/presentation/cubit/exercise_category/exercise_category_cubit.dart';
import '../../../features/exercise/presentation/cubit/exercise_filter/exercise_filter_cubit.dart';
import '../../../features/exercise/presentation/model/exercise_description_screen_args.dart';
import '../../../features/exercise/presentation/model/exercise_filter_screen_args.dart';
import '../../../features/exercise/presentation/screens/exercise_categories_screen.dart';
import '../../../features/exercise/presentation/screens/exercise_description_screen.dart';
import '../../../features/exercise/presentation/screens/exercises_filter_screen.dart';
import '../../../features/main_navigation/presentation/cubit/navigation_cubit/navigation_cubit.dart';
import '../../../features/main_navigation/presentation/screens/main_navigation_screen.dart';
import '../../../injection_container.dart';
import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.login,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<LoginCubit>(),
            child: LoginScreen(),
          ),
        );

      case Routes.signup:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.signup,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<SignupCubit>(),
            child: SignupScreen(),
          ),
        );

      case Routes.forgotPassword:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.forgotPassword,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<RequestPasswordResetCubit>(),
            child: ForgotPasswordScreen(),
          ),
        );

      case Routes.otp:
        final args = settings.arguments as OtpScreenArgs;
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.otp,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<OtpVerificationCubit>()..initializeTimer(),
            child: OtpScreen(args: args),
          ),
        );

      case Routes.newPassword:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.newPassword,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<ResetPasswordCubit>(),
            child: ForgetNewPasswordScreen(
              email: args['email'],
              token: args['token'],
            ),
          ),
        );

      case Routes.mainScreen:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.mainScreen,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<NavigationCubit>(),
            child: MainNavigationScreen(
                key: const ValueKey("MainNavigationScreen")),
          ),
        );

      case Routes.guestHome:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.guestHome,
          ),
          builder: (_) => Scaffold(
            body: BlocProvider(
              create: (context) =>
                  sl<ExerciseCategoryCubit>()..getCategories(isOffline: true),
              child: ExerciseCategoriesScreen(),
            ),
          ),
        );

      case Routes.exerciseFilter:
        final args = settings.arguments as ExerciseFilterScreenArgs;
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.exerciseFilter,
          ),
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => sl<ExerciseFilterCubit>()
                    ..initialize(
                      allCategories: args.allCategoryTitles,
                      initialCategory: args.selectedCategory,
                      isOffline: args.isOffline,
                    ),
                ),
                BlocProvider.value(
                  value: args.exerciseCategoryCubit,
                ),
              ],
              child: const ExercisesFilterScreen(),
            );
          },
        );

      case Routes.exerciseDescription:
        final args = settings.arguments as ExerciseDescriptionScreenArgs;
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.exerciseDescription,
          ),
          builder: (context) {
            return BlocProvider.value(
              value: args.exerciseFilterCubit,
              child: ExerciseDescriptionScreen(exercise: args.exercise),
            );
          },
        );

      case Routes.chatBotChatScreen:
        final args = settings.arguments as ChatScreenArgs;
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.chatBotChatScreen,
          ),
          builder: (_) => BlocProvider(
            create: (context) => sl<ChatMessagesCubit>()
              ..initialize(args.chatId, args.chatHistoryCubit),
            child: ChatScreen(chatId: args.chatId),
          ),
        );

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('No Route Found')),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
