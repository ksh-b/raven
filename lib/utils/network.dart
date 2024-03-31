import 'package:raven/utils/store.dart';

class Network {
  static bool shouldLoadImage(String url) {
    return url.isNotEmpty && url.startsWith("https") && Store.loadImagesSetting;
  }
}
