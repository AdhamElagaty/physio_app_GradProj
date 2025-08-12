import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import 'core/utils/assets_preloader_utils.dart';
import 'core/utils/config/routes.dart';
import 'core/utils/config/routes_genartor.dart';
import 'core/utils/styles/app_colors.dart';
import 'core/utils/styles/theme.dart';
import 'injection_container.dart' as di;

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await di.init();

  final appManagerCubit = di.sl<AppManagerCubit>();

  await Future.wait([
    AssetPreloaderUtils.precacheAllAssets(),
    appManagerCubit.init(),
  ]);

  FlutterNativeSplash.remove();

  runApp(
    BlocProvider.value(
      value: appManagerCubit,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: AppColors.grey,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    return ScreenUtilInit(
      designSize: const Size(393, 873),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final initialRoute = context.read<AppManagerCubit>().state.authStatus == AuthStatus.authenticated
            ? Routes.mainScreen
            : Routes.login;
        return BlocListener<AppManagerCubit, AppManagerState>(
          listenWhen: (previous, current) =>
              previous.authStatus != current.authStatus,
          listener: (context, state) {
            if (state.authStatus == AuthStatus.loading) return;

            final routeName = state.authStatus == AuthStatus.authenticated
                ? Routes.mainScreen
                : (state.authStatus == AuthStatus.guest
                    ? Routes.guestHome
                    : Routes.login);

            if (ModalRoute.of(context)?.settings.name != routeName) {
              _navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(routeName, (route) => false);
            }
          },
          child: BlocBuilder<AppManagerCubit, AppManagerState>(
            buildWhen: (previous, current) =>
                previous.themeMode != current.themeMode ||
                previous.locale != current.locale ||
                previous.authStatus != current.authStatus,
            builder: (context, state) {
              return MaterialApp(
                navigatorKey: _navigatorKey,
                debugShowCheckedModeBanner: false,
                onGenerateRoute: (RouteSettings settings) {
                  if (settings.name == '/') {
                    return null;
                  }
                  return RouteGenerator.getRoute(settings);
                },
                themeMode: state.themeMode,
                locale: state.locale,
                theme: AppTheme.lightMode,
                darkTheme: AppTheme.darkMode,
                initialRoute: initialRoute,
              );
            },
          ),
        );
      },
    );
  }
}
