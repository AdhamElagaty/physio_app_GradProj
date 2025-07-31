import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/widget_themes/buttons.dart';
import '../styles/widget_themes/input_decoration.dart';
import 'app_colors.dart';
import '../styles/font.dart';

class AppTheme {
  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
      colorScheme: appScheme,
      scaffoldBackgroundColor: AppColors.grey,
      pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(
              allowEnterRouteSnapshotting: false,
            )
          }),
      appBarTheme: AppBarTheme(
          foregroundColor: AppColors.black,
          centerTitle: false,
          toolbarHeight: 150.h,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            systemNavigationBarColor: AppColors.grey,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light,
          )),
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.hint.copyWith(color: AppColors.black),
      ),
      bottomSheetTheme: ThemeData.light().bottomSheetTheme.copyWith(
            backgroundColor: AppColors.white,
          ),
      inputDecorationTheme: AppInputDecorationThemes.light,
      filledButtonTheme: AppButtonThemes.filledButton,
      outlinedButtonTheme: AppButtonThemes.outlinedButton,
      elevatedButtonTheme: AppButtonThemes.elevatedButton,
      textButtonTheme: AppButtonThemes.textButton,
      iconButtonTheme: AppButtonThemes.iconButton,
      listTileTheme: listTile,
      searchBarTheme: ThemeData.light().searchBarTheme.copyWith(
          elevation: WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 25)),
          constraints: BoxConstraints(minHeight: 52.72),
          hintStyle: WidgetStatePropertyAll(AppTextStyles.hint),
          textStyle: WidgetStatePropertyAll(
              AppTextStyles.hint.copyWith(color: AppColors.black))));

  static ThemeData darkMode = ThemeData(
    colorScheme: appScheme,
    scaffoldBackgroundColor: AppColors.black,
    appBarTheme: AppBarTheme(
        foregroundColor: AppColors.grey,
        centerTitle: false,
        toolbarHeight: 150,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            systemNavigationBarColor: AppColors.black,
            statusBarColor: AppColors.black)),
    textTheme: TextTheme(
      bodyLarge: AppTextStylesDarkMode.text,
    ),
    bottomSheetTheme: ThemeData.dark().bottomSheetTheme.copyWith(
          backgroundColor: AppColors.lightBlack,
        ),
    inputDecorationTheme: AppInputDecorationThemes.dark,
    filledButtonTheme: AppButtonThemesDark.filledButton,
    outlinedButtonTheme: AppButtonThemesDark.outlinedButton,
    elevatedButtonTheme: AppButtonThemesDark.elevatedButton,
    textButtonTheme: AppButtonThemesDark.textButton,
    listTileTheme: listTile,
  );

  static ListTileThemeData listTile = ListTileThemeData(
    dense: true,
    //minTileHeight: 0,
    //minVerticalPadding: 0,
    visualDensity: VisualDensity(vertical: -4),
    titleTextStyle: AppTextStyles.header,
    contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
  );
}
