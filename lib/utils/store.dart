import 'package:hive/hive.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/trends.dart';
import 'package:raven/model/user_subscription.dart';
import 'package:raven/utils/theme_provider.dart';

class Store {
  static Map<String, String> ladders = {
    "12ft": "https://12ft.io",
    "1ft": "https://1ft.io",
    "archive.is": "https://archive.is",
    "archive.ph": "https://archive.ph",
    "Web Archive": "https://web.archive.org/web/*",
  };

  //// Subscriptions ////

  static Box get subscriptions {
    return Hive.box("subscriptions");
  }

  static List<UserSubscription> get selectedSubscriptions {
    return List<UserSubscription>.from(
        subscriptions.get("selected", defaultValue: []));
  }

  static set selectedSubscriptions(List<UserSubscription> newSubscriptions) {
    subscriptions.put("selected", newSubscriptions);
  }

  static List get customSubscriptions {
    return subscriptions.get("custom", defaultValue: []);
  }

  static set customSubscriptions(List newSubscriptions) {
    subscriptions.put("custom", newSubscriptions);
  }

  //// Settings ////

  static Box get settings {
    return Hive.box("settings");
  }

  static String get ladderSetting {
    return settings.get("ladder", defaultValue: ladders.keys.first);
  }

  static set ladderSetting(String ladder) {
    settings.put("ladder", ladder);
  }

  static set languageSetting(String language) {
    settings.put("language", language);
  }

  static bool get loadImagesSetting {
    return settings.get("loadImages", defaultValue: true);
  }

  static set loadImagesSetting(bool load) {
    settings.put("loadImages", load);
  }

  static String get trendsProviderSetting {
    return settings.get("trendsProvider", defaultValue: trends.keys.first);
  }

  static set trendsProviderSetting(String provider) {
    settings.put("trendsProvider", provider);
  }

  static String get countrySetting {
    return settings.get("country", defaultValue: "United States of America");
  }

  static set countrySetting(String country) {
    settings.put("country", country);
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

  static int get materialYouColor {
    return settings.get("materialYouColor", defaultValue: -1);
  }

  static set materialYouColor(int color) {
    settings.put("materialYouColor", color);
  }

  static int get sdkVersion {
    return settings.get("sdkVersion", defaultValue: -1);
  }

  static set sdkVersion(int version) {
    settings.put("sdkVersion", version);
  }

  static String get ladderUrl {
    return ladders[ladderSetting] ?? ladders.keys.first;
  }

  static String get languageSetting {
    return settings.get("language", defaultValue: "English");
  }

  static bool get shouldTranslate {
    return settings.get("translate", defaultValue: false);
  }

  static set shouldTranslate(bool should) {
    settings.put("translate", should);
  }

  static double get fontScale {
    return settings.get("scale", defaultValue: 1.0);
  }

  static set fontScale(double scale) {
    settings.put("scale", scale);
  }

  //// Saved ////

  static Box get saved {
    return Hive.box("saved");
  }

  static void saveArticle(NewsArticle article) {
    saved.put(article.url, article);
  }

  static void deleteArticle(NewsArticle article) {
    saved.delete(article.url);
  }

  static List<dynamic> getSavedArticles(NewsArticle article) {
    return saved.values.toList();
  }
}
