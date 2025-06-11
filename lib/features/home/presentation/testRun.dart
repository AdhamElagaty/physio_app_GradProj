// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gradproject/core/utils/styles/colors.dart';
// import 'package:gradproject/core/utils/styles/theme.dart';
// import 'package:gradproject/features/description/presentation/screens/description.dart';
// import 'package:gradproject/features/home/presentation/screens/home.dart';
// import 'package:gradproject/features/search/presentation/screens/search.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle.dark.copyWith(
//         systemNavigationBarColor: AppColors.grey,
//         systemNavigationBarIconBrightness: Brightness.dark,
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//     return ScreenUtilInit(
//       designSize: Size(402, 874),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           theme: AppTheme.lightMode,
//           home: Home(),
//         );
//       },
//     );
//   }
// }
