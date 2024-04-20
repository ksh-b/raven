import 'package:raven/model/article.dart';
import 'package:raven/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:raven/utils/string.dart';
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
  Category get mainCategory => Category.world;

  Future<Map<String, String>> extractCategories() async {
    Map<String, String> map = {};
    var response = await http.get(Uri.parse(homePage));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      document
          .querySelectorAll(".header-menu .menu__item--aje a")
          .forEach((element) {
        map.putIfAbsent(
          element.text.trim(),
              () {
            return element.attributes["href"]!
                .replaceAll(homePage, "")
                .replaceAll("tag/", "")
                .replaceAll("/", "");
          },
        );
      });
    }
    var unsupported = ["Opinion","Investigations","Interactives","In Pictures","Podcasts",];
    return map..removeWhere((key, value) => unsupported.contains(key));
  }

  @override
  Future<NewsArticle> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse('$homePage${newsArticle.url}'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));
      var more = document.querySelector(".more-on")?.innerHtml ?? "";
      var article = document.querySelector("#main-content-area");
      var thumbnailElement = article?.querySelector('img');
      var content = document.querySelector('.wysiwyg--all-content')?.innerHtml ?? "";
      if (content.isEmpty) {
        content = article?.querySelector(".article__subhead")?.innerHtml ?? "";
      }
      content = content.replaceAll(more, "");
      var thumbnail = "$homePage${thumbnailElement?.attributes["src"]}";
      return newsArticle.fill(
        content: content,
        thumbnail: thumbnail,
      );
    }
    return newsArticle;
  }

  @override
  Future<Set<NewsArticle>> articles({
    String category = "features",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  Future<Set<NewsArticle>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    Set<NewsArticle> articles = {};

    if (category == "/") {
      category = "news";
    }

    var url = Uri.parse(
        'https://www.aljazeera.com/graphql?wp-site=aje&operationName=ArchipelagoAjeSectionPostsQuery&variables={"category":"$category","categoryType":"where","postTypes":["blog","episode","opinion","post","video","external-article","gallery","podcast","longform","liveblog"],"quantity":5,"offset":${(page - 1) * 5}}&extensions={}');
    var headers = {'wp-site': 'aje'};

    var response = await http.get(url, headers: headers);
    if (json.decode(response.body)["data"]["articles"] == null) {
      url = Uri.parse(
          'https://www.aljazeera.com/graphql?wp-site=aje&operationName=ArchipelagoAjeSectionPostsQuery&variables={"category":"$category","categoryType":"categories","postTypes":["blog","episode","opinion","post","video","external-article","gallery","podcast","longform","liveblog"],"quantity":5,"offset":${(page - 1) * 5}}&extensions={}');
      response = await http.get(url, headers: headers);
    }

    if (json.decode(response.body)["data"]["articles"] == null) {
      url = Uri.parse(
          'https://www.aljazeera.com/graphql?wp-site=aje&operationName=ArchipelagoAjeSectionPostsQuery&variables={"category":"$category","categoryType":"tags","postTypes":["blog","episode","opinion","post","video","external-article","gallery","podcast","longform","liveblog"],"quantity":5,"offset":${(page - 1) * 5}}&extensions={}');
      response = await http.get(url, headers: headers);
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      var articlesData = data["data"]["articles"] ?? [];
      for (var element in articlesData) {
        var title = element['title'];
        var author =
            element['author'].isNotEmpty ? element['author'][0]['name'] : "";
        var thumbnail = homePage + element['featuredImage']['sourceUrl'];
        var time = element['date'];
        var articleUrl = element['link'];
        var excerpt = element['excerpt'];
        articles.add(NewsArticle(
            publisher: this,
            title: title ?? "",
            content: "",
            excerpt: excerpt,
            author: author ?? "",
            url: articleUrl,
            thumbnail: thumbnail,
            publishedAt: stringToUnix(time?.trim() ?? ""),
            tags: [createTag(category)],
            category: category));
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
