import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/brain/dio_manager.dart';
import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
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
    Map<String, String> map = {
      "US": "/us",
      "World": "/world",
      "Politics": "/politics",
      "Business": "/business",
      "Opinion": "/opinion",
      "Health": "/health",
      "Entertainment": "/entertainment",
      "Style": "/style",
      "Travel": "/travel",
      "Sports": "/sports"
    };
    return map;
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    String url = "$homePage${newsArticle.url}";
    if (newsArticle.url.startsWith("http")) {
      url = newsArticle.url;
    } else {
      url = "$homePage${newsArticle.url}";
    }
    await dio().get(url).then((response) {
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        var timestamp =
            document.querySelector('.timestamp')?.text.split("\n")[2].trim() ??
                "";
        if (timestamp.isEmpty) {
          timestamp = document.querySelector(".timeAlert")?.text ?? "";
        }
        var live = document.querySelector("#posts-and-button");
        newsArticle = newsArticle.fill(
            excerpt: "",
            content: live != null
                ? live.outerHtml
                : document
                .querySelector(
                '.article__content,.video-resource,article[data-position],.gallery-inline_unfurled__description')
                ?.outerHtml ??
                "",
            author: document.querySelector('.byline__name')?.text ?? "",
            thumbnail: document
                .querySelector('.image__picture img')
                ?.attributes["src"] ??
                "",
            publishedAt: live != null
                ? stringToUnix(timestamp)
                : stringToUnix(timestamp.trim(),
                format: "h:mm a 'EDT', EEE MMMM d, yyyy"),
            tags: document
                .querySelectorAll(
                ".header__nav-container a[class='header__nav-item-link'][href]")
                .map((e) => e.text)
                .toList());
      }
    });


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
    if (category == "/") {
      category = "/world";
    }
    if (page > 1) {
      return {};
    }
    Set<NewsArticle> articles = {};
    await dio().get("$homePage$category").then((response) {
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        var data = document
            .querySelector(
            ".has-pseudo-class-fix-layout--wide-left-balanced-2")
            ?.querySelectorAll(".container__item--type-section") ??
            [];
        for (var article in data) {
          articles.add(NewsArticle(
            publisher: name,
            title:
            article.querySelector(".container__headline-text")?.text.trim() ??
                "",
            content: "",
            excerpt: "",
            author: "",
            url: article.querySelector("a")?.attributes["href"] ?? "",
            tags: [category],
            thumbnail: article.querySelector("img")?.attributes["src"] ?? "",
            publishedAt: -1,
            category: category,
          ));
        }
      }
    },);

    return articles;
  }

  @override
  Future<Set<NewsArticle>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};

    var url =
        'https://search.prod.di.api.cnn.io/content?q=$searchQuery&size=5&from=${(page - 1) * 5}&page=$page&sort=newest&request_id=0';
    await dio().get(url).then((response) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = (response.data);
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
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author,
            url: articleUrl,
            thumbnail: thumbnail,
            publishedAt: stringToUnix(time?.trim() ?? ""),
            category: searchQuery,
          ));
        }
      }
    },);
    return articles;
  }
}
