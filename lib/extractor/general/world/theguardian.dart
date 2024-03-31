// ignore_for_file: unused_import

import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/string.dart';
import 'package:raven/utils/time.dart';

class TheGuardian extends Publisher {
  @override
  String get name => "The Guardian";

  @override
  String get homePage => "https://www.theguardian.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  Category get mainCategory => Category.world;

  @override
  bool get hasSearchSupport => false;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      document
          .querySelectorAll('.dcr-1xyuhwc gu-island .dcr-qxru8z')
          .forEach((element) {
        map.putIfAbsent(
          element.text,
              () {
            return element.attributes["href"]!;
          },
        );
      });
    }
    return map;
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    print("$homePage${newsArticle.url}");
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var article = document.querySelector('article');
      var isLive = document.querySelectorAll("gu-island[name=PulsingDot]").isNotEmpty;
      print(document.querySelector('#liveblog-body')?.text);
      return newsArticle.fill(
        excerpt: article?.querySelector('div[data-gu-name="standfirst"] p')?.text ?? "",
        content: isLive?document.querySelector('#liveblog-body')?.outerHtml:article?.querySelector('#maincontent')?.outerHtml ?? "",
        author: article?.querySelector('a[rel="author"]')?.text ?? "",
        category: article?.querySelector('.content__label__link span')?.text ?? "",
        thumbnail: article?.querySelector('article img')?.attributes["src"] ?? "",
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> articles({
    String category = "/world",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/world",
    int page = 1,
  }) async {
    if(category=="/") {
      category="/world";
    }
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse("$homePage$category?page=$page"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var data = document.querySelectorAll(".fc-item__container");
      for (var article in data) {
        articles.add(NewsArticle(
            publisher: this,
            title: article.querySelector(".fc-item__header a .js-headline-text")?.text.trim() ?? "",
            content: "",
            excerpt: "",
            author: "",
            url: article.querySelector("a")?.attributes["href"]?.replaceFirst(homePage, "") ?? "",
            tags: [category],
            thumbnail: article.querySelector("img")?.attributes["src"] ?? "",
            publishedAt: parseUnixTime((int.parse(article.querySelector("time")?.attributes["data-timestamp"]??"0")).toInt()),
            category: category,
        ));
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    return {};
  }
}
