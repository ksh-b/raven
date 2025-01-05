import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/internal.dart';

class Network {
  static bool shouldLoadImage(String url) {
    return url.isNotEmpty && url.startsWith("https") && ContentPref.shouldLoadImages;
  }

  static Future<bool> isConnected() async {
    List<ConnectivityResult> list = await (Connectivity().checkConnectivity());
    return list.contains(ConnectivityResult.wifi) ||
        list.contains(ConnectivityResult.mobile) ||
        list.contains(ConnectivityResult.other);
  }
}

extension ResponseExtension on Response {
  bool get successful => statusCode == 200 || statusCode == 304;
}
