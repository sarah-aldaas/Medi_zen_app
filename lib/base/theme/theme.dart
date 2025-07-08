import 'package:flutter/material.dart';
import 'package:medizen_app/base/theme/app_color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  secondaryHeaderColor: Colors.black87,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: Colors.white.withValues(alpha: 2),
  appBarTheme: const AppBarTheme(
    color: AppColors.whiteColor,
    iconTheme: IconThemeData(color: AppColors.primaryColor),
    titleTextStyle: TextStyle(
      color: AppColors.primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(color: AppColors.primaryColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: const IconThemeData(color: AppColors.primaryColor),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
  ),
  cardTheme: const CardTheme(color: Colors.white, elevation: 2),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    errorStyle: const TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: Colors.grey.shade600),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  secondaryHeaderColor: Colors.white,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: const AppBarTheme(
    color: AppColors.darkBackground,
    iconTheme: IconThemeData(color: AppColors.primaryColor),
    titleTextStyle: TextStyle(
      color: AppColors.primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.whiteColor),
    bodyMedium: TextStyle(color: AppColors.whiteColor),
    displayLarge: TextStyle(
      color: AppColors.whiteColor,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: AppColors.whiteColor,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(color: AppColors.whiteColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: const IconThemeData(color: AppColors.primaryColor),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
  ),
  cardTheme: const CardTheme(color: AppColors.darkCard, elevation: 2),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    errorStyle: const TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: Colors.grey.shade400),
  ),
);
