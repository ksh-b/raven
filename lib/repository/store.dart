import 'package:hive/hive.dart';

class Store {

  static Box get settings {
    return Hive.box("settings");
  }

}
