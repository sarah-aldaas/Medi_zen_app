import 'package:flutter/material.dart';
import 'package:medizen_app/base/theme/app_color.dart';


import 'package:flutter/material.dart';
import 'package:medizen_app/base/theme/app_color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor.withOpacity(0.8),
    surface: Colors.white,
    background: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    onBackground: Colors.black87,
  ),
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: AppColors.whiteColor,
    iconTheme: const IconThemeData(color: AppColors.primaryColor),
    titleTextStyle: const TextStyle(
      color: AppColors.primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    displayLarge: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(color: AppColors.primaryColor),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryColor,
    selectionColor: AppColors.primaryColor.withOpacity(0.4),
    selectionHandleColor: AppColors.primaryColor,
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
  ),
  cardTheme: const CardTheme(
    color: Colors.white,
    elevation: 2,
    margin: EdgeInsets.all(8),
  ),
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
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor,
    surface: AppColors.darkCard,
    background: AppColors.darkBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
  ),
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
    elevation: 0,
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
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryColor,
    selectionColor: AppColors.primaryColor.withOpacity(0.4),
    selectionHandleColor: AppColors.primaryColor,
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
  ),
  cardTheme: const CardTheme(
    color: AppColors.darkCard,
    elevation: 2,
    margin: EdgeInsets.all(8),
  ),
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
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
);
// final ThemeData lightTheme = ThemeData(
//   textSelectionTheme: TextSelectionThemeData(
//     cursorColor:AppColors.primaryColor ,
//   ),
//
//   brightness: Brightness.light,
//   secondaryHeaderColor: Colors.black87,
//   primaryColor: AppColors.primaryColor,
//   scaffoldBackgroundColor: Colors.white.withValues(alpha: 2),
//   appBarTheme: const AppBarTheme(
//     color: AppColors.whiteColor,
//     iconTheme: IconThemeData(color: AppColors.primaryColor),
//     titleTextStyle: TextStyle(
//       color: AppColors.primaryColor,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Colors.black87),
//     bodyMedium: TextStyle(color: Colors.black87),
//     displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//     displayMedium: TextStyle(
//       color: Colors.black87,
//       fontWeight: FontWeight.bold,
//     ),
//     labelLarge: TextStyle(color: AppColors.primaryColor),
//   ),
//   buttonTheme: ButtonThemeData(
//     buttonColor: AppColors.primaryColor,
//     textTheme: ButtonTextTheme.primary,
//   ),
//   iconTheme: const IconThemeData(color: AppColors.primaryColor),
//   floatingActionButtonTheme: const FloatingActionButtonThemeData(
//     backgroundColor: AppColors.primaryColor,
//   ),
//   cardTheme: const CardTheme(color: Colors.white, elevation: 2),
//   inputDecorationTheme: InputDecorationTheme(
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: BorderSide(color: AppColors.primaryColor),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: BorderSide(color: AppColors.primaryColor),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: BorderSide(color: AppColors.primaryColor),
//     ),
//     errorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: const BorderSide(color: Colors.redAccent),
//     ),
//     focusedErrorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: const BorderSide(color: Colors.redAccent),
//     ),
//     errorStyle: const TextStyle(
//       color: Colors.redAccent,
//       fontWeight: FontWeight.w500,
//     ),
//     hintStyle: TextStyle(color: Colors.grey.shade600),
//   ),
// );
//
// final ThemeData darkTheme = ThemeData(
//   textSelectionTheme: TextSelectionThemeData(
//     cursorColor:AppColors.primaryColor ,
//   ),
//   brightness: Brightness.dark,
//   secondaryHeaderColor: Colors.white,
//   primaryColor: AppColors.primaryColor,
//   scaffoldBackgroundColor: AppColors.darkBackground,
//   appBarTheme: const AppBarTheme(
//     color: AppColors.darkBackground,
//     iconTheme: IconThemeData(color: AppColors.primaryColor),
//     titleTextStyle: TextStyle(
//       color: AppColors.primaryColor,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: AppColors.whiteColor),
//     bodyMedium: TextStyle(color: AppColors.whiteColor),
//     displayLarge: TextStyle(
//       color: AppColors.whiteColor,
//       fontWeight: FontWeight.bold,
//     ),
//     displayMedium: TextStyle(
//       color: AppColors.whiteColor,
//       fontWeight: FontWeight.bold,
//     ),
//     labelLarge: TextStyle(color: AppColors.whiteColor),
//   ),
//   buttonTheme: ButtonThemeData(
//     buttonColor: AppColors.primaryColor,
//     textTheme: ButtonTextTheme.primary,
//   ),
//   iconTheme: const IconThemeData(color: AppColors.primaryColor),
//   floatingActionButtonTheme: const FloatingActionButtonThemeData(
//     backgroundColor: AppColors.primaryColor,
//   ),
//   cardTheme: const CardTheme(color: AppColors.darkCard, elevation: 2),
//   inputDecorationTheme: InputDecorationTheme(
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: BorderSide(color: AppColors.primaryColor),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: BorderSide(color: AppColors.primaryColor),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: BorderSide(color: AppColors.primaryColor),
//     ),
//     errorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: const BorderSide(color: Colors.redAccent),
//     ),
//     focusedErrorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25.0),
//       borderSide: const BorderSide(color: Colors.redAccent),
//     ),
//     errorStyle: const TextStyle(
//       color: Colors.redAccent,
//       fontWeight: FontWeight.w500,
//     ),
//     hintStyle: TextStyle(color: Colors.grey.shade400),
//   ),
// );
