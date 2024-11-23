import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:raven/model/article.dart';
import 'package:raven/model/category.dart';
import 'package:raven/model/publisher.dart';
import 'package:raven/service/http_client.dart';
import 'package:raven/utils/network.dart';
import 'package:raven/utils/time.dart';

class AlJazeera extends Publisher {
  @override
  String get name => "Al Jazeera";

  @override
  String get homePage => "https://www.aljazeera.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  @override
  bool get hasSearchSupport => false;

  @override
  String get mainCategory => Category.world.name;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await dio().get(homePage);
    if (response.successful) {
      var document = html_parser.parse(response.data);
      document
          .querySelectorAll(".header-menu .menu__item--aje a")
          .forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
          () {
            return element.attributes["href"]!.replaceAll(homePage, "");
          },
        );
      });
    }

    var unsupported = [
      "Features",
      "Opinion",
      "Investigations",
      "Interactives",
      "In Pictures",
      "Podcasts",
      "Video",
      "Economy",
      "Climate Crisis",
    ];
    return map..removeWhere((key, value) => unsupported.contains(key));
  }

  @override
  Future<Article> article(Article newsArticle) async {
    var response = await dio().get(newsArticle.url);
    if (response.successful) {
      var document = html_parser.parse(response.data);
      var more = document.querySelector(".more-on")?.innerHtml ?? "";
      var article = document.querySelector("#main-content-area");
      var thumbnailElement = article?.querySelector('img');
      var content =
          document.querySelector('div[class*=wysiwyg]')?.innerHtml ?? "";
      if (content.isEmpty) {
        content = article?.querySelector(".article__subhead")?.innerHtml ?? "";
      }
      content = content.replaceAll(more, "");
      var thumbnail = "$homePage${thumbnailElement?.attributes["src"]}";
      newsArticle = newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<Article>> categoryArticles({
    String category = "All",
    int page = 1,
  }) async {
    if (category == "/") {
      category = "/news";
    }
    if (!category.startsWith("/")) {
      return {};
    }
    Set<Article> articles = {};
    Response? response = await get(category, page);
    if (response?.statusCode == 200) {
      final Map<String, dynamic> data = (response?.data);
      var articlesData = data["data"]["articles"] ?? [];
      for (var element in articlesData) {
        var title = element['title'];
        var author =
            element['author'].isNotEmpty ? element['author'][0]['name'] : "";
        var thumbnail = homePage + element['featuredImage']['sourceUrl'];
        var time = element['date'];
        var articleUrl = homePage + element['link'];
        var excerpt = element['excerpt'];
        articles.add(
          Article(
            publisher: name,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail,
            publishedAt: stringToUnix(time?.trim() ?? ""),
            tags: [
              articleUrl.split("/").length > 1 ? articleUrl.split("/")[1] : ""
            ],
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

  @override
  Future<Set<Article>> articles({
    String category = "features",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  Future<Response?> get(String category, int page) async {
    Response? response;
    var categoryType = "where";
    if (category.startsWith("/tag/")) {
      category = category.replaceAll("/tag/", "");
      categoryType = "tags";
    } else if (["/news/", "/sports/"].contains(category)) {
      categoryType = "categories";
    }
    category = category.trim().replaceAll("/", "");
    Map<String, String> headers = {'wp-site': 'aje'};
    Map<String, dynamic> variablesMap = {
      "category": category,
      "categoryType": categoryType,
      "postTypes": [
        "blog",
        "episode",
        "opinion",
        "post",
        "video",
        "external-article",
        "gallery",
        "podcast",
        "longform",
        "liveblog"
      ],
      "quantity": 5,
      "offset": (page - 1) * 5
    };
    response = await dio().get('https://www.aljazeera.com/graphql',
        queryParameters: {
          'wp-site': 'aje',
          'operationName': 'ArchipelagoAjeSectionPostsQuery',
          'variables': json.encode(variablesMap),
          'extensions': '{}',
        },
        options: Options(headers: headers));
    return response;
  }
}
