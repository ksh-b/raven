import 'package:raven/repository/preferences/internal.dart';

enum Appearance {
  theme,
  color,
  isMaterialYou,
  fontSize,
}

// default values
final _theme = ThemePref.values.first;
final _color = "Purple";

final _materialYou = false;
final _fontSize = 1.0;

enum ThemePref {
  Light,
  Dark,
  System,
}

class AppearancePref {
  static String get theme {
    return Internal.settings.get(Appearance.theme.name, defaultValue: _theme.name);
  }

  static set theme(String theme) {
    Internal.settings.put(Appearance.theme.name, theme);
  }

  static String get color {
    return Internal.settings.get(Appearance.color.name, defaultValue: _color);
  }

  static set color(String color) {
    Internal.settings.put(Appearance.color.name, color);
  }

  static bool get materialYou {
    return Internal.settings
        .get(Appearance.isMaterialYou.name, defaultValue: _materialYou);
  }

  static set materialYou(bool isMaterialYou) {
    Internal.settings.put(Appearance.isMaterialYou.name, isMaterialYou);
  }

  static double get fontSize {
    return Internal.settings.get(
      Appearance.fontSize.name,
      defaultValue: _fontSize,
    );
  }

  static set fontSize(double fontSize) {
    Internal.settings.put(Appearance.fontSize.name, fontSize);
  }
}
