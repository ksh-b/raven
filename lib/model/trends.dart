
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/extractor/trend/apnews.dart';
import 'package:raven/extractor/trend/brave.dart';
import 'package:raven/extractor/trend/google.dart';
import 'package:raven/extractor/trend/none.dart';
import 'package:raven/extractor/trend/yahoo.dart';

Map<String, Trend> trends = {
  "None": NoneTrend(),
  "APNews": APNewsTrend(),
  "Brave": BraveTrend(),
  "Google": GoogleTrend(),
  "Yahoo": YahooTrend(),
};

abstract class Trend {

  String get url;
  String get locator;

  Future<List<String>> get topics async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      return document.querySelectorAll(locator).map((e) => e.text).toList();
    }
    return [];
  }

}