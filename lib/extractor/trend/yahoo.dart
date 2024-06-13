import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/trends.dart';
import 'package:raven/utils/store.dart';

class YahooTrend extends Trend {
  @override
  String get url => "https://www.yahoo.com/";

  @override
  String get locator => ".bd a span:last-child";

  @override
  Future<List<String>> get topics async {
    var country = "United States of America";
    var yUrl = url;
    if (Hive.isBoxOpen("settings")) {
      country = Store.countrySetting;
    }
    switch (country) {
      case "Australia": yUrl = "https://au.yahoo.com/"; break;
      case "Canada": yUrl = "https://ca.yahoo.com/"; break;
      case "India": yUrl = "https://in.search.yahoo.com/"; break;
      case "Malaysia": yUrl = "https://malaysia.yahoo.com/"; break;
      case "New Zealand": yUrl = "https://nz.yahoo.com/"; break;
      case "Singapore": yUrl = "https://sg.yahoo.com/"; break;
      case "United Kingdom": yUrl = "https://uk.yahoo.com/"; break;
      default: yUrl = "https://www.yahoo.com/"; break;
    }
    List<String> topics = [];
    dio().get(yUrl).then((response) {
      if (response.statusCode == 200) {
        Document document = html_parser.parse(response.data);
        topics = document.querySelectorAll(locator).map((e) => e.text).toList();
      }
    });
    topics = topics.take(10).toList();
    return topics;
  }

  static List<String> locations = [
    'United States of America',
    'Australia',
    'Canada',
    'India',
    'Malaysia',
    'New Zealand',
    'Singapore',
    'United Kingdom',
  ];
}
