import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class RfaBurmese extends Publisher {
  @override
  String get name => "မြန်မာဌာန";

  @override
  String get homePage => "https://www.rfa.org/burmese";

  @override
  Future<Map<String, String>> get categories async {
    Map<String, String> map = {"Burmese": "/burmese"};
    var response = await dio().get(homePage, options: options);

    if (response.successful) {
      var document = html_parser.parse(response.data);
      var elements = document.querySelectorAll(".header_top li a");
      for (var element in elements) {
        if (element.attributes["href"] == homePage) {
          continue;
        }
        map.putIfAbsent(
          element.text,
          () {
            return element.attributes["href"]!.replaceAll("$homePage", "");
          },
        );
      }
    }
    return map
      ..removeWhere(
        (key, value) => value == "/video",
      );
  }

  @override
  String get mainCategory => Category.myanmar.name;

  @override
  bool get hasSearchSupport => true;

  Options options = Options(headers: {
    "User-Agent":
        "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
  });

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get(newsArticle.url, options: options);
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var content = document.querySelector('#storytext')?.text ?? "";
      var author = document.querySelector("#story_byline")?.text ?? "";
      var thumbnail = document.querySelector("#headerimg img")?.text ?? "";

      newsArticle = newsArticle.fill(
        content: content,
        author: author,
        tags: [],
        thumbnail: thumbnail,
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "news",
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var limit = 15;
    var offset = (page - 1) * limit;

    var response = await dio().get(
      "$homePage/$category/story_archive?b_start:int=$offset",
      options: options,
    );

    if (response.successful) {
      var document = html_parser.parse(response.data);
      var data = document.querySelectorAll(".sectionteaser");
      for (var article in data) {
        var title = article.querySelector("span")?.text ?? "";
        var thumbnail = article.querySelector("img")?.attributes["src"] ?? "";
        var publishedAt = article.querySelector(".story_date")?.text ?? "";
        var excerpt = article.querySelector("story_description")?.text ?? "";
        var url = article.querySelector("a")?.attributes["href"] ?? "";

        articles.add(
          Article(
            publisher: name,
            title: title,
            content: "",
            excerpt: excerpt,
            author: "",
            url: url,
            tags: [],
            thumbnail: thumbnail,
            publishedAt: stringToUnix(publishedAt, format: "yyyy-MM-dd"),
            category: category,
          ),
        );
      }
    }
    return articles;
  }

  @override
  Future<Set<Article>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<Article> articles = {};
    var limit = 30;
    var offset = (page - 1) * limit;
    var response = await dio().get(
        "$homePage/@@search?SearchableText=$searchQuery&sort_on=Date&b_start:int=$offset",
        options: options);

    if (response.successful) {
      var document = html_parser.parse(response.data);
      var data = document.querySelectorAll(".searchresult");
      for (var article in data) {
        var title = article.querySelector("a.state-published")?.text ?? "";
        var thumbnail = article.querySelector("img")?.attributes["src"] ?? "";
        var publishedAt =
            article.querySelector(".searchresultdate")?.text.trim() ?? "";
        var excerpt = article.querySelector(".croppedDescription")?.text ?? "";
        var url =
            article.querySelector("a.state-published")?.attributes["href"] ??
                "";

        articles.add(
          Article(
            publisher: name,
            title: title,
            content: "",
            excerpt: excerpt,
            author: "",
            url: url,
            tags: [],
            thumbnail: thumbnail,
            publishedAt: stringToUnix(publishedAt, format: "yyyy-MM-dd"),
            category: "",
          ),
        );
      }
    }
    return articles;
  }
}
