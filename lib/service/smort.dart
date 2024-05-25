import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/fallback.dart';
import 'package:raven/model/publisher.dart';

class Smort extends Fallback {
  @override
  String get name => "Smort";

  @override
  Future<MapEntry<bool, NewsArticle>> fallback(NewsArticle article) async {
    String url = "${publishers[article.publisher]!.homePage}${article.url}";
    bool success = false;
    await dio().get(
      "https://www.smort.io/article?smortParseAdvanced=true&url=$url",
    ).then((response) {
      if (response.statusCode == 200) {
        success = true;
        var document = html_parser.parse(response.data);
        var text =
            document.querySelector("script[id='__NEXT_DATA__']")?.text ?? "";
        article.content =
            jsonDecode(text)["props"]["pageProps"]["body"] ?? document.outerHtml;
      }
    },);

    if(!success) {
      return MapEntry(false, article);
    }
    return MapEntry(true, article);
  }
}
