import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/api/api_manger.dart'; // Make sure this import is correct if you have ApiManager in a different folder
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/componets/observer.dart';
import 'package:gradproject/core/utils/config/routes.dart'; // Make sure Routes is imported
import 'package:gradproject/core/utils/config/routes_genartor.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/theme.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';

String? initialRoute;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();

  final Token? cachedToken = CacheHelper.getToken('token');
  if (cachedToken != null && cachedToken.value.isNotEmpty) {
    initialRoute = Routes.home;
    debugPrint("Cached token found. Initial route set to Home.");
  } else {
    initialRoute = Routes.login;
    debugPrint("No cached token found. Initial route set to Login.");
  }

  runApp(
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: AppColors.grey,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light,
      ),
    );
    return ScreenUtilInit(
      designSize: Size(393, 873),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteGenerator.getRoute,
          theme: AppTheme.lightMode,
          initialRoute: initialRoute,
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}
