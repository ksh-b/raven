import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/time.dart';

class CNN extends Publisher {
  @override
  String get name => "CNN";

  @override
  String get homePage => "https://edition.cnn.com";

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
          .querySelectorAll(
              ".header__nav-container a[class='header__nav-item-link'][href]")
          .forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
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
    http.Response response;
    if (newsArticle.url.startsWith("http")) {
      response = await http.get(Uri.parse(newsArticle.url));
    } else {
      response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    }
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var timestamp =
          document.querySelector('.timestamp')?.text.split("\n")[2].trim() ??
              "";
      if (timestamp.isEmpty) {
        timestamp = document.querySelector(".timeAlert")?.text ?? "";
      }
      var live = document.querySelector("#posts-and-button");
      return newsArticle.fill(
          excerpt: "",
          content: live != null
              ? live.outerHtml
              : document
                      .querySelector('.article__content,.video-resource,article[data-position]')
                      ?.outerHtml ??
                  "",
          author: document.querySelector('.byline__name')?.text ?? "",
          thumbnail: document
                  .querySelector('.image__picture img')
                  ?.attributes["src"] ??
              "",
          publishedAt: live != null
              ? parseDateString(timestamp)
              : parseUnixTime(convertToUnixTimestamp(timestamp) * 1000),
          tags: document
              .querySelectorAll(
                  ".header__nav-container a[class='header__nav-item-link'][href]")
              .map((e) => e.text)
              .toList());
    }
    return newsArticle;
  }

  int convertToUnixTimestamp(String dateString) {
    DateFormat dateFormat =
        DateFormat("h:mm a 'EDT', EEE MMMM d, yyyy", 'en_US');
    DateTime dateTime =
        dateFormat.tryParse(dateString.trim()) ?? DateTime.timestamp();
    return dateTime.millisecondsSinceEpoch ~/ 1000;
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
    if (category == "/") {
      category = "/world";
    }
    if (page > 1) {
      return {};
    }
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse("$homePage$category"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var data = document
          .querySelector(".has-pseudo-class-fix-layout--wide-left-balanced-2")
          ?.querySelectorAll(".container__item--type-section");
      for (var article in data!) {
        articles.add(NewsArticle(
          publisher: this,
          title:
              article.querySelector(".container__headline-text")?.text.trim() ??
                  "",
          content: "",
          excerpt: "",
          author: "",
          url: article.querySelector("a")?.attributes["href"] ?? "",
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

    var url = Uri.parse(
        'https://search.prod.di.api.cnn.io/content?q=$searchQuery&size=5&from=${(page - 1) * 5}&page=$page&sort=newest&request_id=0');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data["message"] != "success") {
        return {};
      }
      var articlesData = data["result"];
      for (var element in articlesData) {
        var title = element['headline'];
        var author = "";
        var thumbnail = element['thumbnail'];
        var time = element['lastModifiedDate'];
        var articleUrl = element['url'];
        var excerpt = element['body'];
        articles.add(NewsArticle(
          publisher: this,
          title: title ?? "",
          content: "",
          excerpt: excerpt,
          author: author,
          url: articleUrl,
          thumbnail: thumbnail,
          publishedAt: parseDateString(time?.trim() ?? ""),
          category: searchQuery,
        ));
      }
    }

    return articles;
  }
}
