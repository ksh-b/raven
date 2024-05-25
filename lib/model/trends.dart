import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/extractor/trend/apnews.dart';
import 'package:raven/extractor/trend/google.dart';
import 'package:raven/extractor/trend/none.dart';
import 'package:raven/extractor/trend/yahoo.dart';

Map<String, Trend> trends = {
  "None": NoneTrend(),
  "APNews": APNewsTrend(),
  "Google": GoogleTrend(),
  "Yahoo": YahooTrend(),
};

abstract class Trend {
  String get url;
  String get locator;

  Future<List<String>> get topics async {
    List<String> topics = [];
    await dio().get(url).then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        topics = document.querySelectorAll(locator).map((e) => e.text).toList();
      }
    });
    return topics;
  }
}
