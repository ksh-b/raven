import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/country.dart';
import 'package:raven/model/trends.dart';
import 'package:raven/utils/store.dart';

class GoogleTrend extends Trend {
  @override
  String get url => "https://trends.google.com/trends/api/dailytrends?geo=";

  @override
  String get locator => "";

  @override
  Future<List<String>> get topics async {
    var country = "US";
    if (Hive.isBoxOpen("settings"))
      country = "${countryCodes[Store.countrySetting]}";
    var response = await dio().get(url + country, options: Options(
      responseType: ResponseType.plain,
    ));
    List<String> queries = [];
    if (response.statusCode == 200) {
      Document document = html_parser.parse(response.data);
      var jsonText = document.outerHtml
          .replaceFirst(")]}',", "")
          .replaceFirst("<html><head></head><body>", "")
          .replaceFirst("</body></html>", "");
      print(jsonText);
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
