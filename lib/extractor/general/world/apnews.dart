import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/time.dart';

class APNews extends Publisher {
  @override
  String get name => "AP News";

  @override
  String get homePage => "https://apnews.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  Category get mainCategory => Category.world;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      document
          .querySelectorAll('.Page-header-navigation .AnClick-MainNav')
          .forEach((element) {
        map.putIfAbsent(
          element.text,
          () {
            return element.attributes["href"]!.replaceFirst(homePage, "");
          },
        );
      });
    }
    return map;
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var isLive =
          document.querySelectorAll("gu-island[name=PulsingDot]").isNotEmpty;
      return newsArticle.fill(
        excerpt:
            document.querySelector('div[data-gu-name="standfirst"] p')?.text ??
                "",
        content: isLive
            ? document.querySelector('#liveblog-body')?.outerHtml
            : document.querySelector('.RichTextStoryBody')?.outerHtml ?? "",
        author: document.querySelector('a[rel="author"]')?.text ?? "",
        tags: [
          document.querySelector('.content__label__link span')?.text ?? ""
        ],
        thumbnail:
            document.querySelector('.Page-main .Image')?.attributes["src"] ??
                "",
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
    String category = "/world-news",
    int page = 1,
  }) async {
    if (category == "/") {
      category = "/world-news";
    }
    if (page > 1) {
      return {};
    }
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse("$homePage$category"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var data = document.querySelectorAll(".PageListStandardH .PagePromo");
      for (var article in data) {
        articles.add(NewsArticle(
          publisher: this,
          title: article.querySelector(".PagePromo-title")?.text.trim() ?? "",
          content: "",
          excerpt:
              article.querySelector(".PagePromo-description")?.text.trim() ??
                  "",
          author: "",
          url: article
                  .querySelector("a")
                  ?.attributes["href"]
                  ?.replaceFirst(homePage, "") ??
              "",
          tags: [category],
          thumbnail: article.querySelector("img")?.attributes["src"] ?? "",
          publishedAt: MapEntry(-1, ""),
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
    Set<NewsArticle> articles = {};
    var response =
        await http.get(Uri.parse("$homePage/search?q=$searchQuery&p=$page"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var data =
          document.querySelectorAll(".SearchResultsModule-results .PagePromo");
      for (var article in data) {
        var timestamp = int.parse(document
                .querySelector('bsp-timestamp')
                ?.attributes['data-timestamp'] ??
            "0");
        articles.add(NewsArticle(
          publisher: this,
          title: article.querySelector(".PagePromo-title")?.text.trim() ?? "",
          content: "",
          excerpt:
              article.querySelector(".PagePromo-description")?.text.trim() ??
                  "",
          author: "",
          url: article
                  .querySelector("a")
                  ?.attributes["href"]
                  ?.replaceFirst(homePage, "") ??
              "",
          thumbnail: article.querySelector("img")?.attributes["src"] ?? "",
          publishedAt: parseUnixTime(timestamp),
          category: searchQuery,
        ));
      }
    }
    return articles;
  }

  int convertToUnixTimestamp(String dateString) {
    DateFormat dateFormat = DateFormat("h:mm a 'UTC', MMMM d, yyyy", 'en_US');
    DateTime dateTime = dateFormat.parse(dateString.trim());
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }
}
