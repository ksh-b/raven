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

  List<String> colorOptions(){
    List<String> options = [];
    options = colors.keys.toList();
    if(Store.sdkVersion>=31) {
      options.add("Material You");
    };
    return options;
  }

  ThemeData _get(Color color, bool dark) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  ThemeData getCurrentTheme({ColorScheme? lightScheme, ColorScheme? darkScheme,}) {
    if (Store.themeColorSetting=="Material You") {
      if (Store.darkThemeSetting && darkScheme!=null) {
        Store.materialYouColor = darkScheme.primary.value;
        return _get(darkScheme.primary, true);
      } else if (!Store.darkThemeSetting && lightScheme!=null){
        Store.materialYouColor = lightScheme.primary.value;
        return _get(lightScheme.primary, false);
      }
      if(Store.materialYouColor!=-1)
        return _get(Color(Store.materialYouColor), Store.darkThemeSetting);
      return _get(colors.values.first, Store.darkThemeSetting);
    }
    return _get(
      colors[Store.themeColorSetting]!,
      Store.darkThemeSetting,
    );
  }
}
