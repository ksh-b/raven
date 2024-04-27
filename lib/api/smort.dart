import 'dart:convert';

import 'package:raven/model/article.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/publisher.dart';

class Smort {
  Future<NewsArticle> fallback(NewsArticle article) async {
    String url = "${publishers[article.publisher]!.homePage}${article.url}";
    var response = await http.get(
      Uri.parse("https://www.smort.io/article?smortParseAdvanced=true&url=$url"),
    );
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var text = document.querySelector("script[id='__NEXT_DATA__']")?.text ?? "";
      article.content = jsonDecode(text)["props"]["pageProps"]["body"] ?? document.outerHtml;
    }
    return article;
  }
}