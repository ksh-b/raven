import 'package:flutter/material.dart';
import 'package:raven/utils/store.dart';

class ThemeProvider {

  static String defaultColor  = "Orange";

  static Map<String, Color> colors = {
    'Red': Colors.red,
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Deep Purple': Colors.deepPurple,
    'Indigo': Colors.indigo,
    'Blue': Colors.blue,
    'Light Blue': Colors.lightBlue,
    'Cyan': Colors.cyan,
    'Teal': Colors.teal,
    'Green': Colors.green,
    'Light Green': Colors.lightGreen,
    'Lime': Colors.lime,
    'Yellow': Colors.yellow,
    'Amber': Colors.amber,
    'Orange': Colors.orange,
    'Deep Orange': Colors.deepOrange,
    'Brown': Colors.brown,
  };

  static ThemeData get(Color color, bool dark) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: dark?Brightness.dark:Brightness.light,
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