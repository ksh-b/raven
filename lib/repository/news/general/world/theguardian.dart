import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class TheGuardian extends Publisher {
  @override
  String get name => "The Guardian";

  @override
  String get homePage => "https://www.theguardian.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.world.name;

  @override
  bool get hasSearchSupport => false;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);

    if (response.successful) {
      var document = html_parser.parse(response.data);
      document
          .querySelectorAll("header gu-island ul li a")
          .forEach((element) {
        map.putIfAbsent(
          element.text,
          () {
            return element.attributes["href"]!;
          },
        );
      });
    }

    var unsupported = ["Opinion"];

    return map
      ..removeWhere(
        (key, value) => unsupported.contains(key),
      );
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get("$homePage${newsArticle.url}");
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var article = document.querySelector('article');
      var isLive =
          document.querySelectorAll("gu-island[name=PulsingDot]").isNotEmpty;
      newsArticle = newsArticle.fill(
        excerpt:
            article?.querySelector('div[data-gu-name="standfirst"] p')?.text ??
                "",
        content: isLive
            ? document.querySelector('#liveblog-body')?.outerHtml
            : article?.querySelector('#maincontent')?.outerHtml ?? "",
        author: article?.querySelector('a[rel="author"]')?.text ?? "",
        tags: [
          article?.querySelector('.content__label__link span')?.text ?? ""
        ],
        thumbnail:
            article?.querySelector('article img')?.attributes["src"] ?? "",
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> articles({
    String category = "/world",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "/world",
    int page = 1,
  }) async {
    if (category == "/") {
      category = "/world";
    }
    Set<Article> articles = {};
    var response = await dio().get("$homePage$category?page=$page");
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var data = document.querySelectorAll("#maincontent div[class*='dcr-']");
      for (var article in data) {
        var title = article.querySelector("a")?.attributes["aria-label"] ?? "";
        if (title.isEmpty) {
          continue;
        }
        articles.add(
          Article(
            publisher: name,
            title: title,
            content: "",
            excerpt: "",
            author: "",
            url: article
                    .querySelector("a")
                    ?.attributes["href"]
                    ?.replaceFirst(homePage, "") ??
                "",
            tags: [category],
            thumbnail: article
                    .querySelector("img")
                    ?.attributes["src"]
                    ?.replaceFirst("width=120", "width=720")
                    .replaceFirst("width=75", "width=720") ??
                "",
            publishedAt: article.querySelector("time") != null
                ? isoToUnix(
                    article.querySelector("time")!.attributes["datetime"]!)
                : -1,
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
    return {};
  }
}
