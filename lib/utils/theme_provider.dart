import 'package:flutter/material.dart';
import 'package:raven/utils/store.dart';

class ThemeProvider {
  static String defaultColor = 'Raven';

  Map<String, Color> colors = {
    'Raven': Colors.deepPurple,
    'Red': Colors.red,
    'Teal': Colors.teal,
    'Blue': Colors.blue,
    'Orange': Colors.orange,
  };

  List<String> colorOptions() {
    List<String> options = [];
    options = colors.keys.toList();
    if (Store.sdkVersion >= 31) {
      options.add("Material You");
    }
    return options;
  }

  ThemeData _get(Color color, bool dark) {
    var fontScale = Store.fontScale;
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
    if (Store.themeColorSetting == "Material You") {
      if (Store.darkThemeSetting && darkScheme != null) {
        Store.materialYouColor = darkScheme.primary.value;
        return _get(darkScheme.primary, true);
      } else if (!Store.darkThemeSetting && lightScheme != null) {
        Store.materialYouColor = lightScheme.primary.value;
        return _get(lightScheme.primary, false);
      }
      if (Store.materialYouColor != -1) {
        return _get(Color(Store.materialYouColor), Store.darkThemeSetting);
      }
      return _get(colors.values.first, Store.darkThemeSetting);
    }
    return _get(
      colors[Store.themeColorSetting]!,
      Store.darkThemeSetting,
    );
  }
}
