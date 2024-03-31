import 'package:flutter/material.dart';
import 'package:raven/utils/store.dart';

class ThemeProvider {
  static String defaultColor = 'Raven';

  static Map<String, Color> colors = {
    'Raven': Colors.deepPurple,
    'Red': Colors.red,
    'Teal': Colors.teal,
    'Blue': Colors.blue,
    'Orange': Colors.orange,
  };

  static ThemeData get(Color color, bool dark) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  static ThemeData getCurrentTheme() {
    return ThemeProvider.get(
      ThemeProvider.colors[Store.themeColorSetting]!,
      Store.darkThemeSetting,
    );
  }
}
