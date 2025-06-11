import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/componets/observer.dart';
import 'package:gradproject/core/utils/config/routes.dart' show Routes;
import 'package:gradproject/core/utils/config/routes_genartor.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/theme.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_cubit.dart';
import 'package:gradproject/features/camera_handling/services/camera_service.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/cubit/exercise_session_cubit.dart';
import 'package:gradproject/features/pose_detection_handling/services/pose_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CameraCubit(CameraService())..initializeCamera(),
          lazy: false, // Initialize camera immediately
        ),
        BlocProvider(
          create: (context) => ExerciseSessionCubit(PoseDetectionService()),
        ),
      ],
      child: const MyApp(), // Your root app widget
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
          initialRoute: Routes.login,
        );
      },
    );
  }
}
