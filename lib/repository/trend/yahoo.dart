import 'package:hive_ce/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/trend.dart';
import 'package:raven/repository/preferences/content.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';

class YahooTrend extends Trend {
  @override
  String get name => "Yahoo";

  @override
  String get url => "https://www.yahoo.com/";

  @override
  String get locator => ".trendingNow .Ell";

  @override
  Future<List<String>> get topics async {
    var country = "United States of America";
    var locator = this.locator;
    var yUrl = url;
    if (Hive.isBoxOpen("settings")) {
      country = ContentPref.country;
    }
    switch (country) {
      case "Australia":
        yUrl = "https://au.yahoo.com/";
        break;
      case "Canada":
        yUrl = "https://ca.yahoo.com/";
        break;
      case "India":
        yUrl = "https://in.search.yahoo.com/";
        locator = ".keyword-text";
        break;
      case "Malaysia":
        yUrl = "https://malaysia.yahoo.com/";
        break;
      case "New Zealand":
        yUrl = "https://nz.yahoo.com/";
        break;
      case "Singapore":
        yUrl = "https://sg.yahoo.com/";
        break;
      case "United Kingdom":
        yUrl = "https://uk.yahoo.com/";
        break;
      default:
        yUrl = "https://www.yahoo.com/";
        break;
    }
    List<String> topics = [];
    var response = await dio().get(yUrl);
    if (response.successful) {
      Document document = html_parser.parse(response.data);
      topics = document.querySelectorAll(locator).map((e) => e.text).toList();
    }
    topics = topics.take(10).toList();
    return topics;
  }

  @override
  List<String> locations = [
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
