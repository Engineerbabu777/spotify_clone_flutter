import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border(Color borderColor) => OutlineInputBorder(
    borderSide: BorderSide(color: borderColor, width: 3),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: _border(Pallete.gradient2),
      enabledBorder: _border(Pallete.borderColor),
      contentPadding: EdgeInsets.all(27),
    ),
  );
}
