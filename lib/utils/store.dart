import 'package:hive/hive.dart';
import 'package:whapp/utils/theme_provider.dart';

class Store {

  static List<String> loadImagesValues = ["Always", "Never"];

  static Map<String, String> ladders = {
    "12ft": "https://12ft.io",
    "1ft": "https://1ft.io",
    "archive.is": "https://archive.is",
    "archive.ph": "https://archive.ph",
    "Web Archive": "https://web.archive.org/web/*",
  };

  static Box get subscriptions {
    return Hive.box("subscriptions");
  }

  static List get selectedSubscriptions {
    return subscriptions.get("selected", defaultValue: []);
  }

  static set selectedSubscriptions(List newSubscriptions) {
    subscriptions.put("selected", newSubscriptions);
  }

  static List get customSubscriptions {
    return subscriptions.get("custom", defaultValue: []);
  }

  static set customSubscriptions(List newSubscriptions) {
    subscriptions.put("custom", newSubscriptions);
  }

  static Box get settings {
    return Hive.box("settings");
  }

  static String get ladderSetting {
    return settings.get("ladder", defaultValue: ladders.keys.first);
  }

  static set ladderSetting(String ladder) {
    settings.put("ladder", ladder);
  }

  static String get loadImagesSetting {
    return settings.get("loadImages", defaultValue: loadImagesValues.first);
  }

  static set loadImagesSetting(String load) {
    settings.put("loadImages", load);
  }

  static bool get darkThemeSetting {
    return settings.get("darkMode", defaultValue: false);
  }

  static set darkThemeSetting(bool load) {
    settings.put("darkMode", load);
  }

  static String get themeColorSetting {
    return settings.get("themeColor", defaultValue: ThemeProvider.defaultColor);
  }

  static set themeColorSetting(String color) {
    settings.put("themeColor", color);
  }

  static String get ladderUrl {
    return ladders[ladderSetting] ?? ladders.keys.first;
  }

}