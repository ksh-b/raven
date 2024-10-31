import 'package:flutter/material.dart';
import 'package:raven/repository/preferences/appearance.dart';

class ThemeProvider {
  static String defaultColor = 'Raven';

  static Map<String, Color> colors = {
    "Purple": Colors.purple,
    "Red": Colors.red,
    "Pink": Colors.pink,
    "Orange": Colors.orange,
    "Yellow": Colors.yellow,
    "Green": Colors.green,
    "Teal": Colors.teal,
    "Blue": Colors.blue,
    "Light Blue": Colors.lightBlue,
    "Cyan": Colors.cyan,
    "Indigo": Colors.indigo,
    "Brown": Colors.brown,
    "Grey": Colors.grey,
    "Blue Grey": Colors.blueGrey,
    "Amber": Colors.amber,
    "Lime": Colors.lime,
  };


  List<String> colorOptions() {
    return colors.keys.toList();
  }

  ThemeData _get(Color color, bool dark) {
    var fontScale = AppearancePref.fontSize;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0 * fontScale,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.0 * fontScale,
        ),
        headlineSmall: TextStyle(
          fontSize: 24.0 * fontScale,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0 * fontScale,
        ),
        titleMedium: TextStyle(
          fontSize: 16.0 * fontScale,
        ),
        titleSmall: TextStyle(
          fontSize: 14.0 * fontScale,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0 * fontScale,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0 * fontScale,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0 * fontScale,
        ),
        displayLarge: TextStyle(
          fontSize: 57.0 * fontScale,
        ),
        displayMedium: TextStyle(
          fontSize: 45.0 * fontScale,
        ),
        displaySmall: TextStyle(
          fontSize: 36.0 * fontScale,
        ),
        labelLarge: TextStyle(
          fontSize: 14.0 * fontScale,
        ),
        labelMedium: TextStyle(
          fontSize: 12.0 * fontScale,
        ),
        labelSmall: TextStyle(
          fontSize: 11.0 * fontScale,
        ),
      ),
    );
  }

  ThemeData getCurrentTheme({
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
  }) {
    var dark = AppearancePref.theme == ThemePref.Dark.name;
    if (AppearancePref.materialYou) {
      if (dark && darkScheme != null) {
        return _get(darkScheme.primary, true);
      } else if (!dark && lightScheme != null) {
        return _get(lightScheme.primary, false);
      }
      return _get(colors.values.first, dark);
    }
    return _get(
      colors[AppearancePref.color]!,
      dark,
    );
  }
}
