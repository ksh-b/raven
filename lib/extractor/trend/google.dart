import 'package:hive/hive.dart';
import 'package:raven/model/country.dart';
import 'package:raven/model/trends.dart';

import 'dart:convert';

import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/store.dart';

class GoogleTrend extends Trend {
  @override
  String get url =>
      "https://trends.google.com/trends/api/dailytrends?geo=";

  @override
  String get locator => "";

  @override
  Future<List<String>> get topics async {
    var country = "US";
    if(Hive.isBoxOpen("settings"))
      country = "${countryCodes[Store.countrySetting]}";
    var response = await http.get(Uri.parse(url+country));
    List<String> queries = [];
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      var jsonText = document.outerHtml
          .replaceFirst(")]}',", "")
          .replaceFirst("<html><head></head><body>", "")
          .replaceFirst("</body></html>", "");
      var somethings = json.decode(jsonText)["default"]["trendingSearchesDays"];
      for (var something in somethings) {
        var searches = something["trendingSearches"];
        for (var search in searches) {
          queries.add(search["title"]["query"].toString());
        }
      }
      return queries.take(10).toList();
    }
    return [];
  }

  static List<String> locations = [
    'Argentina',
    'Australia',
    'Austria',
    'Belgium',
    'Brazil',
    'Canada',
    'Chile',
    'Colombia',
    'Czechia',
    'Denmark',
    'Egypt',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'Hong Kong',
    'Hungary',
    'India',
    'Indonesia',
    'Ireland',
    'Israel',
    'Italy',
    'Japan',
    'Kenya',
    'Malaysia',
    'Mexico',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Romania',
    'Russia',
    'Saudi Arabia',
    'Singapore',
  ];
}
