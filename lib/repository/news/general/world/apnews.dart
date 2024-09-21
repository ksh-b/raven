import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';

class APNews extends Publisher {
  @override
  String get name => "AP News";

  @override
  String get homePage => "https://apnews.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  String get mainCategory => Category.world.name;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);
    if (response.successful) {
      var document = html_parser.parse(response.data);
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

    var unsupported = [
      "Election 2024",
      "Fact Check",
      "Oddities",
      "Newsletters",
      "Video",
      "Photography ",
      "AP Buyline Personal Finance",
      "AP Buyline Shopping",
      "Press Releases",
      "Press Releases",
      "My Account",
    ];
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
      var isLive =
          document.querySelectorAll("gu-island[name=PulsingDot]").isNotEmpty;
      var content = isLive
          ? document.querySelector('#liveblog-body')?.outerHtml
          : document.querySelector('.RichTextStoryBody')?.outerHtml ?? "";
      if (content != null && content.isEmpty) {
        content =
            document.querySelector('.VideoPage-pageSubHeading')?.outerHtml;
      }
      newsArticle = newsArticle.fill(
        excerpt:
            document.querySelector('div[data-gu-name="standfirst"] p')?.text ??
                "",
        content: content,
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
  Future<Set<Article>> articles({
    String category = "/world",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "/world-news",
    int page = 1,
  }) async {
    if (category == "/") {
      category = "/world-news";
    }
    if (page > 1) {
      return {};
    }
    Set<Article> articles = {};
    var response = await dio().get("$homePage$category");
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var data = document.querySelectorAll(".PageListStandardH .PagePromo");
      for (var article in data) {
        articles.add(
          Article(
            publisher: name,
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
            publishedAt: -1,
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
    var response = await dio().get("$homePage/search?q=$searchQuery&p=$page");
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var data =
          document.querySelectorAll(".SearchResultsModule-results .PagePromo");
      for (var article in data) {
        var timestamp = int.parse(document
                .querySelector('bsp-timestamp')
                ?.attributes['data-timestamp'] ??
            "0");
        articles.add(
          Article(
            publisher: name,
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
            publishedAt: timestamp,
            category: searchQuery,
            tags: [],
          ),
        );
      }
    }

    return articles;
  }

  int convertToUnixTimestamp(String dateString) {
    DateFormat dateFormat = DateFormat("h:mm a 'UTC', MMMM d, yyyy", 'en_US');
    DateTime dateTime = dateFormat.parse(dateString.trim());
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  bool get hasSearchSupport => true;
}
