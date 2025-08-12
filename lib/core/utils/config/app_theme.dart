import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[600],
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    // cardTheme: CardTheme(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[500],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.orangeAccent,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[700]),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
        .copyWith(secondary: Colors.orangeAccent),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.grey[850],
    appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
    // cardTheme: CardTheme(
    //   elevation: 2,
    //   color: Colors.grey[800],
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.orangeAccent[400],
      foregroundColor: Colors.black,
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[300]),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[300]),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[400]),
    ),
    colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal, brightness: Brightness.dark)
        .copyWith(secondary: Colors.orangeAccent[400]),
  );
}
