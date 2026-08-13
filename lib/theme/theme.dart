import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

class AppTheme {
  /// 🌞 LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColor.lightGreyBackground,
    visualDensity: VisualDensity.compact,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.white,
      foregroundColor: AppColor.black,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColor.black),
      titleTextStyle: TextStyle(
        color: AppColor.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: ColorScheme.light(primary: AppColor.primary),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColor.black)),
  );

  /// 🌙 DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColor.darkBackground,
    visualDensity: VisualDensity.compact,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.darkBackground,
      foregroundColor: AppColor.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColor.white),
      titleTextStyle: TextStyle(
        color: AppColor.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: ColorScheme.dark(primary: AppColor.primary),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColor.white)),
  );
}
