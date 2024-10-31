import 'package:hive/hive.dart';

class Internal {

  static Box get settings {
    return Hive.box("settings");
  }

  static String get appDirectory {
    return settings.get("appDirectory", defaultValue: "");
  }

  static set appDirectory(String appDirectory) {
    settings.put("appDirectory", appDirectory);
  }

  static int get sdkVersion {
    return settings.get("sdkVersion", defaultValue: -1);
  }

  static set sdkVersion(int version) {
    settings.put("sdkVersion", version);
  }

}
