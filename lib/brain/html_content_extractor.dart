import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:raven/model/article.dart';

class HtmlContentExtractor {
  Future<NewsArticle> fallback(NewsArticle article) async {
    var response = await http.get(Uri.parse(article.url));
    var document = html_parser.parse(utf8.decode(response.bodyBytes));
    article.content = document.querySelector("article")?.innerHtml ??
        document.querySelector("*[class*='article-body']")?.innerHtml ??
        document.querySelector("*[class*='article']")?.innerHtml ??
        document.querySelector("*[class*='story']")?.innerHtml ??
        "";
    return article;
  }
}
