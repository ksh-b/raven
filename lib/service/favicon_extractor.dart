import 'package:flutter/cupertino.dart';

class FaviconExtractor {

  static String favicon(String url) {
    Uri uri = Uri.parse(url);
    String host = uri.host;
    if(host.startsWith("feeds.")) {
      host = host.replaceAll("feeds.", "");
    }
    return "https://f2.allesedv.com/16/$host";
  }

}
